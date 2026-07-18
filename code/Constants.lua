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

RGP_CONSTANTS = {
  ADDON_NAME = "Pulse",
  --[[
    Unit ids
  ]]--
  UNIT_ID_PLAYER = "player",
  --[[
    PowerType
  ]]--
  POWERTYPE_ENERGY = {"ENERGY", 3},
  --[[
    Addon message prefix for the version broadcast (max 16 characters)
  ]]--
  ADDON_MESSAGE_PREFIX = "RGP_VER",
  --[[
    Update Intervals for tickers
  ]]--
  ENERGY_BAR_UPDATE_INTERVAL = 0.05,
  --[[
    Energy tickrate every 2 seconds
  ]]--
  TICK_RATE = 2,
  --[[
    EnergyBar
  ]]--
  ELEMENT_ENERGY_BAR_FRAME = "P_EnergyBar",
  ELEMENT_ENERGY_BAR_WIDTH = 120,
  ELEMENT_ENERGY_BAR_HEIGHT = 30,
  ELEMENT_ENERGY_BAR_STATUS_BAR = "$parentStatusBar",
  ELEMENT_ENERGY_BAR_STATUS_BAR_MIN = 0,
  ELEMENT_ENERGY_BAR_STATUS_BAR_MAX = 2,
  ELEMENT_ENERGY_BAR_ENERGY_AMOUNT = "$parentEnergyAmount",

  --[[
    Addon configuration
  ]]--
  ELEMENT_ADDON_PANEL = "P_AddonPanel",
  --[[
    Design colour tokens as { r, g, b } in the 0-1 range. Derived from Quartermaster's COLOR
    table, but BODY / SUBNOTE are brightened: Quartermaster's values are tuned for its own
    near-black panel backdrop, while these panels render on the lighter stock settings canvas.
  ]]--
  COLOR = {
    TITLE_GOLD = { 1.0, 0.819, 0.0 },       -- #ffd100 panel titles
    SECTION_GOLD = { 0.851, 0.647, 0.129 }, -- #d9a521 section headers
    BODY = { 0.91, 0.87, 0.80 },            -- #e8decc body text / option labels (warm near-white)
    MUTED = { 0.541, 0.486, 0.392 },        -- #8a7c64 idle / dim text
    DISABLED = { 0.45, 0.41, 0.35 },        -- disabled control labels (QM stepper disabled-glyph tone)
    SUBNOTE = { 0.66, 0.60, 0.50 }          -- #a89980 option descriptions (warm mid gray)
  },
  --[[
    About
  ]]--
  ELEMENT_ABOUT_LOGO = "P_AboutLogo",
  ELEMENT_ABOUT_AUTHOR_FONT_STRING = "P_AboutAuthor",
  ELEMENT_ABOUT_EMAIL_FONT_STRING = "P_AboutEmail",
  ELEMENT_ABOUT_VERSION_FONT_STRING = "P_AboutVersion",
  ELEMENT_ABOUT_ISSUES_FONT_STRING = "P_AboutIssues",
  --[[
    General
  ]]--
  ELEMENT_GENERAL_SUB_OPTION_FRAME = "P_GeneralMenuOptionsFrame",
  ELEMENT_GENERAL_CHECK_OPTION_SIZE = 24,
  ELEMENT_GENERAL_OPT = "P_Opt",
  ELEMENT_GENERAL_TITLE = "P_GeneralTitle",
  ELEMENT_GENERAL_OPT_WINDOW_LOCK_ENERGY_BAR = "P_OptWindowLockEnergyBar",

  --[[
    Energy Bar Size Configuration
  ]]--
  ELEMENT_ENERGY_BAR_SIZE_SLIDER_WIDTH = 250,
  ELEMENT_ENERGY_BAR_SIZE_SLIDER_STEP = 5,
  ELEMENT_ENERGY_BAR_WIDTH_SLIDER = "P_EnergyBarWidthSlider",
  ELEMENT_ENERGY_BAR_HEIGHT_SLIDER = "P_EnergyBarHeightSlider",
  ELEMENT_ENERGY_BAR_MIN_WIDTH = 50,
  ELEMENT_ENERGY_BAR_MAX_WIDTH = 300,
  ELEMENT_ENERGY_BAR_MIN_HEIGHT = 15,
  ELEMENT_ENERGY_BAR_MAX_HEIGHT = 60,

  --[[
    Profile (import/export and named profiles)
  ]]--
  ELEMENT_PROFILE_SUB_OPTION_FRAME = "P_ProfileMenuOptionsFrame",
  ELEMENT_PROFILE_TITLE = "P_ProfileTitle",
  ELEMENT_PROFILE_LIST_SCROLL_FRAME = "P_ProfileListScrollFrame",
  ELEMENT_PROFILE_LIST_CONTENT_FRAME = "P_ProfileListContentFrame",
  ELEMENT_PROFILE_LIST_ROW = "P_ProfileListRow", -- suffixed with the row index
  ELEMENT_PROFILE_SAVE_BUTTON = "P_ProfileSaveButton",
  ELEMENT_PROFILE_APPLY_BUTTON = "P_ProfileApplyButton",
  ELEMENT_PROFILE_RENAME_BUTTON = "P_ProfileRenameButton",
  ELEMENT_PROFILE_DELETE_BUTTON = "P_ProfileDeleteButton",
  ELEMENT_PROFILE_EXPORT_BUTTON = "P_ProfileExportButton",
  ELEMENT_PROFILE_IMPORT_BUTTON = "P_ProfileImportButton",
  ELEMENT_PROFILE_STRING_SCROLL_FRAME = "P_ProfileStringScrollFrame",
  ELEMENT_PROFILE_STRING_EDIT_BOX = "P_ProfileStringEditBox",
  --[[
    Profile layout sizing
  ]]--
  ELEMENT_PROFILE_LIST_WIDTH = 280,
  ELEMENT_PROFILE_LIST_HEIGHT = 160,
  ELEMENT_PROFILE_LIST_ROW_HEIGHT = 20,
  ELEMENT_PROFILE_BUTTON_WIDTH = 110,
  ELEMENT_PROFILE_BUTTON_HEIGHT = 24,
  ELEMENT_PROFILE_STRING_WIDTH = 540,
  ELEMENT_PROFILE_STRING_HEIGHT = 90,
}
