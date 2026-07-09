--[[
  MIT License

  Copyright (c) 2026 Michael Wiesendanger

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.
]]--

--[[
  Tests for the SavedVariables defaulting and accessors (code/Configuration.lua).

  SetupConfiguration recursively merges a single DEFAULTS table into the saved table on every
  load/upgrade (fresh install = empty table gets everything, upgrade = only missing keys). The module
  owns the PulseConfiguration global and rgp.configuration; both are re-created by re-dofiling
  code/Configuration.lua in before_each (per the bootstrap module-state convention). SetAddonVersion
  runs MigrationPath (dispatching the version-keyed steps in me.migrationSteps - empty in production
  until the first schema change ships, injected here to prove the mechanism) before stamping
  addonVersion from C_AddOns.GetAddOnMetadata, stubbed via WowStubs to return a fixed version string
  (and a Title, which the logger prints). SetupConfiguration logs through rgp.logger, whose PrintLogMessage
  consults rgp.filter -- loaded here in TOC order (Filter precedes Configuration in Pulse.toc) so the
  real logging path is satisfied. The logger's level is then dropped below `error` to keep the chat
  prints out of the test output (the bootstrap shims LOG_LEVEL = 4 / debug).
]]--

-- busted extends `assert` with .same / .equal / etc. at runtime; luacheck cannot verify those
-- fields statically. Suppress warning 143 (accessing undefined field of a global variable).
-- luacheck: globals describe it before_each after_each rgp RGP_CONSTANTS PulseConfiguration
-- luacheck: ignore 143

local wowStubs = require("WowStubs")

