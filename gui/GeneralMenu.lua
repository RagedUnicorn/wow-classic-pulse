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
  },
  SnapEnergyBarToGrid = {
    label = rgp.L["snap_energy_bar_to_grid"],
    description = rgp.L["snap_energy_bar_to_grid_tooltip"]
  },
  EnergyBarGridSize = {
    label = rgp.L["energy_bar_grid_size"],
    description = rgp.L["energy_bar_grid_size_tooltip"]
  }
}

-- track whether the menu was already built
local builtMenu = false
--[[
  The grid size slider, kept around so its enabled state can follow the snap checkbox
]]--
local gridSizeSlider

-- forward declarations
local BuildCheckButtonOption
local CreateSizeSlider
local CreateSliderOptions
local CreateSliderDescription
local GetOptionData
local LockWindowEnergyBarOnShow
local LockWindowEnergyBarOnClick
local SnapEnergyBarToGridOnShow
local SnapEnergyBarToGridOnClick
local UpdateGridSizeSliderState

--[[
  Build the ui for the general menu

  @param {table} frame
    The addon configuration frame to attach to
]]--
function me.BuildUi(frame)
  --[[
    Force the energyBar visible while the panel is open so the width/height
    sliders show their effect live even for a class/state where no energy tick
    has fired yet. Runs on every OnShow, before the one-time build guard
  ]]--
  mod.energyBar.ShowPreview()

  if builtMenu then return end

  --[[
    Restore the bar's prior state when the panel closes (registered once).

    Skipped while the positioning mode is running: that mode closes this very panel on its
    way in, which fires this OnHide, and tearing the preview down here would hide the bar
    the user just asked to place. The mode owns the preview from that point on and reverses
    it when it exits
  ]]--
  frame:HookScript("OnHide", function()
    if mod.positioningMode.IsActive() then return end

    mod.energyBar.HidePreview()
  end)

  local titleFontString = frame:CreateFontString(
    RGP_CONSTANTS.ELEMENT_GENERAL_TITLE, "OVERLAY", "GameFontNormalLarge")
  titleFontString:SetPoint("TOPLEFT", 16, -16)
  mod.uiHelper.SetColor(titleFontString, RGP_CONSTANTS.COLOR.TITLE_GOLD)
  titleFontString:SetText(rgp.L["options_title"])

  BuildCheckButtonOption(
    frame,
    RGP_CONSTANTS.ELEMENT_GENERAL_OPT_WINDOW_LOCK_ENERGY_BAR,
    20,
    -52,
    LockWindowEnergyBarOnShow,
    LockWindowEnergyBarOnClick
  )

  BuildCheckButtonOption(
    frame,
    RGP_CONSTANTS.ELEMENT_GENERAL_OPT_SNAP_ENERGY_BAR_TO_GRID,
    20,
    -100,
    SnapEnergyBarToGridOnShow,
    SnapEnergyBarToGridOnClick
  )

  --[[
    Directly below the checkbox that governs it - and greyed out while that checkbox is
    unchecked (see UpdateGridSizeSliderState)
  ]]--
  gridSizeSlider = CreateSizeSlider(
    frame,
    RGP_CONSTANTS.ELEMENT_ENERGY_BAR_GRID_SIZE_SLIDER,
    {"TOPLEFT", 20, -160},
    RGP_CONSTANTS.ELEMENT_ENERGY_BAR_MIN_GRID_SIZE,
    RGP_CONSTANTS.ELEMENT_ENERGY_BAR_MAX_GRID_SIZE,
    mod.configuration.GetEnergyBarGridSize(),
    options.EnergyBarGridSize.label,
    options.EnergyBarGridSize.description,
    function(_, value)
      mod.configuration.SetEnergyBarGridSize(value)
      mod.alignmentGrid.Refresh()
    end,
    RGP_CONSTANTS.ELEMENT_ENERGY_BAR_GRID_SIZE_SLIDER_STEP
  )

  UpdateGridSizeSliderState()

  CreateSizeSlider(
    frame,
    RGP_CONSTANTS.ELEMENT_ENERGY_BAR_WIDTH_SLIDER,
    {"TOPLEFT", 20, -250},
    RGP_CONSTANTS.ELEMENT_ENERGY_BAR_MIN_WIDTH,
    RGP_CONSTANTS.ELEMENT_ENERGY_BAR_MAX_WIDTH,
    mod.configuration.GetEnergyBarWidth(),
    options.EnergyBarWidth.label,
    options.EnergyBarWidth.description,
    function(_, value)
      mod.configuration.SetEnergyBarWidth(value)
      mod.energyBar.UpdateEnergyBarSize()
    end,
    RGP_CONSTANTS.ELEMENT_ENERGY_BAR_SIZE_SLIDER_STEP
  )

  CreateSizeSlider(
    frame,
    RGP_CONSTANTS.ELEMENT_ENERGY_BAR_HEIGHT_SLIDER,
    {"TOPLEFT", 20, -340},
    RGP_CONSTANTS.ELEMENT_ENERGY_BAR_MIN_HEIGHT,
    RGP_CONSTANTS.ELEMENT_ENERGY_BAR_MAX_HEIGHT,
    mod.configuration.GetEnergyBarHeight(),
    options.EnergyBarHeight.label,
    options.EnergyBarHeight.description,
    function(_, value)
      mod.configuration.SetEnergyBarHeight(value)
      mod.energyBar.UpdateEnergyBarSize()
    end,
    RGP_CONSTANTS.ELEMENT_ENERGY_BAR_SIZE_SLIDER_STEP
  )

  --[[
    Placing the bar cannot happen from here - this panel covers the screen the bar sits on.
    The button hands over to the positioning mode, which closes the panel first
  ]]--
  mod.uiHelper.CreateButton(
    frame,
    RGP_CONSTANTS.ELEMENT_GENERAL_MOVE_BAR_BUTTON,
    {"TOPLEFT", 20, -430},
    RGP_CONSTANTS.ELEMENT_POSITIONING_HUD_BUTTON_WIDTH,
    RGP_CONSTANTS.ELEMENT_POSITIONING_HUD_BUTTON_HEIGHT,
    rgp.L["move_bar"],
    function()
      mod.positioningMode.Enter()
    end
  )

  local moveBarDescription = frame:CreateFontString(nil, "OVERLAY")
  moveBarDescription:SetFont(STANDARD_TEXT_FONT, 12)
  mod.uiHelper.SetColor(moveBarDescription, RGP_CONSTANTS.COLOR.SUBNOTE)
  moveBarDescription:SetPoint("TOPLEFT", 24, -460)
  moveBarDescription:SetJustifyH("LEFT")
  moveBarDescription:SetText(rgp.L["move_bar_description"])

  builtMenu = true
