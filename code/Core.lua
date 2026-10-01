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

-- luacheck: read globals C_AddOns geterrorhandler

rgp = rgp or {}
local me = rgp

me.tag = "Core"

-- forward declarations for local functions
local OnPlayerLogin
local OnUnitPowerUpdate
local OnEnteringWorld
local OnRosterChanged
local OnDisplaySizeChanged
local Initialize
local ShowWelcomeMessage

--[[
  Run the bootstrap sequence on login, then mark the event bus ready so gated
  handlers begin firing. PLAYER_LOGIN fires once per session, so a step of
  Initialize that raises must not keep the gate closed until the next reload - the
  error is logged and handed to the client's error handler (the script error frame,
  BugSack) and the gate opens regardless.
]]--
OnPlayerLogin = function()
  xpcall(Initialize, function(err)
    me.logger.LogError(me.tag, "Initialization failed: " .. tostring(err))

    return geterrorhandler()(err)
  end)

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
  Announce the version on PLAYER_ENTERING_WORLD. The guild is announced to only on
  login and reload - a loading screen changes no guild.

  @param {boolean} isInitialLogin
  @param {boolean} isReloadingUi
]]--
OnEnteringWorld = function(isInitialLogin, isReloadingUi)
  me.comm.BroadcastVersion(isInitialLogin == true or isReloadingUi == true)
end

--[[
  Announce the version on GROUP_ROSTER_UPDATE. A group change announces to the group
  only - the guild already got the version at login.
]]--
OnRosterChanged = function()
  me.comm.BroadcastVersion(false)
end

--[[
  Re-lay the alignment grid when the drawable area changes. Referenced through the module
  table at call time - gui/AlignmentGrid.lua is loaded after gui/Frame.xml runs OnLoad
]]--
OnDisplaySizeChanged = function()
  me.alignmentGrid.Refresh()
end

--[[
  Addon load

  @param {table} self
]]--
function me.OnLoad(self)
  -- register to player login event also fires on /reload
  me.event.Register("PLAYER_LOGIN", OnPlayerLogin)
  -- fired when a unit's current power changes; unit-filtered on the client so
  -- the handler never runs for other units' power changes. Gated because the
  -- handler touches the energy bar ui, which only exists after Initialize()
  me.event.Register(
    "UNIT_POWER_UPDATE",
    OnUnitPowerUpdate,
    { gated = true, unit = RGP_CONSTANTS.UNIT_ID_PLAYER }
  )
  me.event.Register("CHAT_MSG_ADDON", me.comm.OnChatMsgAddon, { gated = true })
  me.event.Register("PLAYER_ENTERING_WORLD", OnEnteringWorld, { gated = true })
  me.event.Register("GROUP_ROSTER_UPDATE", OnRosterChanged, { gated = true })
  -- the alignment grid spans the whole screen and has to be re-laid when that changes
  me.event.Register(
    { "DISPLAY_SIZE_CHANGED", "UI_SCALE_CHANGED" },
    OnDisplaySizeChanged,
    { gated = true }
  )

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
  -- guarantee the undeletable default profile exists (needs the defaults applied above)
  me.profile.EnsureDefaultProfile()
  -- setup addon configuration ui
  me.addonConfiguration.SetupAddonConfiguration()
  me.energyBar.BuildUi()
  -- register addon message prefix for the version broadcast
  me.comm.Initialize()

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
