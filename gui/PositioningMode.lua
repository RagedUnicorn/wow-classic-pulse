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
  Positioning mode - "I am placing the energy bar right now".

  Placing the bar used to depend on a pile of unrelated state lining up: the bar had to be
  unlocked, it had to already be visible (which it is not until the first energy tick), and
  the only thing that force-shows it was the options panel - a centered window that then
  covers the very bar being placed. This module replaces all of that with one deliberate
  mode the user enters and leaves.

  While active it closes the settings window, force-shows the bar, draws the alignment grid
  (when snapping is on), lets the bar be dragged even if it is locked, and puts a small hud
  with a Done button on screen. Leaving restores everything; the lock setting is never
  touched.
]]--

-- luacheck: globals CreateFrame UIParent STANDARD_TEXT_FONT SettingsPanel HideUIPanel UISpecialFrames
-- luacheck: globals InCombatLockdown

local mod = rgp
local me = {}

mod.positioningMode = me

me.tag = "PositioningMode"

local hudFrame
local isActive = false
--[[
  Whether the settings window was open when the mode was entered - i.e. whether the mode
  closed it on the way in. Only then does Done put the user back where they came from;
  entering from the slash command with no window open must not conjure one up on exit
]]--
local enteredFromSettings = false

-- forward declarations
local EnsureUi
local CreateHudFrame
local CloseSettingsWindow

--[[
  @return {boolean}
    true - while the user is placing the bar
    false - otherwise
]]--
function me.IsActive()
  return isActive
end

--[[
  Create the positioning hud on first use.

  Built lazily rather than at login: placing the bar is something a user does once and then
  never again for the life of the character, so a frame, a button and a backdrop should not
  be paid for by every session that never enters the mode
]]--
EnsureUi = function()
  if hudFrame ~= nil then return end

  hudFrame = CreateHudFrame()

  --[[
    Escape closes the hud, and its OnHide leaves the mode - so the usual "get me out of
    here" key works without a separate keybinding. UISpecialFrames holds frame names, which
    is why the hud is created with one. Inserted alongside the frame so the name can never
    be registered twice
  ]]--
  table.insert(UISpecialFrames, RGP_CONSTANTS.ELEMENT_POSITIONING_HUD_FRAME)
end

--[[
  Enter or leave the mode depending on where it currently is. Used by the slash command
]]--
function me.Toggle()
  if isActive then
    me.Exit()
  else
    me.Enter()
  end
end

--[[
  Start placing the bar
]]--
function me.Enter()
  if isActive then return end

  EnsureUi()

  mod.logger.LogInfo(me.tag, "Entering positioning mode")
  isActive = true
  enteredFromSettings = SettingsPanel ~= nil and SettingsPanel:IsShown()

  --[[
    Order matters. Closing the settings window fires the general panel's OnHide, which runs
    energyBar.HidePreview and can hide the bar again - so the window has to go away first
    and the bar be force-shown afterwards, never the other way around
  ]]--
  CloseSettingsWindow()
  mod.energyBar.ShowPreview()
  mod.alignmentGrid.Refresh()

  --[[
    Only promise the corner alignment when snapping is actually on - without it the bar
    lands wherever it is dropped and the grid is not even drawn
  ]]--
  if mod.configuration.IsEnergyBarGridSnapEnabled() then
    hudFrame.instruction:SetText(rgp.L["positioning_hud_instruction_snap"])
  else
    hudFrame.instruction:SetText(rgp.L["positioning_hud_instruction"])
  end

  hudFrame:Show()
end

--[[
  Stop placing the bar and restore the state it was in beforehand

  @param {boolean} returnToSettings
    Reopen the options the mode was entered from. Set by Done - finishing the job puts the
    user back where they started. Deliberately not set for Escape, where popping a window
    open would be the opposite of what the key is for
]]--
function me.Exit(returnToSettings)
  if not isActive then return end

  mod.logger.LogInfo(me.tag, "Leaving positioning mode")
  --[[
    Cleared first: hiding the hud fires its OnHide, which calls back in here - the guard
    above turns that second pass into a no-op
  ]]--
  isActive = false

  if hudFrame ~= nil then
    hudFrame:Hide()
  end

  mod.alignmentGrid.Refresh()
  --[[
    Before any reopen: this hands the forced bar visibility back, so the options panel can
    take out a fresh preview of its own when it comes up again
  ]]--
  mod.energyBar.HidePreview()

  if returnToSettings and enteredFromSettings then
    mod.addonConfiguration.OpenCategory("general")
  end

  enteredFromSettings = false
