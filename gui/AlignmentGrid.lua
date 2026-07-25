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

--[[
  The on-screen alignment grid.

  Purely a visual aid for the grid snapping implemented in gui/EnergyBar.lua - it draws
  the lines the mover rounds onto so the user can see where the bar will land. Lines are
  laid out from UIParent's BOTTOMLEFT in steps of the configured grid size, matching the
  origin SnapFrameToGrid normalizes to, so a snapped bar's top left corner sits exactly on
  an intersection the user can see.

  This is the addon's own geometry. It is unrelated to Blizzard's Edit Mode grid, which
  addons cannot register a frame with.
]]--

-- luacheck: globals CreateFrame UIParent PixelUtil

local mod = rgp
local me = {}

mod.alignmentGrid = me

me.tag = "AlignmentGrid"

local gridFrame
--[[
  Reused Line objects. A rebuild re-anchors the ones it needs and hides the remainder, so
  switching to a coarser grid never leaves orphaned lines on screen and switching back
  never creates lines a previous rebuild already made. Regions cannot be destroyed once
  created, so pooling is the only way a rebuild stays free of leaks
]]--
local linePool = {}

-- forward declarations
local BuildLineAxis
local EnsureUi
local AcquireLine
local PlaceLine
local Rebuild

--[[
  Whether the grid should currently be on screen.

  Only while the user is deliberately placing the bar (see gui/PositioningMode.lua), and
  only when snapping is on - a grid the bar does not snap to would be a lie. Everything
  else follows from the mode: it force-shows the bar and allows dragging, so there is no
  separate "is the bar visible" or "is it unlocked" rule to reason about, and the grid can
  never end up painted over normal gameplay.

  Pure - exposed on the module so the headless spec can exercise it without a WoW client.

  @param {boolean} snapEnabled
  @param {boolean} isPositioning

  @return {boolean}
]]--
function me.ShouldShowGrid(snapEnabled, isPositioning)
  if not snapEnabled then return false end
  if not isPositioning then return false end

  return true
end

--[[
  Calculate the grid lines for a drawing area of the passed size.

  Offsets are measured from the bottom left corner in steps of gridSize - the same origin
  and spacing gui/EnergyBar.lua snaps the bar's top left corner to. The line closest to the
  middle of each axis is flagged so it can be drawn brighter as an orientation aid.

  Pure - exposed on the module so the headless spec can exercise it without a WoW client.

  @param {number} width
  @param {number} height
  @param {number} gridSize

  @return {table}
    { vertical = { { offset, axis }, ... }, horizontal = { { offset, axis }, ... } }
    both lists are empty for a drawing area or grid size that cannot be gridded
]]--
function me.CalculateGridLines(width, height, gridSize)
  local lines = { vertical = {}, horizontal = {} }

  if type(gridSize) ~= "number" or gridSize <= 0 then return lines end
  if type(width) ~= "number" or type(height) ~= "number" then return lines end
  if width <= 0 or height <= 0 then return lines end

  BuildLineAxis(lines.vertical, width, gridSize)
  BuildLineAxis(lines.horizontal, height, gridSize)

  return lines
end

