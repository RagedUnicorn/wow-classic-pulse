--[[
  MIT License

  Copyright (c) 2024 Michael Wiesendanger

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

-- luacheck: globals CreateFrame UIParent STANDARD_TEXT_FONT GetTime UnitPower

local mod = rgp
local me = {}

mod.energyBar = me

me.tag = "EnergyBar"

local energyBarFrame

--[[
  Time when the last energyTick happened
]]--
local lastTick
--[[
  Last saved energyValue
]]--
local lastEnergyValue = 0

function me.BuildUi()
  energyBarFrame = CreateFrame("Frame", RGP_CONSTANTS.ELEMENT_ENERGY_BAR_FRAME, UIParent, "BackdropTemplate")
  energyBarFrame:SetWidth(RGP_CONSTANTS.ELEMENT_ENERGY_BAR_WIDTH)
  energyBarFrame:SetHeight(RGP_CONSTANTS.ELEMENT_ENERGY_BAR_HEIGHT)
  energyBarFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background"
  })
  energyBarFrame:SetBackdropColor(0, 0, 0, .5)
  energyBarFrame:SetBackdropBorderColor(0, 0, 0, .8)
  energyBarFrame:SetPoint("CENTER", 0, 0)
  energyBarFrame:SetMovable(true)
  energyBarFrame:SetClampedToScreen(true)

  local framePosition = mod.configuration.GetUserPlacedFramePosition(RGP_CONSTANTS.ELEMENT_ENERGY_BAR_FRAME)
  --[[
    Set user frame position if there is one saved
  ]]--
  if framePosition ~= nil then
    energyBarFrame:ClearAllPoints()  -- very important to clear all points first
    energyBarFrame:SetPoint(
      framePosition.point,
      framePosition.relativeTo,
      framePosition.relativePoint,
      framePosition.posX,
      framePosition.posY
    )
  else
    -- initial position for first time use
    energyBarFrame:SetPoint("CENTER", 0, 0)
  end

  me.SetupDragFrame(energyBarFrame)
  energyBarFrame.energyStatusBar = me.CreateStatusBarFrame(energyBarFrame)
  energyBarFrame.energyAmount = me.CreateEnergyAmountFontString(energyBarFrame)

  energyBarFrame:Hide()
end

--[[
  @param {table} frame
]]--
function me.CreateStatusBarFrame(frame)
  local energyStatusBar = CreateFrame("StatusBar", RGP_CONSTANTS.ELEMENT_ENERGY_BAR_STATUS_BAR, frame)
  energyStatusBar:SetPoint("CENTER", frame, 0, 0)
  energyStatusBar:SetWidth(RGP_CONSTANTS.ELEMENT_ENERGY_BAR_WIDTH)
  energyStatusBar:SetHeight(RGP_CONSTANTS.ELEMENT_ENERGY_BAR_HEIGHT)
  energyStatusBar:SetStatusBarTexture("Interface\\AddOns\\Pulse\\assets\\ui_statusbar")
  energyStatusBar:SetStatusBarColor(0, 1, 0.68, 1)
  energyStatusBar:SetFrameLevel(energyStatusBar:GetFrameLevel() - 1)
  energyStatusBar:SetMinMaxValues(
    RGP_CONSTANTS.ELEMENT_ENERGY_BAR_STATUS_BAR_MIN,
    RGP_CONSTANTS.ELEMENT_ENERGY_BAR_STATUS_BAR_MAX
  )

  return energyStatusBar
end

--[[
  @param {table} frame
]]--
function me.CreateEnergyAmountFontString(frame)
  local energyAmountFontString = frame:CreateFontString(RGP_CONSTANTS.ELEMENT_ENERGY_BAR_ENERGY_AMOUNT, "OVERLAY")
  energyAmountFontString:SetFont(STANDARD_TEXT_FONT, 14)
  energyAmountFontString:SetPoint("LEFT", 5, 0)
  energyAmountFontString:SetSize(
    RGP_CONSTANTS.ELEMENT_ENERGY_BAR_ENERGY_AMOUNT_WIDTH,
    RGP_CONSTANTS.ELEMENT_ENERGY_BAR_ENERGY_AMOUNT_HEIGHT
  )

  return energyAmountFontString
end

function me.ShowEnergyBarFrame()
  energyBarFrame:Show()
end

--[[
  @param {table} frame
    the frame to attach drag handlers
]]--
function me.SetupDragFrame(frame)
  frame:SetScript("OnMouseDown", me.StartDragFrame)
  frame:SetScript("OnMouseUp", me.StopDragFrame)
end

--[[
  Frame callback to start moving the passed (self) frame

  @param {table} self
]]--
function me.StartDragFrame(self)
  if mod.configuration.IsEnergyBarLocked() then return end

  self:StartMoving()
end

--[[
  Frame callback to stop moving the passed (self) frame

  @param {table} self
]]--
function me.StopDragFrame(self)
  if mod.configuration.IsEnergyBarLocked() then return end

  self:StopMovingOrSizing()

  local point, relativeTo, relativePoint, posX, posY = self:GetPoint()

  mod.configuration.SaveUserPlacedFramePosition(
    RGP_CONSTANTS.ELEMENT_ENERGY_BAR_FRAME,
    point,
    relativeTo,
    relativePoint,
    posX,
    posY
  )
end

--[[
  Ticker callback for updating the tickerbar
]]--
function me.UpdateTickerBar()
  local currentEnergy = UnitPower(RGP_CONSTANTS.UNIT_ID_PLAYER, RGP_CONSTANTS.POWERTYPE_ENERGY[2])
  local currentTime = GetTime()

  if currentEnergy > lastEnergyValue or currentTime >= lastTick + RGP_CONSTANTS.TICK_RATE then
      lastTick = currentTime
  end

  local difference = currentTime - lastTick
  energyBarFrame.energyStatusBar:SetValue(difference)
  energyBarFrame.energyAmount:SetText(currentEnergy)

  lastEnergyValue = currentEnergy
end