end

--[[
  Hide the Blizzard settings window so it stops covering the bar being placed.

  Routed through HideUIPanel rather than a direct Hide - that is what Blizzard's own close
  button ends up calling, and it keeps working should the settings window ever gain a
  UIPanelWindows entry. Note that SettingsPanel:Close() is deliberately not used: without
  its skip argument it falls through to ToggleGameMenu, which would pop the game menu open
  on top of the hud whenever the panel was reached from a slash command.

  HideUIPanel is protected, so in combat an insecure caller only earns a blocked-action
  message. The mode is still perfectly usable then - the window just stays open and can be
  closed by hand
]]--
CloseSettingsWindow = function()
  if SettingsPanel == nil or not SettingsPanel:IsShown() then return end
  if InCombatLockdown() then return end

  HideUIPanel(SettingsPanel)
end

--[[
  Build the hud: one line telling the user what to do plus a Done button. Anchored to the
  screen rather than to the energyBar so dragging the bar into a corner can never push the
  Done button out of reach

  @return {table}
]]--
CreateHudFrame = function()
  local frame = CreateFrame(
    "Frame",
    RGP_CONSTANTS.ELEMENT_POSITIONING_HUD_FRAME,
    UIParent,
    "BackdropTemplate"
  )
  frame:SetSize(
    RGP_CONSTANTS.ELEMENT_POSITIONING_HUD_WIDTH,
    RGP_CONSTANTS.ELEMENT_POSITIONING_HUD_HEIGHT
  )
  frame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, RGP_CONSTANTS.ELEMENT_POSITIONING_HUD_OFFSET_Y)
  --[[
    Above the ordinary ui (which sits on MEDIUM) but deliberately below DIALOG, so the game
    menu and any confirmation popup still render over the hud rather than under it
  ]]--
  frame:SetFrameStrata("HIGH")
  -- swallow clicks so aiming for the hud never reaches the world behind it
  frame:EnableMouse(true)
  mod.uiHelper.ApplyBorderBackdrop(frame)

  local instructionFontString = frame:CreateFontString(nil, "OVERLAY")
  instructionFontString:SetFont(STANDARD_TEXT_FONT, 13)
  mod.uiHelper.SetColor(instructionFontString, RGP_CONSTANTS.COLOR.BODY)
  instructionFontString:SetPoint("TOP", frame, "TOP", 0, -14)
  --[[
    A width is what makes a font string wrap - without it the longer snapping variant would
    run straight off both sides of the hud
  ]]--
  instructionFontString:SetWidth(
    RGP_CONSTANTS.ELEMENT_POSITIONING_HUD_WIDTH - RGP_CONSTANTS.ELEMENT_POSITIONING_HUD_TEXT_INSET
  )
  instructionFontString:SetJustifyH("CENTER")
  -- the text itself depends on whether snapping is on, so it is set when the mode is entered
  frame.instruction = instructionFontString

  mod.uiHelper.CreateButton(
    frame,
    RGP_CONSTANTS.ELEMENT_POSITIONING_HUD_DONE_BUTTON,
    {"BOTTOM", 0, 12},
    RGP_CONSTANTS.ELEMENT_POSITIONING_HUD_BUTTON_WIDTH,
    RGP_CONSTANTS.ELEMENT_POSITIONING_HUD_BUTTON_HEIGHT,
    rgp.L["positioning_hud_done"],
    function()
      me.Exit(true)
    end
  )

  --[[
    Catches the exits that never reach the Done handler - Escape hides the frame directly
    through UISpecialFrames. Exiting via the button has already run, so this is a no-op then
  ]]--
  frame:SetScript("OnHide", function()
    me.Exit()
  end)

  frame:Hide()

  return frame
end
