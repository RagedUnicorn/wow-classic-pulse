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
  Headless test bootstrap (busted helper, wired via the `helper` key in `.busted`).

  Pulse modules have no package system: each file does `local mod = rgp; local me = {};
  mod.<name> = me` and is executed in `Pulse.toc` load order. This bootstrap reproduces the
  minimal slice of that environment so the pure / lightly-stubbed modules load with no WoW client
  present:

    1. the `rgp` namespace table (normally created by code/Core.lua),
    2. RGP_ENVIRONMENT, shimmed directly here (mirrors the *development* code/Environment.lua) so
       tests do not depend on `mvn generate-resources` or the build-generated file,
    3. the pure modules Constants.lua, Event.lua and Logger.lua, dofile'd in TOC dependency order,
    4. a minimal PulseConfiguration stand-in plus a no-op rgp.configuration, and the serialization
       modules (Serializer, Encoder, Profile) the existing specs exercise.

  It also prepends test/headless to package.path so specs can `require("WowStubs")` for the opt-in
  WoW-global stub registry.

  Module-state reset convention for specs: because modules load via dofile (not require /
  package.loaded), re-dofile a module inside before_each to get a fresh module table -- e.g.
  `dofile("code/Profile.lua")` re-runs `mod.profile = {}`, clearing its file-local state.

  Expected cwd: addon repo root. Run from elsewhere and the dofile()s will fail.
]]--

-- luacheck: globals rgp RGP_ENVIRONMENT PulseConfiguration

-- allow specs to require the opt-in WoW-global stub registry as `require("WowStubs")`
package.path = "./test/headless/?.lua;" .. package.path

-- the addon namespace, normally created by code/Core.lua
rgp = {}

-- shimmed environment, mirroring the development build of code/Environment.lua
RGP_ENVIRONMENT = {
  ADDON_IDENTIFIER = "com.ragedunicorn.wow.classic.pulse-addon",
  LOG_LEVEL = 4,
  LOG_EVENT = true,
  DEBUG = true
}

-- load the pure modules in Pulse.toc dependency order
dofile("code/Constants.lua") -- defines RGP_CONSTANTS
dofile("code/Event.lua")     -- defines rgp.event (the centralized event bus)
dofile("code/Logger.lua")    -- defines rgp.logger (reads RGP_ENVIRONMENT at load time)

-- a minimal stand-in for the per-character saved variables
PulseConfiguration = {
  addonVersion = "1.2.0",
  lockEnergyBar = false,
  energyBarWidth = 120,
  energyBarHeight = 30,
  frames = {},
  profiles = {}
}

-- Profile.ApplySnapshot calls back into the configuration module to backfill defaults and
-- Profile.BuildDefaultSnapshot reads the shipped defaults from it; a no-op SetupConfiguration
-- plus a GetDefaults mirroring the DEFAULTS table of code/Configuration.lua is enough for the
-- headless tests (ConfigurationSpec exercises the real module by re-dofiling it)
rgp.configuration = {
  SetupConfiguration = function() end,
  GetDefaults = function()
    return {
      lockEnergyBar = false,
      energyBarWidth = RGP_CONSTANTS.ELEMENT_ENERGY_BAR_WIDTH,
      energyBarHeight = RGP_CONSTANTS.ELEMENT_ENERGY_BAR_HEIGHT,
      frames = {},
      profiles = {},
      lastNotifiedVersion = ""
    }
  end
}

-- load the serialization modules under test (dependency order)
dofile("code/Serializer.lua")
dofile("code/Encoder.lua")
dofile("code/Profile.lua")
