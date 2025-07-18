--[[
  MIT License

  Copyright (c) 2025 Michael Wiesendanger

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

-- luacheck: globals GetAddOnMetadata

rgp = rgp or {}
local me = rgp

me.tag = "Core"

-- forward declarations for local functions
local RegisterEvents
local Initialize
local ShowWelcomeMessage

--[[
  Addon load

  @param {table} self
]]--
function me.OnLoad(self)
  RegisterEvents(self)
end

--[[
  Register addon events
]]--
RegisterEvents = function(self)
  -- register to player login event also fires on /reload
  self:RegisterEvent("PLAYER_LOGIN")
  -- Fired when a unit's current power
  self:RegisterEvent("UNIT_POWER_UPDATE")
end

--[[
  MainFrame OnEvent handler

  @param {string} event
  @param {table} vararg
]]--
function me.OnEvent(event, ...)
  if event == "PLAYER_LOGIN" then
    me.logger.LogEvent(me.tag, "PLAYER_LOGIN")
    Initialize()
  elseif event == "UNIT_POWER_UPDATE" then
    me.logger.LogEvent(me.tag, "UNIT_POWER_UPDATE")
    local unitTarget, powerType = ...

    if unitTarget == RGP_CONSTANTS.UNIT_ID_PLAYER and powerType == RGP_CONSTANTS.POWERTYPE_ENERGY[1] then
      me.ticker.StartTickerEnergy()
      me.energyBar.ShowEnergyBarFrame()
    end
  end
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
    GetAddOnMetadata(RGP_CONSTANTS.ADDON_NAME, "Version"))
  )
end