describe("Configuration", function()
  local configuration
  local restore

  -- dofiling code/Configuration.lua replaces rgp.configuration (the bootstrap installs a no-op that
  -- ProfileSpec relies on) and lowers rgp.logger.logLevel below. Both are deep fields of the shared
  -- `rgp` table: busted's file insulation snapshots only the top-level `rgp` reference, not its
  -- contents, so these would leak into later specs -- capture and restore them in after_each. The
  -- PulseConfiguration global is a top-level _G key, so file insulation restores it on its own (and
  -- restoring it manually here fights the per-block env insulation that makes the before_each dofile
  -- reset work, so we must NOT touch it).
  local originalConfiguration = rgp.configuration
  local originalLogLevel = rgp.logger.logLevel

  before_each(function()
    restore = wowStubs.install({
      C_AddOns = wowStubs.stubs.C_AddOns({ Version = "1.2.3", Title = "Pulse" })
    })

    -- Filter precedes Configuration in Pulse.toc; the logger's PrintLogMessage consults rgp.filter
    dofile("code/Filter.lua")
    -- re-run code/Configuration.lua to get a fresh, empty PulseConfiguration (defaults are
    -- applied by SetupConfiguration, not at file scope)
    dofile("code/Configuration.lua")
    configuration = rgp.configuration

    -- keep the logger's chat prints out of the test output
    rgp.logger.logLevel = rgp.logger.error - 1
  end)

  after_each(function()
    restore()
    rgp.configuration = originalConfiguration
    rgp.logger.logLevel = originalLogLevel
  end)

  describe("SetupConfiguration", function()
    it("fills a fresh install (empty saved table) with every documented default", function()
      configuration.SetupConfiguration()

      assert.is_false(PulseConfiguration.lockEnergyBar)
      assert.are.same({}, PulseConfiguration.frames)
      assert.are.same({}, PulseConfiguration.profiles)
      assert.are.equal(RGP_CONSTANTS.ELEMENT_ENERGY_BAR_WIDTH, PulseConfiguration.energyBarWidth)
      assert.are.equal(RGP_CONSTANTS.ELEMENT_ENERGY_BAR_HEIGHT, PulseConfiguration.energyBarHeight)
      assert.are.equal("1.2.3", PulseConfiguration.addonVersion)
    end)

    it("fills only the missing fields of a partial (upgraded) saved table", function()
      PulseConfiguration.energyBarWidth = 200
      PulseConfiguration.frames = { P_EnergyBar = { point = "CENTER" } }

      configuration.SetupConfiguration()

      -- existing values, including keys the user wrote into the frames table, survive
      assert.are.equal(200, PulseConfiguration.energyBarWidth)
      assert.are.same({ P_EnergyBar = { point = "CENTER" } }, PulseConfiguration.frames)
      -- missing fields get their defaults
      assert.is_false(PulseConfiguration.lockEnergyBar)
      assert.are.equal(RGP_CONSTANTS.ELEMENT_ENERGY_BAR_HEIGHT, PulseConfiguration.energyBarHeight)
      assert.are.same({}, PulseConfiguration.profiles)
    end)

    it("does not overwrite values that are already set, including false", function()
      PulseConfiguration.lockEnergyBar = false
      PulseConfiguration.energyBarWidth = 200
      PulseConfiguration.energyBarHeight = 45

      configuration.SetupConfiguration()

      assert.is_false(PulseConfiguration.lockEnergyBar)
      assert.are.equal(200, PulseConfiguration.energyBarWidth)
      assert.are.equal(45, PulseConfiguration.energyBarHeight)
    end)

    it("does not overwrite a value that differs from its default", function()
      PulseConfiguration.lockEnergyBar = true -- default is false

      configuration.SetupConfiguration()

      assert.is_true(PulseConfiguration.lockEnergyBar)
    end)

    it("merges in place, preserving the PulseConfiguration table reference", function()
      local reference = PulseConfiguration

      configuration.SetupConfiguration()

      assert.is_true(rawequal(reference, PulseConfiguration))
      assert.are.same({}, reference.frames)
    end)
  end)

  describe("MigrationPath", function()
    it("runs an injected step when the saved version is older, before stamping the current one", function()
      PulseConfiguration.addonVersion = "v1.0.0"

      local versionSeenByStep
      table.insert(configuration.migrationSteps, {
        version = "v1.2.0",
        upgrade = function()
          versionSeenByStep = PulseConfiguration.addonVersion
        end
      })

      configuration.SetupConfiguration()

      -- the step ran while the saved version was still the old one ...
      assert.are.equal("v1.0.0", versionSeenByStep)
      -- ... and only afterwards was the version stamped to current (the stubbed metadata)
      assert.are.equal("1.2.3", PulseConfiguration.addonVersion)
    end)

    it("skips a step whose version equals the saved version", function()
      PulseConfiguration.addonVersion = "v1.2.0"

      local stepRan = false
      table.insert(configuration.migrationSteps, {
        version = "v1.2.0",
        upgrade = function() stepRan = true end
      })

      configuration.SetupConfiguration()

      assert.is_false(stepRan)
      assert.are.equal("1.2.3", PulseConfiguration.addonVersion)
    end)

    it("skips a step whose version is older than the saved version", function()
      PulseConfiguration.addonVersion = "v1.3.0"

      local stepRan = false
      table.insert(configuration.migrationSteps, {
        version = "v1.2.0",
        upgrade = function() stepRan = true end
      })

      configuration.SetupConfiguration()

      assert.is_false(stepRan)
      assert.are.equal("1.2.3", PulseConfiguration.addonVersion)
    end)

    it("skips every step on a fresh install without a saved version", function()
      local stepRan = false
      table.insert(configuration.migrationSteps, {
        version = "v99.0.0",
        upgrade = function() stepRan = true end
      })

      configuration.SetupConfiguration()

      assert.is_false(stepRan)
      assert.are.equal("1.2.3", PulseConfiguration.addonVersion)
    end)

    it("compares versions numerically, not lexically", function()
      PulseConfiguration.addonVersion = "v1.9.0"

      local stepRan = false
      table.insert(configuration.migrationSteps, {
        version = "v1.10.0",
        upgrade = function() stepRan = true end
      })

      configuration.SetupConfiguration()

      assert.is_true(stepRan)
    end)
  end)

  describe("energy bar lock", function()
    it("round-trips lock / unlock through IsEnergyBarLocked", function()
      configuration.LockEnergyBar()
      assert.is_true(configuration.IsEnergyBarLocked())

      configuration.UnlockEnergyBar()
      assert.is_false(configuration.IsEnergyBarLocked())
    end)
  end)

  describe("energy bar dimensions", function()
    it("round-trips width through set / get", function()
      configuration.SetEnergyBarWidth(250)
      assert.are.equal(250, configuration.GetEnergyBarWidth())
    end)

    it("round-trips height through set / get", function()
      configuration.SetEnergyBarHeight(60)
      assert.are.equal(60, configuration.GetEnergyBarHeight())
    end)
  end)

  describe("frame position persistence", function()
    before_each(function()
      -- the freshly dofiled PulseConfiguration is empty; the frames table is created by the merge
      configuration.SetupConfiguration()
    end)

    it("returns the stored point / posX / posY after a save", function()
      configuration.SaveUserPlacedFramePosition("P_EnergyBar", "CENTER", nil, "CENTER", 12.5, -30.25)

      local stored = configuration.GetUserPlacedFramePosition("P_EnergyBar")

      assert.are.equal("CENTER", stored.point)
      assert.are.equal(12.5, stored.posX)
      assert.are.equal(-30.25, stored.posY)
    end)

    it("returns nil for an unknown frame", function()
      assert.is_nil(configuration.GetUserPlacedFramePosition("DoesNotExist"))
    end)
  end)

  it("does not bleed PulseConfiguration between it() blocks", function()
    -- the before_each dofile re-creates PulseConfiguration as an empty table; if a previous
    -- block's width/frames leaked, these fresh-state assertions would fail
    assert.is_nil(PulseConfiguration.energyBarWidth)
    assert.is_nil(PulseConfiguration.frames)
  end)
end)
