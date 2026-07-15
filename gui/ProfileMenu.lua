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

-- luacheck: globals CreateFrame STANDARD_TEXT_FONT StaticPopupDialogs StaticPopup_Show ReloadUI
-- luacheck: globals ACCEPT CANCEL YES NO

local mod = rgp
local me = {}
mod.profileMenu = me

me.tag = "ProfileMenu"

--[[
  Currently selected profile name in the list, or nil when nothing is selected
]]--
me.selectedProfile = nil

-- track whether the menu was already built
local builtMenu = false

--[[
  Scroll child holding the profile rows and the reusable row button pool
]]--
local profileListContent
local rows = {}

--[[
  The multiline edit box used for export/import strings
]]--
local profileEditBox

-- forward declarations
local SetupStaticPopups
local CreateActionButton
local CreateProfileRow
local RefreshList
local Trim
local HandleSave
local HandleApply
local HandleDelete
local HandleRename
local HandleExport
local HandleImport
local FinishImport

--[[
  Build the ui for the profile menu. Built once (guarded); the list is
  refreshed on every show so external changes are reflected.

  @param {table} frame
    The addon configuration frame to attach to
]]--
function me.BuildUi(frame)
  if not builtMenu then
    SetupStaticPopups()

    local titleFontString = frame:CreateFontString(RGP_CONSTANTS.ELEMENT_PROFILE_TITLE, "OVERLAY")
    titleFontString:SetFont("Fonts\\FRIZQT__.TTF", 20)
    titleFontString:SetPoint("TOP", 0, -20)
    titleFontString:SetSize(frame:GetWidth(), 20)
    titleFontString:SetText(rgp.L["profile_title"])

    local listLabel = frame:CreateFontString(nil, "OVERLAY")
    listLabel:SetFont(STANDARD_TEXT_FONT, 13)
    listLabel:SetPoint("TOPLEFT", 20, -62)
    listLabel:SetText(rgp.L["profile_list_label"])

    me.BuildProfileList(frame)
    me.BuildActionButtons(frame)

    local stringLabel = frame:CreateFontString(nil, "OVERLAY")
    stringLabel:SetFont(STANDARD_TEXT_FONT, 13)
    stringLabel:SetPoint("TOPLEFT", 20, -262)
    stringLabel:SetText(rgp.L["profile_string_label"])

    me.BuildStringBox(frame)

    builtMenu = true
  end

  RefreshList()
end

--[[
  Build the bordered, scrollable list of saved profiles.

  @param {table} frame
]]--
function me.BuildProfileList(frame)
  local listWidth = RGP_CONSTANTS.ELEMENT_PROFILE_LIST_WIDTH
  local listHeight = RGP_CONSTANTS.ELEMENT_PROFILE_LIST_HEIGHT

  local listContainer = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  listContainer:SetSize(listWidth, listHeight)
  listContainer:SetPoint("TOPLEFT", 20, -80)
  listContainer:SetBackdrop({
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
  })
  listContainer:SetBackdropColor(0, 0, 0, 0.4)
  listContainer:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)

  local scrollFrame = CreateFrame(
    "ScrollFrame",
    RGP_CONSTANTS.ELEMENT_PROFILE_LIST_SCROLL_FRAME,
    listContainer,
    "UIPanelScrollFrameTemplate"
  )
  scrollFrame:SetPoint("TOPLEFT", 6, -6)
  scrollFrame:SetPoint("BOTTOMRIGHT", -28, 6)

  profileListContent = CreateFrame("Frame", RGP_CONSTANTS.ELEMENT_PROFILE_LIST_CONTENT_FRAME, scrollFrame)
  profileListContent:SetSize(listWidth - 34, listHeight)
  scrollFrame:SetScrollChild(profileListContent)
end