--[[
  Append the lines of one axis to target. Indices rather than an accumulated offset keep
  the axis comparison exact for a fractional grid size.

  @param {table} target
  @param {number} extent
  @param {number} gridSize
]]--
BuildLineAxis = function(target, extent, gridSize)
  local lastIndex = math.floor(extent / gridSize)
  local axisIndex = math.floor(extent / 2 / gridSize + 0.5)

  for index = 0, lastIndex do
    target[#target + 1] = { offset = index * gridSize, axis = index == axisIndex }
  end
end

--[[
  Create the grid frame on first use. Sits on the lowest strata so it never covers the bar
  it helps align, and takes no mouse input so it cannot swallow a click meant for the game
  world.

  Built lazily rather than at login: most sessions never place the bar, and a grid that is
  never shown should not cost a frame
]]--
EnsureUi = function()
  if gridFrame ~= nil then return end

  gridFrame = CreateFrame("Frame", RGP_CONSTANTS.ELEMENT_ALIGNMENT_GRID_FRAME, UIParent)
  gridFrame:SetAllPoints(UIParent)
  gridFrame:SetFrameStrata("BACKGROUND")
  gridFrame:EnableMouse(false)
  gridFrame:Hide()
end

--[[
  Bring the grid in line with the current configuration and positioning state. The single
  entry point for every caller - the options panel, the positioning mode and the display
  size events all just call this
]]--
function me.Refresh()
  local shouldShow = me.ShouldShowGrid(
    mod.configuration.IsEnergyBarGridSnapEnabled(),
    mod.positioningMode.IsActive()
  )

  if not shouldShow then
    -- nothing to hide while the grid was never needed in the first place
    if gridFrame ~= nil then
      gridFrame:Hide()
    end

    return
  end

  EnsureUi()
  Rebuild()
  gridFrame:Show()
end

--[[
  Lay the line textures out for the current grid size and screen size
]]--
Rebuild = function()
  --[[
    Measured off UIParent rather than the grid frame itself. The grid is anchored to fill
    UIParent, so the numbers are the same - but UIParent's rect is always resolved, while a
    frame created moments earlier may not have one yet, and a zero size would silently
    produce a grid with no lines in it
  ]]--
  local lines = me.CalculateGridLines(
    UIParent:GetWidth(),
    UIParent:GetHeight(),
    mod.configuration.GetEnergyBarGridSize()
  )
  --[[
    Snap the line thickness to whole device pixels for the current ui scale, otherwise a
    one pixel line renders blurred at most scales
  ]]--
  local thickness = PixelUtil.GetNearestPixelSize(
    RGP_CONSTANTS.ELEMENT_ALIGNMENT_GRID_LINE_THICKNESS,
    gridFrame:GetEffectiveScale(),
    RGP_CONSTANTS.ELEMENT_ALIGNMENT_GRID_LINE_THICKNESS
  )
  local used = 0

  for _, line in ipairs(lines.vertical) do
    used = used + 1
    PlaceLine(AcquireLine(used), line, true, thickness)
  end

  for _, line in ipairs(lines.horizontal) do
    used = used + 1
    PlaceLine(AcquireLine(used), line, false, thickness)
  end

  -- retire whatever a previous, denser grid left behind
  for index = used + 1, #linePool do
    linePool[index]:Hide()
  end

  mod.logger.LogDebug(me.tag, "Rebuilt the alignment grid with " .. used .. " lines")
end

--[[
  Get the pooled line at index, creating it on first use

  @param {number} index

  @return {table}
]]--
AcquireLine = function(index)
  local line = linePool[index]

  if line == nil then
    line = gridFrame:CreateLine(nil, "BACKGROUND")
    linePool[index] = line
  end

  return line
end

--[[
  Anchor one line across the full width or height of the grid frame. A Line is defined by
  its two endpoints, so it needs no size math and follows the frame when the screen
  changes underneath it

  @param {table} line
  @param {table} lineSpec
    one entry as produced by me.CalculateGridLines
  @param {boolean} isVertical
  @param {number} thickness
]]--
PlaceLine = function(line, lineSpec, isVertical, thickness)
  local color = lineSpec.axis
    and RGP_CONSTANTS.ELEMENT_ALIGNMENT_GRID_AXIS_COLOR
    or RGP_CONSTANTS.ELEMENT_ALIGNMENT_GRID_LINE_COLOR

  line:SetColorTexture(color[1], color[2], color[3], color[4])
  line:SetThickness(thickness)

  if isVertical then
    line:SetStartPoint("BOTTOMLEFT", gridFrame, lineSpec.offset, 0)
    line:SetEndPoint("TOPLEFT", gridFrame, lineSpec.offset, 0)
  else
    line:SetStartPoint("BOTTOMLEFT", gridFrame, 0, lineSpec.offset)
    line:SetEndPoint("BOTTOMRIGHT", gridFrame, 0, lineSpec.offset)
  end

  line:Show()
end
