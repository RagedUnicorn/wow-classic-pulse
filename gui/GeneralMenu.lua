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
    description = rgp.L["window_lock_energy_bar_tooltip"]
  },
  EnergyBarWidth = {
    label = rgp.L["energy_bar_width"],
    description = rgp.L["energy_bar_width_tooltip"]
  },
  EnergyBarHeight = {
    label = rgp.L["energy_bar_height"],
    description = rgp.L["energy_bar_height_tooltip"]
  }
}

-- track whether the menu was already built
local builtMenu = false

-- forward declarations
local BuildCheckButtonOption
local CreateSizeSlider
local CreateSliderOptions
local CreateSliderDescription
local GetOptionData
local LockWindowEnergyBarOnShow
local LockWindowEnergyBarOnClick

--[[
  Build the ui for the general menu

  @param {table} frame
    The addon configuration frame to attach to
]]--
function me.BuildUi(frame)
  if builtMenu then return end

  local titleFontString = frame:CreateFontString(
    RGP_CONSTANTS.ELEMENT_GENERAL_TITLE, "OVERLAY", "GameFontNormalLarge")
  titleFontString:SetPoint("TOPLEFT", 16, -16)
  mod.uiHelper.SetColor(titleFontString, RGP_CONSTANTS.COLOR.TITLE_GOLD)
  titleFontString:SetText(rgp.L["general_title"])

  BuildCheckButtonOption(
    frame,
    RGP_CONSTANTS.ELEMENT_GENERAL_OPT_WINDOW_LOCK_ENERGY_BAR,
    20,
    -52,
    LockWindowEnergyBarOnShow,
    LockWindowEnergyBarOnClick
  )

  CreateSizeSlider(
    frame,
    RGP_CONSTANTS.ELEMENT_ENERGY_BAR_WIDTH_SLIDER,
    {"TOPLEFT", 20, -130},
    RGP_CONSTANTS.ELEMENT_ENERGY_BAR_MIN_WIDTH,
    RGP_CONSTANTS.ELEMENT_ENERGY_BAR_MAX_WIDTH,
    mod.configuration.GetEnergyBarWidth(),
    options.EnergyBarWidth.label,
    options.EnergyBarWidth.description,
    function(_, value)
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
    options.EnergyBarHeight.description,
    function(_, value)
      mod.configuration.SetEnergyBarHeight(value)
      mod.energyBar.UpdateEnergyBarSize()
    end
  )

  builtMenu = true
end

--[[
  Create slider options with label formatters

  @param {number} minValue
  @param {number} maxValue
  @param {string} title

  @return {table} configured slider options
]]--
CreateSliderOptions = function(minValue, maxValue, title)
  local sliderOptions = Settings.CreateSliderOptions(
    minValue,
    maxValue,
    RGP_CONSTANTS.ELEMENT_ENERGY_BAR_SIZE_SLIDER_STEP
  )
  sliderOptions:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(value) return value end)
  sliderOptions:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Max, function() return maxValue end)
  sliderOptions:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Min, function() return minValue end)
  sliderOptions:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Top, function() return title end)

  return sliderOptions
end

--[[
  Create an always visible description below a slider

  @param {table} sliderFrame
  @param {string} description
]]--
CreateSliderDescription = function(sliderFrame, description)
  local descriptionFontString = sliderFrame:CreateFontString(nil, "OVERLAY")
  descriptionFontString:SetFont(STANDARD_TEXT_FONT, 12)
  mod.uiHelper.SetColor(descriptionFontString, RGP_CONSTANTS.COLOR.SUBNOTE)
  -- the template renders its min/max value labels below the frame - clear them
  descriptionFontString:SetPoint("TOPLEFT", sliderFrame, "BOTTOMLEFT", 4, -16)
  descriptionFontString:SetJustifyH("LEFT")
  descriptionFontString:SetText(description)
  sliderFrame.description = descriptionFontString
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
  local optionData = GetOptionData(optionFrameName)
  local checkButtonOptionFrame = mod.uiHelper.CreateCheckBox(
    optionFrameName,
    parentFrame,
    {"TOPLEFT", posX, posY},
    onClickCallback,
    onShowCallback,
    optionData and optionData.label,
    optionData and optionData.description
  )

  -- load initial state
  onShowCallback(checkButtonOptionFrame)
end

--[[
  Get the option metadata for a checkbutton

  @param {string} frameName

  @return {table | nil}
    The option data with label and description
]]--
GetOptionData = function(frameName)
  if not frameName then return end

  for optionKey, optionData in pairs(options) do
    if frameName == RGP_CONSTANTS.ELEMENT_GENERAL_OPT .. optionKey then
      return optionData
    end
  end
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
  @param {string} sliderDescription
  @param {function} onValueChangedCallback
]]--
CreateSizeSlider = function(parentFrame, sliderName, position, sliderMinValue, sliderMaxValue, defaultValue,
    sliderTitle, sliderDescription, onValueChangedCallback)

  local sliderOptions = CreateSliderOptions(sliderMinValue, sliderMaxValue, sliderTitle)

  local sliderFrame = CreateFrame("Frame", sliderName, parentFrame, "MinimalSliderWithSteppersTemplate")
  sliderFrame:SetWidth(RGP_CONSTANTS.ELEMENT_ENERGY_BAR_SIZE_SLIDER_WIDTH)
  sliderFrame:SetPoint(unpack(position))
  sliderFrame:Init(
    defaultValue,
    sliderOptions.minValue,
    sliderOptions.maxValue,
    sliderOptions.steps,
    sliderOptions.formatters
  )

  if onValueChangedCallback then
    sliderFrame:RegisterCallback("OnValueChanged", onValueChangedCallback, sliderFrame)
  end

  CreateSliderDescription(sliderFrame, sliderDescription)
end
