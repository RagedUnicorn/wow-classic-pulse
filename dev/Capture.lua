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

--[[
  Development-only media capture. Loaded by the development .toc only - it must never
  ship in a release. Walks the generated RGP_SHOTS manifest, sets the UI up for each
  shot, takes a screenshot and records the target frame's pixel rect so the
  post-process script can crop exactly instead of by eye.

  Registers its own /rgpshot slash command rather than extending code/Cmd.lua, so no
  production file is touched by a dev-only tool.

  See the wow-media-capture skill for the full pipeline.
]]--

-- luacheck: globals C_Timer Screenshot SetCVar GetPhysicalScreenSize InCombatLockdown
-- luacheck: globals Settings SettingsPanel SlashCmdList SLASH_RGPSHOT1 CreateFrame
-- luacheck: globals UIParent PulseShotLog RGP_SHOTS time

local mod = rgp
local me = {}
mod.capture = me

me.tag = "Capture"

--[[
  Delay between setting the UI up and taking the screenshot. The frames need a moment
  to lay out - measuring too early yields a rect for the previous layout.
]]--
local SETTLE_DELAY = 0.5
--[[
  Delay before the UI chrome is restored. Must outlast SETTLE_DELAY so the chrome is
  still hidden when the screenshot is actually taken.
]]--
local RESTORE_DELAY = 1.0
--[[
  Spacing between shots in a `shot all` run.
]]--
local BATCH_INTERVAL = 2.5

--[[
  Default UI elements hidden for a clean capture. Guarded by existence - the set
  differs between Classic Era and TBC Anniversary.
]]--
local CHROME = {
  "ChatFrame1",
  "ChatFrame1Tab",
  "ChatFrame1ButtonFrame",
  "ChatFrame1EditBox",
  "GeneralDockManager",
  "MinimapCluster",
  "MainMenuBar",
  "MultiBarBottomLeft",
  "MultiBarBottomRight",
  "MultiBarLeft",
  "MultiBarRight",
  "PlayerFrame",
  "TargetFrame",
  "BuffFrame",
  "TicketStatusFrame"
}

-- frames hidden by the current shot, restored afterwards
local hidden = {}
-- cursor for the keybind-safe `shot next` driver
local cursor = 1

-- forward declarations
local FindShot
local RunSetup
local HideChrome
local HideFrames
local RestoreChrome
local MeasureFrame
local MeasureShotRect
local RecordShot
local TakeShot
local HandleSlashCommand

--[[
  Register the dev-only slash command.
]]--
function me.SetupSlashCmdList()
  SLASH_RGPSHOT1 = "/rgpshot"

  SlashCmdList["RGPSHOT"] = HandleSlashCommand
end

--[[
  Setup verbs referenced by the manifest's capture.setup array. Keep this vocabulary
  small - add a verb only when a shot genuinely needs it.
]]--
local setupVerbs = {
  --[[
    Open a Settings subcategory. Settings.OpenToCategory requires the numeric category
    id - passing a name errors ("outside of expected range"). The AddOn exposes its ids
    via mod.addonConfiguration.GetCategoryId(key).
  ]]--
  ["openCategory"] = function(key)
    local id = mod.addonConfiguration.GetCategoryId(key)

    if id == nil then
      mod.logger.PrintUserError("Unknown category key: " .. tostring(key))
      return
    end

    Settings.OpenToCategory(id)
  end,

  ["closeSettings"] = function()
    if SettingsPanel ~= nil then
      SettingsPanel:Hide()
    end
  end,

  ["showFrame"] = function(name)
    local frame = _G[name]

    if frame ~= nil then
      frame:Show()
    end
  end,

  --[[
    Force the Pulse energyBar visible - and sweeping - for the duration of the shot via
    the same preview path the options panel uses (mod.energyBar.ShowPreview).
    Without it the bar stays Hidden until the first energy tick, so an
    energy_bar shot on a fresh login or a non-energy class captures bare terrain. Starting
    the ticker also gives the bar a real sweep position and energy number at capture time.
    No paired teardown is needed - a capture is always followed by a /reload.
  ]]--
  ["previewEnergyBar"] = function()
    mod.energyBar.ShowPreview()
  end
}

--[[
  @param {string} name

  @return {table}, {number}
    The manifest entry and its index, or nil
]]--
FindShot = function(name)
  for i = 1, #RGP_SHOTS do
    if RGP_SHOTS[i].name == name or RGP_SHOTS[i].shot == name then
      return RGP_SHOTS[i], i
    end
  end

  return nil, nil
end

--[[
  @param {table} entry
]]--
RunSetup = function(entry)
  for _, step in ipairs(entry.setup) do
    local verb, argument = string.match(step, "^(%w+):?(.*)$")
    local handler = setupVerbs[verb]

    if handler == nil then
      mod.logger.PrintUserError("Unknown setup verb: " .. tostring(verb))
    else
      handler(argument)
    end
  end
