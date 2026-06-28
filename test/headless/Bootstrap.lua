--[[
  Headless busted bootstrap.

  Stubs the handful of WoW globals the pure-Lua modules under test reach for,
  then dofile()s the production files in dependency order. Run from the AddOn
  repo root only (the busted Docker image mounts it at /workspace) - the
  dofile() paths are relative to that root.
]]--

-- the shared addon namespace
rgp = rgp or {}

-- only ADDON_NAME is referenced by the modules under test
RGP_CONSTANTS = { ADDON_NAME = "Pulse" }

-- a minimal stand-in for the per-character saved variables
PulseConfiguration = {
  addonVersion = "1.2.0",
  lockEnergyBar = false,
  energyBarWidth = 120,
  energyBarHeight = 30,
  frames = {},
  profiles = {}
}

-- Profile.ApplySnapshot calls back into the configuration module to backfill
-- defaults; a no-op stub is enough for the headless tests
rgp.configuration = {
  SetupConfiguration = function() end
}

-- load the production modules under test (dependency order)
dofile("code/Serializer.lua")
dofile("code/Encoder.lua")
dofile("code/Profile.lua")
