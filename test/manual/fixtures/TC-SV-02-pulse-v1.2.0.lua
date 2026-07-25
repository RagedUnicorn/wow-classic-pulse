--[[
  SavedVariables fixture for TC-SV-02 - upgrade from the previous release.

  This is the v1.2.0 configuration schema: five keys, no profiles, no grid
  settings, no update notifier bookkeeping. It was taken from a real client
  produced file and enriched with non-default values so that any field the
  upgrade path drops or resets is immediately visible.

  Copy this file to

    WTF/Account/<ACCOUNT>/<Realm>/<Character>/SavedVariables/Pulse.lua

  while the client is fully closed. Comments are stripped the next time WoW
  rewrites the file - that is expected, this is a source fixture, not output.

  Do not regenerate this file against a newer build. When v1.3.0 ships, add a
  sibling fixture for the v1.3.0 schema instead and keep this one as is.
]]--

PulseConfiguration = {
["addonVersion"] = "v1.2.0",
["lockEnergyBar"] = true,
["energyBarWidth"] = 200,
["energyBarHeight"] = 45,
["frames"] = {
["P_EnergyBar"] = {
["relativeTo"] = "UIParent",
["relativePoint"] = "BOTTOMLEFT",
["point"] = "TOPLEFT",
["posX"] = 620.0000305175781,
["posY"] = 350,
},
},
}
