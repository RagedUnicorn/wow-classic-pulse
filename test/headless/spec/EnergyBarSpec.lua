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
  Tests for the grid-snap arithmetic of the energyBar mover (gui/EnergyBar.lua).

  Everything else in that module needs a live frame (CreateFrame, drag scripts, the sweep
  ticker) and is verified in-game. me.SnapValueToGrid is deliberately pure so the rounding
  rule - the part that is easy to get wrong at the half-step and for negative coordinates -
  can be pinned down headlessly. The file has no WoW globals at load scope, so a plain dofile
  is enough; rgp.energyBar is a deep field of the shared rgp table that busted's file
  insulation does not roll back, hence the restore in after_each.
]]--

-- busted extends `assert` with .same / .equal / etc. at runtime; luacheck cannot verify those
-- fields statically. Suppress warning 143 (accessing undefined field of a global variable).
-- luacheck: globals describe it before_each after_each rgp
-- luacheck: ignore 143

describe("EnergyBar", function()
  local energyBar
  local originalEnergyBar = rgp.energyBar

  before_each(function()
    dofile("gui/EnergyBar.lua")
    energyBar = rgp.energyBar
  end)

  after_each(function()
    rgp.energyBar = originalEnergyBar
  end)

  describe("SnapValueToGrid", function()
    it("leaves a value that already sits on the grid untouched", function()
      assert.are.equal(0, energyBar.SnapValueToGrid(0, 10))
      assert.are.equal(10, energyBar.SnapValueToGrid(10, 10))
      assert.are.equal(250, energyBar.SnapValueToGrid(250, 10))
    end)

    it("rounds to the nearest grid multiple", function()
      assert.are.equal(10, energyBar.SnapValueToGrid(12.4, 10))
      assert.are.equal(20, energyBar.SnapValueToGrid(17.6, 10))
      assert.are.equal(500, energyBar.SnapValueToGrid(502.3, 10))
    end)

    it("rounds a value exactly between two grid lines upwards", function()
      assert.are.equal(20, energyBar.SnapValueToGrid(15, 10))
      assert.are.equal(10, energyBar.SnapValueToGrid(7.5, 5))
    end)

    it("rounds negative coordinates towards the nearest line, not towards zero", function()
      assert.are.equal(-10, energyBar.SnapValueToGrid(-12.4, 10))
      assert.are.equal(-20, energyBar.SnapValueToGrid(-17.6, 10))
      -- the half step goes up here too: -15 is as close to -10 as it is to -20
      assert.are.equal(-10, energyBar.SnapValueToGrid(-15, 10))
    end)

    it("honours the configured grid size", function()
      assert.are.equal(1173, energyBar.SnapValueToGrid(1173.4, 1))
      assert.are.equal(1175, energyBar.SnapValueToGrid(1173.4, 5))
      assert.are.equal(1150, energyBar.SnapValueToGrid(1173.4, 50))
    end)

    it("returns the value unchanged for a grid size that cannot be snapped to", function()
      -- guards against a division by zero / an inverted grid reaching the mover
      assert.are.equal(12.4, energyBar.SnapValueToGrid(12.4, 0))
      assert.are.equal(12.4, energyBar.SnapValueToGrid(12.4, -10))
      assert.are.equal(12.4, energyBar.SnapValueToGrid(12.4, nil))
    end)
  end)
end)
