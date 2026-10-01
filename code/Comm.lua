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

-- luacheck: globals C_ChatInfo C_AddOns C_Timer UnitName IsInGuild IsInGroup IsInRaid GetTime

local mod = rgp
local me = {}
mod.comm = me

me.tag = "Comm"

--[[
  Version broadcast and update notice. Every client broadcasts its running version
  over the addon message channel on login and roster edges; when a strictly newer
  version is seen from another player the localized update notice is shown once.
  Uses only the native per-prefix throttle (10 message burst, +1/sec refill) - no
  third-party comm library.
]]--

-- forward declarations for local functions
local IsSelfSent
local NormalizeVersion
local ShouldNotify

--[[
  Minimum time in seconds between two version broadcasts. GROUP_ROSTER_UPDATE fires
  in bursts while a group forms; the cooldown keeps the broadcasts well within the
  native throttle budget
]]--
local BROADCAST_COOLDOWN = 10

--[[
  The channels BroadcastVersion sends on. A version arriving on any other channel (a
  WHISPER from an arbitrary player) is not a broadcast and is ignored
]]--
local BROADCAST_CHANNELS = {
  ["GUILD"] = true,
  ["RAID"] = true,
  ["PARTY"] = true,
  ["INSTANCE_CHAT"] = true
}

-- upper bound for a received version string - "v999.999.999" is 12 characters
local MAX_VERSION_LENGTH = 16

-- time of the last version broadcast
local lastBroadcastTime = 0
-- whether a trailing broadcast is scheduled for the end of the cooldown
local broadcastPending = false
-- whether the scheduled trailing broadcast includes the guild channel
local pendingIncludesGuild = false
-- whether the update notice was already shown this session
local notifiedThisSession = false

--[[
  Register the addon message prefix so the client delivers version broadcasts from
  other players via CHAT_MSG_ADDON
]]--
function me.Initialize()
  C_ChatInfo.RegisterAddonMessagePrefix(RGP_CONSTANTS.ADDON_MESSAGE_PREFIX)
  mod.logger.LogDebug(me.tag,
    "Registered addon message prefix " .. RGP_CONSTANTS.ADDON_MESSAGE_PREFIX)
end

--[[
  Broadcast the running addon version to group members, and to the guild when
  includeGuild is set. Invoked on roster edges only (PLAYER_ENTERING_WORLD and
  GROUP_ROSTER_UPDATE), never in a loop, so the native throttle is never exhausted.
  The guild roster does not change with the group, so only the login / reload edge
  asks for the guild - a group change would otherwise repeat the guild message.

  A call inside the cooldown is not dropped: one trailing broadcast is scheduled for
  the end of the cooldown, so a player who joins right after another roster change
  still receives the version. Calls while it is pending fold into it.

  @param {boolean} includeGuild
    true to also send on the guild channel
]]--
function me.BroadcastVersion(includeGuild)
  local version = C_AddOns.GetAddOnMetadata(RGP_CONSTANTS.ADDON_NAME, "Version")

  if version == nil then return end

  local remaining = BROADCAST_COOLDOWN - (GetTime() - lastBroadcastTime)

  if remaining > 0 then
    pendingIncludesGuild = pendingIncludesGuild or includeGuild == true

    if broadcastPending then return end

    mod.logger.LogDebug(me.tag, "Deferring version broadcast - cooldown active")
    broadcastPending = true
    C_Timer.After(remaining, function()
      local withGuild = pendingIncludesGuild

      broadcastPending = false
      pendingIncludesGuild = false
      me.BroadcastVersion(withGuild)
    end)

    return
  end

  lastBroadcastTime = GetTime()

  if includeGuild and IsInGuild() then
    C_ChatInfo.SendAddonMessage(RGP_CONSTANTS.ADDON_MESSAGE_PREFIX, version, "GUILD")
  end

  if IsInRaid() then
    C_ChatInfo.SendAddonMessage(RGP_CONSTANTS.ADDON_MESSAGE_PREFIX, version, "RAID")
  elseif IsInGroup() then
    C_ChatInfo.SendAddonMessage(RGP_CONSTANTS.ADDON_MESSAGE_PREFIX, version, "PARTY")
  end
end

--[[
  Handle an incoming addon message. Foreign prefixes, messages outside the broadcast
  channels and self-sent messages are dropped. The message is untrusted input from
  another player: only a well-formed version is accepted, and only its normalized form
  is persisted and printed, so sender-controlled text never reaches the saved
  variables or the chat. A strictly newer version shows the localized update notice
  once per session and persists the announced version so relogs are not re-nagged.

  @param {string} prefix
  @param {string} message
    the version string of the sending player
  @param {string} channel
    the channel the message arrived on
  @param {string} sender
    sender name, realm-qualified for cross-realm players ("Name-Realm")
]]--
function me.OnChatMsgAddon(prefix, message, channel, sender)
  if prefix ~= RGP_CONSTANTS.ADDON_MESSAGE_PREFIX then return end
  if not BROADCAST_CHANNELS[channel] then return end
  if IsSelfSent(sender) then return end

  local version = NormalizeVersion(message)

  if version == nil or not ShouldNotify(version) then return end

  notifiedThisSession = true
  PulseConfiguration.lastNotifiedVersion = version
  mod.logger.PrintUserMessage(string.format(rgp.L["update_available"], version))
end

--[[
  Reduce a received version to its canonical "vMAJOR.MINOR.PATCH" form. Anything else -
  a non-string, an oversized message, trailing or leading text - is rejected.

  @param {string} message
  @return {string | nil}
    the normalized version, or nil if the message is not a well-formed version
]]--
NormalizeVersion = function(message)
  if type(message) ~= "string" or #message > MAX_VERSION_LENGTH then return nil end

  local major, minor, patch = string.match(message, "^v?(%d+)%.(%d+)%.(%d+)$")

  if major == nil then return nil end

  return string.format("v%d.%d.%d", tonumber(major), tonumber(minor), tonumber(patch))
end

--[[
  Whether an addon message was sent by the player themself. Defense-in-depth -
  the player's own version is never strictly newer than itself.

  @param {string} sender
    sender name, possibly realm-qualified ("Name-Realm")
  @return {boolean}
    true - if the sender is the player
    false - otherwise
]]--
IsSelfSent = function(sender)
  return string.match(sender or "", "^([^-]+)") == UnitName("player")
end

--[[
  Whether a received version warrants the update notice: strictly newer than the
  running version, not yet announced this session and newer than the persisted
  lastNotifiedVersion.

  @param {string} receivedVersion
  @return {boolean}
    true - if the update notice should be shown
    false - otherwise
]]--
ShouldNotify = function(receivedVersion)
  if notifiedThisSession then return false end

  local version = C_AddOns.GetAddOnMetadata(RGP_CONSTANTS.ADDON_NAME, "Version")

  if not mod.configuration.IsVersionBefore(version, receivedVersion) then return false end

  --[[
    An empty lastNotifiedVersion means nothing was announced yet. IsVersionBefore
    treats an unparseable version as "not before", which would otherwise suppress
    the very first notice
  ]]--
  local lastNotifiedVersion = PulseConfiguration.lastNotifiedVersion

  if lastNotifiedVersion ~= nil and lastNotifiedVersion ~= ""
      and not mod.configuration.IsVersionBefore(lastNotifiedVersion, receivedVersion) then
    return false
  end

  return true
end
