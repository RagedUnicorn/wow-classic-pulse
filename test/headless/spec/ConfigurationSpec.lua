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

  SetupConfiguration is the nil-defaulting routine that runs on every load/upgrade. The module
  owns the PulseConfiguration global and rgp.configuration; both are re-created by re-dofiling
  code/Configuration.lua in before_each (per the bootstrap module-state convention). SetAddonVersion
  reads C_AddOns.GetAddOnMetadata, stubbed via WowStubs to return a fixed version string (and a
  Title, which the logger prints). SetupConfiguration logs through rgp.logger, whose PrintLogMessage
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
    -- re-run code/Configuration.lua to get a fresh PulseConfiguration with documented defaults
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
    it("fills every nil field with its documented default and stamps addonVersion", function()
      PulseConfiguration.lockEnergyBar = nil
      PulseConfiguration.frames = nil
      PulseConfiguration.profiles = nil
      PulseConfiguration.energyBarWidth = nil
      PulseConfiguration.energyBarHeight = nil
      PulseConfiguration.addonVersion = nil

      configuration.SetupConfiguration()

      assert.is_true(PulseConfiguration.lockEnergyBar)
      assert.are.same({}, PulseConfiguration.frames)
      assert.are.same({}, PulseConfiguration.profiles)
      assert.are.equal(RGP_CONSTANTS.ELEMENT_ENERGY_BAR_WIDTH, PulseConfiguration.energyBarWidth)
      assert.are.equal(RGP_CONSTANTS.ELEMENT_ENERGY_BAR_HEIGHT, PulseConfiguration.energyBarHeight)
      assert.are.equal("1.2.3", PulseConfiguration.addonVersion)
    end)

    it("does not overwrite values that are already set", function()
      PulseConfiguration.lockEnergyBar = false
      PulseConfiguration.energyBarWidth = 200
      PulseConfiguration.energyBarHeight = 45
      PulseConfiguration.frames = { P_EnergyBar = { point = "CENTER" } }

      configuration.SetupConfiguration()

      assert.is_false(PulseConfiguration.lockEnergyBar)
      assert.are.equal(200, PulseConfiguration.energyBarWidth)
      assert.are.equal(45, PulseConfiguration.energyBarHeight)
      assert.are.same({ P_EnergyBar = { point = "CENTER" } }, PulseConfiguration.frames)
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
    -- if a previous block's width/frame leaked, these fresh-default assertions would fail
    assert.is_nil(PulseConfiguration.energyBarWidth)
    assert.are.same({}, PulseConfiguration.frames)
  end)
end)
