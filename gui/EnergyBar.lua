--[[
  MIT License

  Copyright (c) 2025 Michael Wiesendanger

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

-- forward declarations
local CreateStatusBarFrame
local CreateEnergyAmountFontString
local SetupDragFrame
local StartDragFrame
local StopDragFrame

--[[
  Time when the last energyTick happened
]]--
local lastTick = 0
--[[
  Last saved energyValue
]]--
local lastEnergyValue = 0

function me.BuildUi()
  energyBarFrame = CreateFrame("Frame", RGP_CONSTANTS.ELEMENT_ENERGY_BAR_FRAME, UIParent, "BackdropTemplate")
  energyBarFrame:SetWidth(mod.configuration.GetEnergyBarWidth())
  energyBarFrame:SetHeight(mod.configuration.GetEnergyBarHeight())
  energyBarFrame:SetBackdrop({
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
    tile = false,
    edgeSize = 2,
    insets = { left = -2, right = -2, top = -2, bottom = -2 }
  })
  energyBarFrame:SetBackdropColor(0, 0, 0, 0)
  energyBarFrame:SetBackdropBorderColor(0, 0, 0, 1)
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

  SetupDragFrame(energyBarFrame)
  energyBarFrame.energyStatusBar = CreateStatusBarFrame(energyBarFrame)
  energyBarFrame.energyAmount = CreateEnergyAmountFontString(energyBarFrame)

  energyBarFrame:Hide()
end

--[[
  @param {table} frame
]]--
CreateStatusBarFrame = function(frame)
  local energyStatusBar = CreateFrame("StatusBar", RGP_CONSTANTS.ELEMENT_ENERGY_BAR_STATUS_BAR, frame, "BackdropTemplate")
  energyStatusBar:SetPoint("CENTER", frame, 0, 0)
  energyStatusBar:SetWidth(mod.configuration.GetEnergyBarWidth() - 4)
  energyStatusBar:SetHeight(mod.configuration.GetEnergyBarHeight() - 4)
  energyStatusBar:SetStatusBarTexture("Interface\\AddOns\\Pulse\\assets\\ui_statusbar")
  energyStatusBar:SetStatusBarColor(1, 0.95, 0, 1)
  energyStatusBar:SetFrameLevel(energyStatusBar:GetFrameLevel() - 1)
  energyStatusBar:SetMinMaxValues(
    RGP_CONSTANTS.ELEMENT_ENERGY_BAR_STATUS_BAR_MIN,
    RGP_CONSTANTS.ELEMENT_ENERGY_BAR_STATUS_BAR_MAX
  )
  
  energyStatusBar:SetBackdrop({
    bgFile = "",
    edgeFile = "",
    tile = false,
    edgeSize = 0,
    insets = { left = 0, right = 0, top = 0, bottom = 0 }
  })

  return energyStatusBar
end

--[[
  @param {table} frame
]]--
CreateEnergyAmountFontString = function(frame)
  local energyAmountFontString = frame:CreateFontString(RGP_CONSTANTS.ELEMENT_ENERGY_BAR_ENERGY_AMOUNT, "OVERLAY")
  energyAmountFontString:SetFont(STANDARD_TEXT_FONT, 16, "OUTLINE")
  energyAmountFontString:SetPoint("CENTER", 0, 0)
  energyAmountFontString:SetSize(
    mod.configuration.GetEnergyBarWidth(),
    mod.configuration.GetEnergyBarHeight()
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
SetupDragFrame = function(frame)
  frame:SetScript("OnMouseDown", StartDragFrame)
  frame:SetScript("OnMouseUp", StopDragFrame)
end

--[[
  Frame callback to start moving the passed (self) frame

  @param {table} self
]]--
StartDragFrame = function(self)
  if mod.configuration.IsEnergyBarLocked() then return end

  self:StartMoving()
end

--[[
  Frame callback to stop moving the passed (self) frame

  @param {table} self
]]--
StopDragFrame = function(self)
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

--[[
  Update the energy bar size when configuration changes
]]--
function me.UpdateEnergyBarSize()
  if not energyBarFrame then return end
  
  local width = mod.configuration.GetEnergyBarWidth()
  local height = mod.configuration.GetEnergyBarHeight()
  
  energyBarFrame:SetWidth(width)
  energyBarFrame:SetHeight(height)
  
  energyBarFrame.energyStatusBar:SetWidth(width - 4)
  energyBarFrame.energyStatusBar:SetHeight(height - 4)
  
  energyBarFrame.energyAmount:SetSize(width, height)
end
