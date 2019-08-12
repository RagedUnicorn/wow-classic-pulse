--[[
  MIT License

  Copyright (c) 2019 Michael Wiesendanger

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
    Update Intervals for tickers
  ]]--
  ENERGY_BAR_UPDATE_INTERVAL = 0.01,
  --[[
    EnergyBar
  ]]--
  ELEMENT_ENERGY_BAR_FRAME = "P_EnergyBar",
  ELEMENT_ENERGY_BAR_WIDTH = 80,
  ELEMENT_ENERGY_BAR_HEIGHT = 25,
  ELEMENT_ENERGY_BAR_STATUS_BAR = "$parentStatusBar",
  ELEMENT_ENERGY_BAR_STATUS_BAR_MIN = 0,
  ELEMENT_ENERGY_BAR_STATUS_BAR_MAX = 2,
  ELEMENT_ENERGY_BAR_ENERGY_AMOUNT = "$parentEnergyAmount",
  ELEMENT_ENERGY_BAR_ENERGY_AMOUNT_WIDTH = 30,
  ELEMENT_ENERGY_BAR_ENERGY_AMOUNT_HEIGHT = 20,

  --[[
    Addon configuration
  ]]--
  ELEMENT_ADDON_PANEL = "P_AddonPanel",
  ELEMENT_TOOLTIP = "GameTooltip", -- default blizzard frames tooltip
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
  ELEMENT_GENERAL_CHECK_OPTION_SIZE = 32,
  ELEMENT_GENERAL_OPT = "P_Opt",
  ELEMENT_GENERAL_FRAME = "P_GeneralFrame",
  ELEMENT_GENERAL_TITLE = "P_GeneralTitle",
  ELEMENT_GENERAL_OPT_WINDOW_LOCK_ENERGY_BAR = "P_OptWindowLockEnergyBar",
}