end

--[[
  Hide the default chrome for a clean capture. Frames named in keepFrames (the shot's
  capture.includeFrames) are spared so a shot can deliberately keep, e.g., the PlayerFrame
  next to the energy bar.

  @param {table | nil} keepFrames
    Array of frame names to leave visible
]]--
HideChrome = function(keepFrames)
  local keep = {}

  if keepFrames ~= nil then
    for _, name in ipairs(keepFrames) do
      keep[name] = true
    end
  end

  for _, name in ipairs(CHROME) do
    if not keep[name] then
      local frame = _G[name]

      if frame ~= nil and frame.IsShown ~= nil and frame:IsShown() then
        frame:Hide()
        table.insert(hidden, frame)
      end
    end
  end
end

RestoreChrome = function()
  for _, frame in ipairs(hidden) do
    frame:Show()
  end

  hidden = {}
end

--[[
  Hide specific frames named by the shot's capture.hideFrames, right before the screenshot
  and restored afterwards (queued onto the same `hidden` list as the chrome). Used to
  suppress a frame that a setup step forces visible - e.g. the energy-bar size preview that
  opening the Options panel triggers (PLI-0032) would otherwise ghost through the panel.

  @param {table | nil} names
    Array of frame names to hide
]]--
HideFrames = function(names)
  if names == nil then return end

  for _, name in ipairs(names) do
    local frame = _G[name]

    if frame ~= nil and frame.IsShown ~= nil and frame:IsShown() then
      frame:Hide()
      table.insert(hidden, frame)
    end
  end
end

--[[
  Convert a frame's UI coordinates to screenshot pixel coordinates. Two conversions are
  needed:

    1. WoW UI coordinates live in a virtual space that is a fixed 768 units tall at scale
       1.0 (UIParent:GetHeight() * UIParent:GetEffectiveScale() == 768), independent of
       the render resolution. A frame's GetLeft/GetTop/GetWidth/GetHeight are in that
       space, so a shot at 5065x2032 needs UI units mapped up to real pixels via
       screenHeight / 768. Omitting this factor is the classic bug - crops come out
       ~2.6x too small and mispositioned.
    2. The UI origin is bottom-left while the screenshot's is top-left, so the y edge is
       flipped against screenHeight.

  @param {table} frame

  @return {number}, {number}, {number}, {number}, {number}, {number}
    x, y, width, height, screenWidth, screenHeight
]]--
MeasureFrame = function(frame)
  local screenWidth, screenHeight = GetPhysicalScreenSize()

  -- referenceHeight is 768; derived live rather than hardcoded so it survives any future
  -- change to WoW's virtual UI height
  local referenceHeight = UIParent:GetHeight() * UIParent:GetEffectiveScale()
  local uiToPixel = frame:GetEffectiveScale() * (screenHeight / referenceHeight)

  local x = frame:GetLeft() * uiToPixel
  local y = screenHeight - (frame:GetTop() * uiToPixel)
  local width = frame:GetWidth() * uiToPixel
  local height = frame:GetHeight() * uiToPixel

  return x, y, width, height, screenWidth, screenHeight
end

--[[
  Compute the crop rect for a shot: the primary frame's pixel rect, expanded to the union
  of any capture.includeFrames rects. This lets a shot capture a group - e.g. the energy
  bar together with the PlayerFrame - instead of a single frame. Include frames that are
  missing, hidden or unpositioned are skipped so the crop degrades to the primary frame.

  @param {table} entry
  @param {table} frame
    The primary (already validated) frame

  @return {number}, {number}, {number}, {number}, {number}, {number}
    x, y, width, height, screenWidth, screenHeight
]]--
MeasureShotRect = function(entry, frame)
  local x, y, width, height, screenWidth, screenHeight = MeasureFrame(frame)
  local left, top, right, bottom = x, y, x + width, y + height

  if entry.includeFrames ~= nil then
    for _, name in ipairs(entry.includeFrames) do
      local extra = _G[name]

      if extra ~= nil and extra.GetLeft ~= nil and extra:GetLeft() ~= nil and extra:IsShown() then
        local ex, ey, ew, eh = MeasureFrame(extra)

        left = math.min(left, ex)
        top = math.min(top, ey)
        right = math.max(right, ex + ew)
        bottom = math.max(bottom, ey + eh)
      end
    end
  end

  return left, top, right - left, bottom - top, screenWidth, screenHeight
end

--[[
  Append a shot record to the SavedVariable. Written as a JSON string so the
  post-process script needs no Lua table parser.

  @param {table} entry
  @param {table} frame
]]--
RecordShot = function(entry, frame)
  if PulseShotLog == nil then
    PulseShotLog = {}
  end

  local x, y, width, height, screenWidth, screenHeight = MeasureShotRect(entry, frame)

  table.insert(PulseShotLog, string.format(
    '{"name":"%s","x":%d,"y":%d,"w":%d,"h":%d,"padding":%d,'
      .. '"uiScale":%.4f,"screenW":%d,"screenH":%d,"ts":%d}',
    entry.name,
    math.floor(x),
    math.floor(y),
    math.floor(width),
    math.floor(height),
    entry.padding,
    frame:GetEffectiveScale(),
    screenWidth,
    screenHeight,
    time()
  ))
