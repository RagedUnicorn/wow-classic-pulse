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

-- luacheck: globals CreateFrame STANDARD_TEXT_FONT

local mod = rgp
local me = {}
mod.generalMenu = me

me.tag = "GeneralMenu"

--[[
  Option texts for checkbutton options
]]--
local options = {
  {"WindowLockEnergyBar", rgp.L["window_lock_energy_bar"], rgp.L["window_lock_energy_bar_tooltip"]}
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
local EnergyBarWidthSliderOnShow
local EnergyBarWidthSliderOnValueChanged
local EnergyBarHeightSliderOnShow
local EnergyBarHeightSliderOnValueChanged

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
    rgp.L["energy_bar_width"],
    rgp.L["energy_bar_width_tooltip"],
    EnergyBarWidthSliderOnShow,
    EnergyBarWidthSliderOnValueChanged
  )

  CreateSizeSlider(
    frame,
    RGP_CONSTANTS.ELEMENT_ENERGY_BAR_HEIGHT_SLIDER,
    {"TOPLEFT", 20, -220},
    RGP_CONSTANTS.ELEMENT_ENERGY_BAR_MIN_HEIGHT,
    RGP_CONSTANTS.ELEMENT_ENERGY_BAR_MAX_HEIGHT,
    mod.configuration.GetEnergyBarHeight(),
    rgp.L["energy_bar_height"],
    rgp.L["energy_bar_height_tooltip"],
    EnergyBarHeightSliderOnShow,
    EnergyBarHeightSliderOnValueChanged
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

  for i = 1, #options do
    if name == RGP_CONSTANTS.ELEMENT_GENERAL_OPT .. options[i][1] then
      return options[i][2]
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

  for i = 1, #options do
    if name == RGP_CONSTANTS.ELEMENT_GENERAL_OPT .. options[i][1] then
      mod.tooltip.BuildTooltipForOption(options[i][2], options[i][3], self)
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
  @param {function} onShowCallback
  @param {function} OnValueChangedCallback
]]--
CreateSizeSlider = function(parentFrame, sliderName, position, sliderMinValue, sliderMaxValue, defaultValue,
    sliderTitle, sliderTooltip, onShowCallback, OnValueChangedCallback)

  local options = Settings.CreateSliderOptions(sliderMinValue, sliderMaxValue, RGP_CONSTANTS.ELEMENT_ENERGY_BAR_SIZE_SLIDER_STEP)
  options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(value) return value end)
  options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Max, function(value) return sliderMaxValue end)
  options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Min, function(value) return sliderMinValue end)
  options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Top, function(value) return sliderTitle end)

  local sliderFrame = CreateFrame("Frame", sliderName, parentFrame, "MinimalSliderWithSteppersTemplate")
  sliderFrame:SetWidth(250)
  sliderFrame:SetPoint(unpack(position))
  sliderFrame:Init(defaultValue, options.minValue, options.maxValue, options.steps, options.formatters)
  sliderFrame:RegisterCallback("OnValueChanged", OnValueChangedCallback, sliderFrame)

  -- Store callbacks for compatibility
  sliderFrame.onShowCallback = onShowCallback
  sliderFrame.tooltipText = sliderTooltip

  -- Add tooltip support for modern sliders - need to add to child elements
  local function ShowTooltip(self)
    if sliderFrame.tooltipText then
      mod.tooltip.BuildTooltipForOption(sliderTitle, sliderFrame.tooltipText, sliderFrame)
    end
  end

  local function HideTooltip(self)
    _G[RGP_CONSTANTS.ELEMENT_TOOLTIP]:Hide()
  end

  -- Add tooltip to the main frame
  sliderFrame:SetScript("OnEnter", ShowTooltip)
  sliderFrame:SetScript("OnLeave", HideTooltip)

  -- Add tooltip to all child regions (slider bar, buttons, etc.)
  for _, child in pairs({sliderFrame:GetChildren()}) do
    if child:IsObjectType("Slider") or child:IsObjectType("Button") then
      child:SetScript("OnEnter", ShowTooltip)
      child:SetScript("OnLeave", HideTooltip)
    end
  end

  -- Also check regions (textures, fontstrings)
  for _, region in pairs({sliderFrame:GetRegions()}) do
    if region:IsObjectType("Texture") and region:IsMouseEnabled() then
      region:SetScript("OnEnter", ShowTooltip)
      region:SetScript("OnLeave", HideTooltip)
    end
  end

  -- Call onShow callback
  onShowCallback(sliderFrame)
end

--[[
  OnShow callback for energy bar width slider

  @param {table} self
]]--
EnergyBarWidthSliderOnShow = function(self)
  -- Check if this is a modern slider
  if self.Init then
    -- Modern slider - value is already set during Init
    return
  end

  -- Old slider
  self:SetValue(mod.configuration.GetEnergyBarWidth())
  if self.valueFontString then
    self.valueFontString:SetText(self:GetValue())
  end
end

--[[
  OnValueChanged callback for energy bar width slider

  @param {table} self
  @param {number} value
]]--
EnergyBarWidthSliderOnValueChanged = function(self, value)
  -- Update value display for old sliders
  if self.valueFontString then
    self.valueFontString:SetText(value)
  end

  mod.configuration.SetEnergyBarWidth(value)
  mod.energyBar.UpdateEnergyBarSize()
end

--[[
  OnShow callback for energy bar height slider

  @param {table} self
]]--
EnergyBarHeightSliderOnShow = function(self)
  -- Check if this is a modern slider
  if self.Init then
    -- Modern slider - value is already set during Init
    return
  end

  -- Old slider
  self:SetValue(mod.configuration.GetEnergyBarHeight())
  if self.valueFontString then
    self.valueFontString:SetText(self:GetValue())
  end
end

--[[
  OnValueChanged callback for energy bar height slider

  @param {table} self
  @param {number} value
]]--
EnergyBarHeightSliderOnValueChanged = function(self, value)
  -- Update value display for old sliders
  if self.valueFontString then
    self.valueFontString:SetText(value)
  end

  mod.configuration.SetEnergyBarHeight(value)
  mod.energyBar.UpdateEnergyBarSize()
end
