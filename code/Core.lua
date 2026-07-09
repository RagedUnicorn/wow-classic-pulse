--[[
  MIT License

  Copyright (c) 2026 Michael Wiesendanger

  Permission is hereby granted, free of charge, to any person obtaining
  a copy of this software and associated documentation files (the
  "Software"), to deal in the Software without restriction, including
  without limitation the rights to use, copy, modify, merge, publish,
  distribute, sublicense, and/or sell copies of the Software, and to
  permit persons to whom the Software is furnished to do so, subject to
  the following conditions:

  The above copyright notice and this permission notice shall be
  included in all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]--

-- luacheck: globals C_AddOns

rgp = rgp or {}
local me = rgp

me.tag = "Core"

-- forward declarations for local functions
local OnPlayerLogin
local OnUnitPowerUpdate
local Initialize
local ShowWelcomeMessage

--[[
  Run the bootstrap sequence on login. Pulse registers no gated handlers, so
  SetReady only keeps the event bus api uniform across the addon family.
]]--
OnPlayerLogin = function()
  Initialize()
  me.event.SetReady()
end

--[[
  Start the energy ticker and show the energy bar when the player's energy
  changes.

  @param {string} unitTarget
  @param {string} powerType
]]--
OnUnitPowerUpdate = function(unitTarget, powerType)
  if unitTarget == RGP_CONSTANTS.UNIT_ID_PLAYER and powerType == RGP_CONSTANTS.POWERTYPE_ENERGY[1] then
    me.ticker.StartTickerEnergy()
    me.energyBar.ShowEnergyBarFrame()
  end
end

--[[
  Addon load

  @param {table} self
]]--
function me.OnLoad(self)
  -- register to player login event also fires on /reload
  me.event.Register("PLAYER_LOGIN", OnPlayerLogin)
  -- fired when a unit's current power changes
  me.event.Register("UNIT_POWER_UPDATE", OnUnitPowerUpdate)

  me.event.Setup(self)
end

--[[
  MainFrame OnEvent handler. Delegates to the event bus for dispatch.

  @param {string} event
  @param {vararg} ...
]]--
function me.OnEvent(event, ...)
  me.event.Dispatch(event, ...)
end

--[[
  Initialize addon
]]--
Initialize = function()
  me.logger.LogDebug(me.tag, "Initialize addon")
  -- setup slash commands
  me.cmd.SetupSlashCmdList()
  -- load addon variables
  me.configuration.SetupConfiguration()
  -- setup addon configuration ui
  me.addonConfiguration.SetupAddonConfiguration()
  -- setup ui
  me.energyBar.BuildUi()

  ShowWelcomeMessage()
end

--[[
  Show welcome message to user
]]--
ShowWelcomeMessage = function()
  print(
    string.format("|cFF00FFB0" .. RGP_CONSTANTS.ADDON_NAME .. rgp.L["help"],
    C_AddOns.GetAddOnMetadata(RGP_CONSTANTS.ADDON_NAME, "Version"))
  )
end
