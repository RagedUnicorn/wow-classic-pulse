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

--[[
  Tests for the decision and geometry of the alignment grid overlay (gui/AlignmentGrid.lua).

  Everything that touches a frame - creating the overlay, acquiring pooled Line objects,
  pixel snapping the thickness - needs a WoW client and is verified in-game. The two parts
  that carry the actual rules are deliberately pure and exposed on the module:
  ShouldShowGrid (when the overlay belongs on screen) and CalculateGridLines (where the
  lines go). The file has no WoW globals at load scope, so a plain dofile is enough;
  rgp.alignmentGrid is a deep field of the shared rgp table that busted's file insulation
  does not roll back, hence the restore in after_each.
]]--

-- busted extends `assert` with .same / .equal / etc. at runtime; luacheck cannot verify those
-- fields statically. Suppress warning 143 (accessing undefined field of a global variable).
-- luacheck: globals describe it before_each after_each rgp
-- luacheck: ignore 143

describe("AlignmentGrid", function()
  local alignmentGrid
  local originalAlignmentGrid = rgp.alignmentGrid

  before_each(function()
    dofile("gui/AlignmentGrid.lua")
    alignmentGrid = rgp.alignmentGrid
  end)

  after_each(function()
    rgp.alignmentGrid = originalAlignmentGrid
  end)

  describe("ShouldShowGrid", function()
    it("shows the grid while placing the bar with snapping enabled", function()
      assert.is_true(alignmentGrid.ShouldShowGrid(true, true))
    end)

    it("hides the grid when snapping is disabled", function()
      -- a grid the bar does not snap to would be a lie
      assert.is_false(alignmentGrid.ShouldShowGrid(false, true))
    end)

    it("hides the grid outside the positioning mode", function()
      -- the regression this rule exists for: a grid painted over normal gameplay
      assert.is_false(alignmentGrid.ShouldShowGrid(true, false))
    end)

    it("hides the grid when nothing is set at all", function()
      assert.is_false(alignmentGrid.ShouldShowGrid(false, false))
      assert.is_false(alignmentGrid.ShouldShowGrid(nil, nil))
    end)
  end)

  describe("CalculateGridLines", function()
    it("spaces the lines by the grid size, starting at the bottom left corner", function()
      local lines = alignmentGrid.CalculateGridLines(100, 50, 10)

      assert.are.equal(11, #lines.vertical)
      assert.are.equal(6, #lines.horizontal)
      assert.are.equal(0, lines.vertical[1].offset)
      assert.are.equal(10, lines.vertical[2].offset)
      assert.are.equal(100, lines.vertical[11].offset)
      assert.are.equal(50, lines.horizontal[6].offset)
    end)

    it("flags the line closest to the middle of each axis as the center axis", function()
      local lines = alignmentGrid.CalculateGridLines(100, 50, 10)
      local flaggedVertical = {}

      for _, line in ipairs(lines.vertical) do
        if line.axis then flaggedVertical[#flaggedVertical + 1] = line.offset end
      end

      -- exactly one axis line per direction, and it is the one nearest the middle
      assert.are.same({ 50 }, flaggedVertical)
      -- 25 is the middle of the 50 high axis; the tie between 20 and 30 rounds up
      assert.is_true(lines.horizontal[4].axis)
      assert.are.equal(30, lines.horizontal[4].offset)
    end)

    it("stops before the edge when the grid size does not divide the area", function()
      local lines = alignmentGrid.CalculateGridLines(105, 105, 10)

      -- no line is ever drawn past the drawing area
      assert.are.equal(11, #lines.vertical)
      assert.are.equal(100, lines.vertical[#lines.vertical].offset)
    end)

    it("returns no lines for a grid size that cannot be gridded", function()
      for _, gridSize in ipairs({ 0, -10 }) do
        local lines = alignmentGrid.CalculateGridLines(100, 50, gridSize)

        assert.are.same({}, lines.vertical)
        assert.are.same({}, lines.horizontal)
      end

      local missing = alignmentGrid.CalculateGridLines(100, 50, nil)

      assert.are.same({}, missing.vertical)
      assert.are.same({}, missing.horizontal)
    end)

    it("returns no lines for a drawing area that has no extent yet", function()
      -- a frame whose rect is not resolved reports 0 - never divide the screen into nothing
      local lines = alignmentGrid.CalculateGridLines(0, 0, 10)

      assert.are.same({}, lines.vertical)
      assert.are.same({}, lines.horizontal)
      assert.are.same({}, alignmentGrid.CalculateGridLines(nil, nil, 10).vertical)
    end)
  end)
end)