end

--[[
  @param {table} entry
]]--
TakeShot = function(entry)
  if InCombatLockdown() then
    mod.logger.PrintUserError("Refusing to capture in combat - hiding protected frames would taint the UI")
    return
  end

  RunSetup(entry)

  C_Timer.After(SETTLE_DELAY, function()
    local frame = _G[entry.frame]

    if frame == nil then
      mod.logger.PrintUserError("Frame not found: " .. entry.frame .. " (is it shown?)")
      return
    end

    if frame:GetLeft() == nil then
      mod.logger.PrintUserError("Frame has no position: " .. entry.frame .. " (it is probably hidden)")
      return
    end

    if entry.hideChrome then
      HideChrome(entry.includeFrames)
    end

    HideFrames(entry.hideFrames)

    RecordShot(entry, frame)
    Screenshot()

    print("|cFF00FFB0Pulse:|r captured " .. entry.name)
  end)

  C_Timer.After(RESTORE_DELAY, RestoreChrome)
end

--[[
  Capture a single shot by name.

  @param {string} name
]]--
function me.Shot(name)
  local entry = FindShot(name)

  if entry == nil then
    mod.logger.PrintUserError("Unknown shot: " .. tostring(name) .. " - try /rgpshot list")
    return
  end

  TakeShot(entry)
end

--[[
  Capture every shot in the manifest, spaced far enough apart that each one settles.
  Requires Screenshot() to work from a timer callback - if it does not, use
  me.Next() bound to a key instead.
]]--
function me.ShotAll()
  me.Clear()

  for i = 1, #RGP_SHOTS do
    C_Timer.After(BATCH_INTERVAL * (i - 1), function()
      TakeShot(RGP_SHOTS[i])
    end)
  end

  print("|cFF00FFB0Pulse:|r capturing " .. #RGP_SHOTS .. " shot(s), /reload when done")
end

--[[
  Keybind-safe driver: capture the shot at the cursor and advance. Use this when
  Screenshot() turns out to require a hardware event.
]]--
function me.Next()
  if cursor > #RGP_SHOTS then
    print("|cFF00FFB0Pulse:|r all shots captured - /reload to flush the log")
    return
  end

  local entry = RGP_SHOTS[cursor]
  cursor = cursor + 1

  print("|cFF00FFB0Pulse:|r shot " .. (cursor - 1) .. "/" .. #RGP_SHOTS .. " - " .. entry.name)
  TakeShot(entry)
end

--[[
  Reset the shot log and the cursor. The post-process script pairs log records with the
  newest screenshot files, so a stale log breaks the pairing.
]]--
function me.Clear()
  PulseShotLog = {}
  cursor = 1
end

--[[
  Print the manifest.
]]--
function me.List()
  print("|cFF00FFB0Pulse:|r " .. #RGP_SHOTS .. " shot(s)")

  for i = 1, #RGP_SHOTS do
    local entry = RGP_SHOTS[i]
    print("  |cFFFFC300" .. entry.name .. "|r - " .. entry.shows .. " (" .. entry.frame .. ")")
  end
end

--[[
  @param {string} msg
]]--
HandleSlashCommand = function(msg)
  local args = {}

  for arg in string.gmatch(msg, "%S+") do
    table.insert(args, arg)
  end

  if args[1] == nil or args[1] == "help" then
    print("|cFF00FFB0Pulse:|r media capture (development only)")
    print("  |cFFFFC300list|r - show the shot manifest")
    print("  |cFFFFC300all|r - capture every shot")
    print("  |cFFFFC300next|r - capture the next shot (bind this if `all` does not work)")
    print("  |cFFFFC300clear|r - reset the shot log")
    print("  |cFFFFC300<name>|r - capture a single shot")
  elseif args[1] == "list" then
    me.List()
  elseif args[1] == "all" then
    me.ShotAll()
  elseif args[1] == "next" then
    me.Next()
  elseif args[1] == "clear" then
    me.Clear()
    print("|cFF00FFB0Pulse:|r shot log cleared")
  else
    me.Shot(args[1])
  end
end

--[[
  The dev module cannot hook into code/Core.lua's initialization without touching a
  production file, so it drives its own PLAYER_LOGIN setup.
]]--
local eventFrame = CreateFrame("Frame")

eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", function()
  --[[
    Screenshots default to JPEG, which is lossy on UI panels. PNG is the right format
    for media that ends up in a README.
  ]]--
  SetCVar("screenshotFormat", "png")
  me.SetupSlashCmdList()
end)
