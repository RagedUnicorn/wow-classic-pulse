--[[
  MIT License

  Copyright (c) 2025 Michael Wiesendanger

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

-- luacheck: globals CreateFrame STANDARD_TEXT_FONT MinimalSliderWithSteppersMixin Settings

local mod = rgp
local me = {}
mod.generalMenu = me

me.tag = "GeneralMenu"

--[[
  Option texts for UI elements
]]--
local options = {
  WindowLockEnergyBar = {
    label = rgp.L["window_lock_energy_bar"],
    tooltip = rgp.L["window_lock_energy_bar_tooltip"]
  },
  EnergyBarWidth = {
    label = rgp.L["energy_bar_width"],
    tooltip = rgp.L["energy_bar_width_tooltip"]
  },
  EnergyBarHeight = {
    label = rgp.L["energy_bar_height"],
    tooltip = rgp.L["energy_bar_height_tooltip"]
  }
}

-- track whether the menu was already built
local builtMenu = false

-- forward declarations
local BuildCheckButtonOption
local CreateSizeSlider
local GetLabelText
local OptTooltipOnEnter
local OptTooltipOnLeave
local LockWindowEnergyBarOnShow
local LockWindowEnergyBarOnClick

--[[
  Build the ui for the general menu

  @param {table} frame
    The addon configuration frame to attach to
]]--
function me.BuildUi(frame)
  if builtMenu then return end

  local titleFontString = frame:CreateFontString(RGP_CONSTANTS.ELEMENT_GENERAL_TITLE, "OVERLAY")
  titleFontString:SetFont("Fonts\\FRIZQT__.TTF", 20)
  titleFontString:SetPoint("TOP", 0, -20)
  titleFontString:SetSize(frame:GetWidth(), 20)
  titleFontString:SetText(rgp.L["general_title"])

  BuildCheckButtonOption(
    frame,
    RGP_CONSTANTS.ELEMENT_GENERAL_OPT_WINDOW_LOCK_ENERGY_BAR,
    20,
    -80,
    LockWindowEnergyBarOnShow,
    LockWindowEnergyBarOnClick
  )

  CreateSizeSlider(
    frame,
    RGP_CONSTANTS.ELEMENT_ENERGY_BAR_WIDTH_SLIDER,
    {"TOPLEFT", 20, -140},
    RGP_CONSTANTS.ELEMENT_ENERGY_BAR_MIN_WIDTH,
    RGP_CONSTANTS.ELEMENT_ENERGY_BAR_MAX_WIDTH,
    mod.configuration.GetEnergyBarWidth(),
    options.EnergyBarWidth.label,
    options.EnergyBarWidth.tooltip,
    function(value)
      mod.configuration.SetEnergyBarWidth(value)
      mod.energyBar.UpdateEnergyBarSize()
    end
  )

  CreateSizeSlider(
    frame,
    RGP_CONSTANTS.ELEMENT_ENERGY_BAR_HEIGHT_SLIDER,
    {"TOPLEFT", 20, -220},
    RGP_CONSTANTS.ELEMENT_ENERGY_BAR_MIN_HEIGHT,
    RGP_CONSTANTS.ELEMENT_ENERGY_BAR_MAX_HEIGHT,
    mod.configuration.GetEnergyBarHeight(),
    options.EnergyBarHeight.label,
    options.EnergyBarHeight.tooltip,
    function(value)
      mod.configuration.SetEnergyBarHeight(value)
      mod.energyBar.UpdateEnergyBarSize()
    end
  )

  builtMenu = true
end

--[[
  Build a checkbutton option

  @param {table} parentFrame
  @param {string} optionFrameName
  @param {number} posX
  @param {number} posY
  @param {function} onShowCallback
  @param {function} onClickCallback
]]--
BuildCheckButtonOption = function(parentFrame, optionFrameName, posX, posY, onShowCallback, onClickCallback)
  local checkButtonOptionFrame = CreateFrame("CheckButton", optionFrameName, parentFrame, "SettingsCheckboxTemplate")
  checkButtonOptionFrame:SetSize(
    RGP_CONSTANTS.ELEMENT_GENERAL_CHECK_OPTION_SIZE,
    RGP_CONSTANTS.ELEMENT_GENERAL_CHECK_OPTION_SIZE
  )
  checkButtonOptionFrame:SetPoint("TOPLEFT", posX, posY)

  local labelText = checkButtonOptionFrame:CreateFontString(nil, "OVERLAY")
  labelText:SetFont(STANDARD_TEXT_FONT, 15)
  labelText:SetTextColor(.95, .95, .95)
  labelText:SetPoint("LEFT", checkButtonOptionFrame, "RIGHT", 5, 0)
  labelText:SetText(GetLabelText(checkButtonOptionFrame))
  checkButtonOptionFrame.labelText = labelText

  checkButtonOptionFrame:SetScript("OnEnter", OptTooltipOnEnter)
  checkButtonOptionFrame:SetScript("OnLeave", OptTooltipOnLeave)
  checkButtonOptionFrame:SetScript("OnShow", onShowCallback)
  checkButtonOptionFrame:SetScript("OnClick", onClickCallback)
  -- load initial state
  onShowCallback(checkButtonOptionFrame)
end

--[[
  Get the label text for the checkbutton

  @param {table} frame

  @return {string}
    The text for the label
]]--
GetLabelText = function(frame)
  local name = frame:GetName()

  if not name then return end

  for optionKey, optionData in pairs(options) do
    if name == RGP_CONSTANTS.ELEMENT_GENERAL_OPT .. optionKey then
      return optionData.label
    end
  end
end

--[[
  OnEnter callback for checkbuttons - show tooltip

  @param {table} self
]]--
OptTooltipOnEnter = function(self)
  local name = self:GetName()

  if not name then return end

  for optionKey, optionData in pairs(options) do
    if name == RGP_CONSTANTS.ELEMENT_GENERAL_OPT .. optionKey then
      mod.tooltip.BuildTooltipForOption(optionData.label, optionData.tooltip, self)
      break
    end
  end
end

--[[
  OnEnter callback for checkbuttons - hide tooltip
]]--
OptTooltipOnLeave = function()
  _G[RGP_CONSTANTS.ELEMENT_TOOLTIP]:Hide()
end

--[[
  OnShow callback for checkbuttons - window lock energyBar

  @param {table} self
]]--
LockWindowEnergyBarOnShow = function(self)
  if mod.configuration.IsEnergyBarLocked() then
    self:SetChecked(true)
  else
    self:SetChecked(false)
  end
end

--[[
  OnClick callback for checkbuttons - window lock energyBar

  @param {table} self
]]--
LockWindowEnergyBarOnClick = function(self)
  local enabled = self:GetChecked()

  if enabled then
    mod.configuration.LockEnergyBar()
  else
    mod.configuration.UnlockEnergyBar()
  end
end

--[[
  Create a slider for changing the size of the energyBar

  @param {table} parentFrame
  @param {string} sliderName
  @param {table} position
    An object that can be unpacked into SetPoint
  @param {number} sliderMinValue
  @param {number} sliderMaxValue
  @param {number} defaultValue
  @param {string} sliderTitle
  @param {string} sliderTooltip
  @param {function} onValueChangedCallback
]]--
CreateSizeSlider = function(parentFrame, sliderName, position, sliderMinValue, sliderMaxValue, defaultValue,
    sliderTitle, sliderTooltip, onValueChangedCallback)

  local sliderOptions = Settings.CreateSliderOptions(
    sliderMinValue,
    sliderMaxValue,
    RGP_CONSTANTS.ELEMENT_ENERGY_BAR_SIZE_SLIDER_STEP
  )
  sliderOptions:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(value) return value end)
  sliderOptions:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Max, function() return sliderMaxValue end)
  sliderOptions:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Min, function() return sliderMinValue end)
  sliderOptions:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Top, function() return sliderTitle end)

  local sliderFrame = CreateFrame("Frame", sliderName, parentFrame, "MinimalSliderWithSteppersTemplate")
  sliderFrame:SetWidth(250)
  sliderFrame:SetPoint(unpack(position))
  sliderFrame:Init(
    defaultValue,
    sliderOptions.minValue,
    sliderOptions.maxValue,
    sliderOptions.steps,
    sliderOptions.formatters
  )
  sliderFrame.tooltipText = sliderTooltip

  if onValueChangedCallback then
    sliderFrame:RegisterCallback("OnValueChanged", onValueChangedCallback, sliderFrame)
  end

  local function ShowTooltip()
    if sliderFrame.tooltipText then
      mod.tooltip.BuildTooltipForOption(sliderTitle, sliderFrame.tooltipText, sliderFrame)
    end
  end

  local function HideTooltip()
    _G[RGP_CONSTANTS.ELEMENT_TOOLTIP]:Hide()
  end

  sliderFrame:SetScript("OnEnter", ShowTooltip)
  sliderFrame:SetScript("OnLeave", HideTooltip)

  local slider = sliderFrame.Slider
  local backButton = sliderFrame.Back
  local forwardButton = sliderFrame.Forward

  if slider then
    slider:SetScript("OnEnter", ShowTooltip)
    slider:SetScript("OnLeave", HideTooltip)
  end

  if backButton then
    backButton:SetScript("OnEnter", ShowTooltip)
    backButton:SetScript("OnLeave", HideTooltip)
  end

  if forwardButton then
    forwardButton:SetScript("OnEnter", ShowTooltip)
    forwardButton:SetScript("OnLeave", HideTooltip)
  end
end
