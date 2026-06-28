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
  Tests for the Pulse profile envelope, export/import and named-profile store
  (code/Profile.lua).
]]--

-- busted extends `assert` with .same / .equal / etc. at runtime; luacheck cannot verify those
-- fields statically. Suppress warning 143 (accessing undefined field of a global variable).
-- luacheck: globals describe it before_each
-- luacheck: ignore 143

describe("Profile", function()
  local profile = rgp.profile

  before_each(function()
    PulseConfiguration.profiles = {}
    PulseConfiguration.lockEnergyBar = false
    PulseConfiguration.energyBarWidth = 120
    PulseConfiguration.energyBarHeight = 30
    PulseConfiguration.frames = {}
  end)

  it("exports and imports a snapshot round-trip", function()
    local payload = profile.BuildSnapshot()
    local envelope, err = profile.ImportString(profile.ExportString(payload, "MyProfile"))

    assert.is_nil(err)
    assert.is_table(envelope)
    assert.are.equal("Pulse", envelope.addon)
    assert.are.equal("MyProfile", envelope.name)
    assert.are.same(payload, envelope.payload)
  end)

  it("tolerates whitespace wrapped around the import string", function()
    local exported = profile.ExportString(profile.BuildSnapshot(), "P")

    assert.is_table(profile.ImportString("  \n" .. exported .. "\n  "))
  end)

  it("rejects an empty string", function()
    local _, err = profile.ImportString("")
    assert.are.equal("profile_error_empty", err)
  end)

  it("rejects an unrecognized string", function()
    local _, err = profile.ImportString("not-a-pulse-string")
    assert.are.equal("profile_error_invalid", err)
  end)

  it("rejects an envelope from a different addon", function()
    local serialized = rgp.serializer.Serialize({ addon = "GearMenu", schemaVersion = 1, payload = {} })
    local _, err = profile.ImportString("Pulse1:" .. rgp.encoder.Encode(serialized))

    assert.are.equal("profile_error_wrong_addon", err)
  end)

  it("rejects a newer schema version", function()
    local serialized = rgp.serializer.Serialize({ addon = "Pulse", schemaVersion = 999, payload = {} })
    local _, err = profile.ImportString("Pulse1:" .. rgp.encoder.Encode(serialized))

    assert.are.equal("profile_error_version", err)
  end)

  it("rejects a corrupt string via the checksum", function()
    local exported = profile.ExportString(profile.BuildSnapshot(), "P")
    local prefixLength = #("Pulse1:")
    local bodyFirst = string.sub(exported, prefixLength + 1, prefixLength + 1)
    local replacement = bodyFirst == "A" and "B" or "A"
    local corrupted = string.sub(exported, 1, prefixLength) .. replacement .. string.sub(exported, prefixLength + 2)

    local _, err = profile.ImportString(corrupted)

    assert.are.equal("profile_error_checksum", err)
  end)

  it("applies a snapshot onto the live configuration", function()
    profile.ApplySnapshot({ lockEnergyBar = true, energyBarWidth = 250, energyBarHeight = 50, frames = {} })

    assert.is_true(PulseConfiguration.lockEnergyBar)
    assert.are.equal(250, PulseConfiguration.energyBarWidth)
    assert.are.equal(50, PulseConfiguration.energyBarHeight)
  end)

  it("does not share table references between profile and live config", function()
    PulseConfiguration.frames = { P_EnergyBar = { posX = 1 } }
    profile.SaveProfile("snap", profile.BuildSnapshot())
    -- mutating the live config must not bleed into the stored profile
    PulseConfiguration.frames.P_EnergyBar.posX = 999

    assert.are.equal(1, profile.GetProfile("snap").frames.P_EnergyBar.posX)
  end)

  it("stores, lists, renames and deletes named profiles", function()
    profile.SaveProfile("alpha", profile.BuildSnapshot())
    profile.SaveProfile("beta", profile.BuildSnapshot())
    assert.are.same({ "alpha", "beta" }, profile.ListProfiles())
    assert.is_true(profile.ProfileExists("alpha"))

    assert.is_true(profile.RenameProfile("alpha", "gamma"))
    assert.are.same({ "beta", "gamma" }, profile.ListProfiles())

    profile.DeleteProfile("beta")
    assert.are.same({ "gamma" }, profile.ListProfiles())
  end)

  it("imports a payload as data without executing it", function()
    local serialized = rgp.serializer.Serialize({
      addon = "Pulse",
      schemaVersion = 1,
      payload = { lockEnergyBar = true }
    })
    local envelope = profile.ImportString("Pulse1:" .. rgp.encoder.Encode(serialized))

    assert.is_table(envelope)
    assert.is_true(envelope.payload.lockEnergyBar)
  end)
end)