--[[
  Build the action buttons that operate on the selected profile plus the
  save-current button.

  @param {table} frame
]]--
function me.BuildActionButtons(frame)
  CreateActionButton(
    frame,
    RGP_CONSTANTS.ELEMENT_PROFILE_SAVE_BUTTON,
    150,
    {"TOPLEFT", 320, -80},
    rgp.L["profile_save_button"],
    function()
      StaticPopup_Show("PULSE_PROFILE_SAVE")
    end
  )

  CreateActionButton(
    frame,
    RGP_CONSTANTS.ELEMENT_PROFILE_APPLY_BUTTON,
    150,
    {"TOPLEFT", 320, -112},
    rgp.L["profile_apply_button"],
    function()
      if not me.selectedProfile then
        mod.logger.PrintUserError(rgp.L["profile_error_no_selection"])
        return
      end

      StaticPopup_Show("PULSE_PROFILE_APPLY", me.selectedProfile, nil, me.selectedProfile)
    end
  )

  CreateActionButton(
    frame,
    RGP_CONSTANTS.ELEMENT_PROFILE_RENAME_BUTTON,
    150,
    {"TOPLEFT", 320, -144},
    rgp.L["profile_rename_button"],
    function()
      if not me.selectedProfile then
        mod.logger.PrintUserError(rgp.L["profile_error_no_selection"])
        return
      end

      StaticPopup_Show("PULSE_PROFILE_RENAME", nil, nil, me.selectedProfile)
    end
  )

  CreateActionButton(
    frame,
    RGP_CONSTANTS.ELEMENT_PROFILE_DELETE_BUTTON,
    150,
    {"TOPLEFT", 320, -176},
    rgp.L["profile_delete_button"],
    function()
      if not me.selectedProfile then
        mod.logger.PrintUserError(rgp.L["profile_error_no_selection"])
        return
      end

      StaticPopup_Show("PULSE_PROFILE_DELETE", me.selectedProfile, nil, me.selectedProfile)
    end
  )
end

--[[
  Build the multiline export/import string box and its Export/Import buttons.

  @param {table} frame
]]--
function me.BuildStringBox(frame)
  local stringContainer = CreateFrame(
    "ScrollFrame",
    RGP_CONSTANTS.ELEMENT_PROFILE_STRING_SCROLL_FRAME,
    frame,
    "InputScrollFrameTemplate"
  )
  stringContainer:SetSize(RGP_CONSTANTS.ELEMENT_PROFILE_STRING_WIDTH, RGP_CONSTANTS.ELEMENT_PROFILE_STRING_HEIGHT)
  stringContainer:SetPoint("TOPLEFT", 20, -280)

  if stringContainer.CharCount then
    stringContainer.CharCount:Hide()
  end

  profileEditBox = stringContainer.EditBox
  profileEditBox:SetMaxLetters(0)
  profileEditBox:SetFontObject("ChatFontNormal")
  profileEditBox:SetWidth(RGP_CONSTANTS.ELEMENT_PROFILE_STRING_WIDTH - 18)
  profileEditBox:SetScript("OnEscapePressed", function(self)
    self:ClearFocus()
  end)

  CreateActionButton(
    frame,
    RGP_CONSTANTS.ELEMENT_PROFILE_EXPORT_BUTTON,
    110,
    {"TOPLEFT", 20, -382},
    rgp.L["profile_export_button"],
    HandleExport
  )

  CreateActionButton(
    frame,
    RGP_CONSTANTS.ELEMENT_PROFILE_IMPORT_BUTTON,
    110,
    {"TOPLEFT", 140, -382},
    rgp.L["profile_import_button"],
    HandleImport
  )
end

--[[
  Select a profile by name and update the row highlights.

  @param {string} name
]]--
function me.SelectProfile(name)
  me.selectedProfile = name

  for _, row in ipairs(rows) do
    if row:IsShown() and row.profileName == name then
      row.selectedTexture:Show()
    else
      row.selectedTexture:Hide()
    end
  end
end

--[[
  Create (or reuse) a row button at the given index in the list.

  @param {number} index
  @return {table}
]]--
CreateProfileRow = function(index)
  local rowHeight = RGP_CONSTANTS.ELEMENT_PROFILE_LIST_ROW_HEIGHT

  local row = CreateFrame("Button", RGP_CONSTANTS.ELEMENT_PROFILE_LIST_ROW .. index, profileListContent)
  row:SetHeight(rowHeight)
  row:SetPoint("TOPLEFT", profileListContent, "TOPLEFT", 0, -(index - 1) * rowHeight)
  row:SetPoint("TOPRIGHT", profileListContent, "TOPRIGHT", 0, -(index - 1) * rowHeight)

  local selectedTexture = row:CreateTexture(nil, "BACKGROUND")
  selectedTexture:SetAllPoints()
  selectedTexture:SetColorTexture(1, 0.82, 0, 0.25)
  selectedTexture:Hide()
  row.selectedTexture = selectedTexture

  local highlightTexture = row:CreateTexture(nil, "HIGHLIGHT")
  highlightTexture:SetAllPoints()
  highlightTexture:SetColorTexture(1, 1, 1, 0.15)

  local label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  label:SetPoint("LEFT", 4, 0)
  label:SetJustifyH("LEFT")
  row.label = label

  row:SetScript("OnClick", function(self)
    me.SelectProfile(self.profileName)
  end)

  return row