end

--[[
  Create slider options with label formatters

  @param {number} minValue
  @param {number} maxValue
  @param {string} title
  @param {number} stepSize
    Increment between two slider values

  @return {table} configured slider options
]]--
CreateSliderOptions = function(minValue, maxValue, title, stepSize)
  local sliderOptions = Settings.CreateSliderOptions(
    minValue,
    maxValue,
    stepSize
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

  -- a locked bar cannot be moved, so the grid has nothing left to guide
  mod.alignmentGrid.Refresh()
end

--[[
  OnShow callback for checkbuttons - snap energyBar to grid

  @param {table} self
]]--
SnapEnergyBarToGridOnShow = function(self)
  if mod.configuration.IsEnergyBarGridSnapEnabled() then
    self:SetChecked(true)
  else
    self:SetChecked(false)
  end

  --[[
    Guarded against the slider not existing yet - the checkbox is built (and its OnShow
    run once) before the slider below it
  ]]--
  UpdateGridSizeSliderState()
end

--[[
  OnClick callback for checkbuttons - snap energyBar to grid

  @param {table} self
]]--
SnapEnergyBarToGridOnClick = function(self)
  local enabled = self:GetChecked()

  if enabled then
    mod.configuration.EnableEnergyBarGridSnap()
  else
    mod.configuration.DisableEnergyBarGridSnap()
  end

  UpdateGridSizeSliderState()
  mod.alignmentGrid.Refresh()
end

--[[
  Keep the grid size slider in step with the snap checkbox - a grid spacing is meaningless
  while nothing snaps to it. Driven from both the checkbox OnShow and its OnClick so the
  slider is right on the first open as well as after every toggle
]]--
UpdateGridSizeSliderState = function()
  mod.uiHelper.SetSliderEnabled(gridSizeSlider, mod.configuration.IsEnergyBarGridSnapEnabled())
end

--[[
  Create a slider for a pixel valued energyBar option (its dimensions, the grid spacing)

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
  @param {number} sliderStep
    Increment between two slider values

  @return {table}
    The created slider frame
]]--
CreateSizeSlider = function(parentFrame, sliderName, position, sliderMinValue, sliderMaxValue, defaultValue,
    sliderTitle, sliderDescription, onValueChangedCallback, sliderStep)

  local sliderOptions = CreateSliderOptions(sliderMinValue, sliderMaxValue, sliderTitle, sliderStep)

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

  return sliderFrame
end
