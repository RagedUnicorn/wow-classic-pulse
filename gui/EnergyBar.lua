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
local SnapFrameToGrid
local IsDragAllowed

--[[
  Time when the last energyTick happened
]]--
local lastTick = 0
--[[
  Last saved energyValue. Starts at -1 so the first ticker update always writes the energy text
]]--
local lastEnergyValue = -1
--[[
  Whether the energyBar was already shown when a size preview started. Used by
  me.HidePreview to decide whether to hide it again on preview end
]]--
local wasShownBeforePreview = false
--[[
  Whether me.ShowPreview started the ticker itself (bar was hidden). Used by
  me.HidePreview to only stop a ticker the preview owns
]]--
local previewStartedTicker = false
--[[
  Whether a preview is currently forcing the bar visible. Makes the Show/HidePreview pair
  idempotent: the options panel and the positioning mode can both ask for a preview, and
  the mode takes over an already running one (the panel closes on its way in). Without this
  the second ShowPreview would re-capture wasShownBeforePreview from the previewed state and
  the bar would never be restored to hidden
]]--
local previewActive = false

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
  local energyStatusBar = CreateFrame(
    "StatusBar",
    RGP_CONSTANTS.ELEMENT_ENERGY_BAR_STATUS_BAR,
    frame,
    "BackdropTemplate"
  )
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
  Force the energyBar visible for a live size preview (e.g. while the options
  panel with the width/height sliders is open). Remembers the prior shown state
  and, only when the bar was hidden, starts the sweep ticker so the preview is
  lively. Reversed by me.HidePreview
]]--
function me.ShowPreview()
  if not energyBarFrame then return end

  previewActive = true
  wasShownBeforePreview = energyBarFrame:IsShown()
  energyBarFrame:Show()

  if not wasShownBeforePreview then
    mod.ticker.StartTickerEnergy()
    previewStartedTicker = true
  end
end

--[[
  End a size preview started by me.ShowPreview. Restores the bar to hidden and
  stops the ticker only when the preview itself showed the bar and started the
  ticker - a bar that was already shown (and its running ticker) is left alone
]]--
function me.HidePreview()
  if not energyBarFrame then return end
  if not previewActive then return end

  previewActive = false

  if not wasShownBeforePreview then
    energyBarFrame:Hide()

    if previewStartedTicker then
      mod.ticker.StopTickerEnergy()
    end
  end

  previewStartedTicker = false
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
  Whether the bar may be dragged right now. The lock keeps the bar from being nudged by a
  stray click during play, but entering the positioning mode is a deliberate "I want to
  move this" - so the mode overrides the lock instead of forcing the user to find and
  toggle a second setting first. The lock setting itself is never changed by the mode.

  @return {boolean}
]]--
IsDragAllowed = function()
  return mod.positioningMode.IsActive() or not mod.configuration.IsEnergyBarLocked()
end

--[[
  Frame callback to start moving the passed (self) frame

  @param {table} self
]]--
StartDragFrame = function(self)
  if not IsDragAllowed() then return end

  self:StartMoving()
end

--[[
  Frame callback to stop moving the passed (self) frame

  @param {table} self
]]--
StopDragFrame = function(self)
  if not IsDragAllowed() then return end

  self:StopMovingOrSizing()

  if mod.configuration.IsEnergyBarGridSnapEnabled() then
    SnapFrameToGrid(self)
  end

  local point, relativeTo, relativePoint, posX, posY = self:GetPoint()

  --[[
    GetPoint returns relativeTo as a region reference. Only its name (or nil for
    anonymous regions) may be persisted - PulseConfiguration.frames is exported
    via profiles and must stay serializable.
  ]]--
  mod.configuration.SaveUserPlacedFramePosition(
    RGP_CONSTANTS.ELEMENT_ENERGY_BAR_FRAME,
    point,
    relativeTo and relativeTo:GetName() or nil,
    relativePoint,
    posX,
    posY
  )
end

--[[
  Round a coordinate onto the nearest multiple of the alignment grid. Pure arithmetic -
  exposed on the module so the headless spec can exercise it without a WoW client. A
  gridSize that is not a positive number leaves the value untouched

  @param {number} value
  @param {number} gridSize

  @return {number}
]]--
function me.SnapValueToGrid(value, gridSize)
  if type(gridSize) ~= "number" or gridSize <= 0 then return value end

  return math.floor(value / gridSize + 0.5) * gridSize
end

--[[
  Re-anchor a dropped frame onto the alignment grid.

  It is the frame's top left corner that lands on an intersection, not its center. With
  the grid drawn on screen the user aligns what they can see - an edge touching a line -
  and a centered snap would leave both visible edges half a bar off every line unless the
  bar's size happened to be a multiple of the grid size.

  The frame is normalized to a TOPLEFT / UIParent BOTTOMLEFT anchor before the offsets are
  rounded: whatever anchor the drag left behind, the persisted position is then a
  deterministic, serializable screen coordinate (profiles carry it) and the grid means the
  same thing no matter where the bar was dragged from.

  @param {table} frame
]]--
SnapFrameToGrid = function(frame)
  local left = frame:GetLeft()
  local top = frame:GetTop()

  --[[
    Both return nil for a frame that has no resolved rect yet - nothing to snap
  ]]--
  if left == nil or top == nil then return end

  local gridSize = mod.configuration.GetEnergyBarGridSize()

  frame:ClearAllPoints()
  frame:SetPoint(
    "TOPLEFT",
    UIParent,
    "BOTTOMLEFT",
    me.SnapValueToGrid(left, gridSize),
    me.SnapValueToGrid(top, gridSize)
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

  if currentEnergy ~= lastEnergyValue then
    energyBarFrame.energyAmount:SetText(currentEnergy)
  end

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