end

--[[
  Rebuild the visible profile rows from the saved profile list.
]]--
RefreshList = function()
  if not profileListContent then return end

  local names = mod.profile.ListProfiles()

  -- drop a selection that no longer exists
  if me.selectedProfile and not mod.profile.ProfileExists(me.selectedProfile) then
    me.selectedProfile = nil
  end

  local rowHeight = RGP_CONSTANTS.ELEMENT_PROFILE_LIST_ROW_HEIGHT
  profileListContent:SetHeight(math.max(#names * rowHeight, 1))

  for index, name in ipairs(names) do
    local row = rows[index]

    if not row then
      row = CreateProfileRow(index)
      rows[index] = row
    end

    row.profileName = name
    row.label:SetText(name)

    if name == me.selectedProfile then
      row.selectedTexture:Show()
    else
      row.selectedTexture:Hide()
    end

    row:Show()
  end

  for index = #names + 1, #rows do
    rows[index]:Hide()
  end
end

--[[
  Helper to create a UIPanelButton.

  @param {table} parent
  @param {string} name
  @param {number} width
  @param {table} point
    a table that can be unpacked into SetPoint
  @param {string} text
  @param {function} onClick
  @return {table}
]]--
CreateActionButton = function(parent, name, width, point, text, onClick)
  local button = CreateFrame("Button", name, parent, "UIPanelButtonTemplate")
  button:SetSize(width, RGP_CONSTANTS.ELEMENT_PROFILE_BUTTON_HEIGHT)
  button:SetPoint(unpack(point))
  button:SetText(text)
  button:SetScript("OnClick", onClick)

  return button
end

--[[
  Trim leading/trailing whitespace from a string.

  @param {string} value
  @return {string}
]]--
Trim = function(value)
  return (string.match(value, "^%s*(.-)%s*$"))
end

--[[
  Save the live configuration as a new (or overwritten) named profile.

  @param {string} name
]]--
HandleSave = function(name)
  name = Trim(name)

  if name == "" then
    mod.logger.PrintUserError(rgp.L["profile_error_name_empty"])
    return
  end

  mod.profile.SaveProfile(name, mod.profile.BuildSnapshot())
  me.selectedProfile = name
  RefreshList()
  mod.logger.PrintUserMessage(string.format(rgp.L["profile_save_success"], name))
end

--[[
  Apply a stored profile to the live configuration and reload the UI.

  @param {string} name
]]--
HandleApply = function(name)
  local payload = mod.profile.GetProfile(name)

  if not payload then
    mod.logger.PrintUserError(rgp.L["profile_error_no_selection"])
    return
  end

  mod.profile.ApplySnapshot(payload)
  ReloadUI()
end

--[[
  Delete a stored profile.

  @param {string} name
]]--
HandleDelete = function(name)
  mod.profile.DeleteProfile(name)

  if me.selectedProfile == name then
    me.selectedProfile = nil
  end

  RefreshList()
  mod.logger.PrintUserMessage(string.format(rgp.L["profile_delete_success"], name))
end

--[[
  Rename a stored profile.

  @param {string} oldName
  @param {string} newName
]]--
HandleRename = function(oldName, newName)
  newName = Trim(newName)

  if newName == "" then
    mod.logger.PrintUserError(rgp.L["profile_error_name_empty"])
    return
  end

  if newName ~= oldName and mod.profile.ProfileExists(newName) then
    mod.logger.PrintUserError(rgp.L["profile_error_name_exists"])
    return
  end

  mod.profile.RenameProfile(oldName, newName)
  me.selectedProfile = newName
  RefreshList()
  mod.logger.PrintUserMessage(string.format(rgp.L["profile_rename_success"], newName))
end

--[[
  Export the selected profile into the string box and select it for copying.
]]--
HandleExport = function()
  local name = me.selectedProfile

  if not name then
    mod.logger.PrintUserError(rgp.L["profile_error_no_selection"])
    return
  end

  local payload = mod.profile.GetProfile(name)

  if not payload then
    mod.logger.PrintUserError(rgp.L["profile_error_no_selection"])
    return
  end

  profileEditBox:SetText(mod.profile.ExportString(payload, name))
  profileEditBox:HighlightText()
  profileEditBox:SetFocus()
end

--[[
  Decode and validate the string box content, then prompt for a name to store
  it under.
]]--
HandleImport = function()
  local envelope, errorKey = mod.profile.ImportString(profileEditBox:GetText())

  if not envelope then
    mod.logger.PrintUserError(rgp.L[errorKey])
    return
  end

  StaticPopup_Show("PULSE_PROFILE_IMPORT", nil, nil, envelope)
end

--[[
  Store an imported, already-validated envelope under a user-given name.

  @param {string} name
  @param {table} envelope
]]--
FinishImport = function(name, envelope)
  name = Trim(name)

  if name == "" then
    mod.logger.PrintUserError(rgp.L["profile_error_name_empty"])
    return
  end

  if mod.profile.ProfileExists(name) then
    mod.logger.PrintUserError(rgp.L["profile_error_name_exists"])
    return
  end

  mod.profile.SaveProfile(name, envelope.payload)
  me.selectedProfile = name
  profileEditBox:SetText("")
  RefreshList()
  mod.logger.PrintUserMessage(string.format(rgp.L["profile_import_success"], name))
end

--[[
  Register the StaticPopup dialogs used for naming and destructive confirmation.
]]--
SetupStaticPopups = function()
  StaticPopupDialogs["PULSE_PROFILE_SAVE"] = {
    text = rgp.L["profile_name_prompt"],
    button1 = ACCEPT,
    button2 = CANCEL,
    hasEditBox = true,
    maxLetters = 64,
    OnShow = function(self)
      self.EditBox:SetText("")
      self.EditBox:SetFocus()
    end,
    OnAccept = function(self)
      HandleSave(self.EditBox:GetText())
    end,
    EditBoxOnEnterPressed = function(self)
      HandleSave(self:GetText())
      self:GetParent():Hide()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3
  }

  StaticPopupDialogs["PULSE_PROFILE_RENAME"] = {
    text = rgp.L["profile_rename_prompt"],
    button1 = ACCEPT,
    button2 = CANCEL,
    hasEditBox = true,
    maxLetters = 64,
    OnShow = function(self)
      self.EditBox:SetText(self.data or "")
      self.EditBox:SetFocus()
      self.EditBox:HighlightText()
    end,
    OnAccept = function(self)
      HandleRename(self.data, self.EditBox:GetText())
    end,
    EditBoxOnEnterPressed = function(self)
      local parent = self:GetParent()
      HandleRename(parent.data, self:GetText())
      parent:Hide()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3
  }

  StaticPopupDialogs["PULSE_PROFILE_IMPORT"] = {
    text = rgp.L["profile_import_name_prompt"],
    button1 = ACCEPT,
    button2 = CANCEL,
    hasEditBox = true,
    maxLetters = 64,
    OnShow = function(self)
      self.EditBox:SetText((self.data and self.data.name) or "")
      self.EditBox:SetFocus()
      self.EditBox:HighlightText()
    end,
    OnAccept = function(self)
      FinishImport(self.EditBox:GetText(), self.data)
    end,
    EditBoxOnEnterPressed = function(self)
      local parent = self:GetParent()
      FinishImport(self:GetText(), parent.data)
      parent:Hide()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3
  }

  StaticPopupDialogs["PULSE_PROFILE_APPLY"] = {
    text = rgp.L["profile_apply_confirm"],
    button1 = YES,
    button2 = NO,
    OnAccept = function(self)
      HandleApply(self.data)
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3
  }

  StaticPopupDialogs["PULSE_PROFILE_DELETE"] = {
    text = rgp.L["profile_delete_confirm"],
    button1 = YES,
    button2 = NO,
    OnAccept = function(self)
      HandleDelete(self.data)
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3
  }
end
