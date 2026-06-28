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
  Tests for the log-filter blacklist (code/Filter.lua).

  Filter is pure table mutation plus string.match over a module-local `filters` list -- no WoW
  API. The `filters` table is file-local and persists across it() blocks, so the module is
  re-dofile'd in before_each to reset the registry (per the bootstrap module-state convention).
]]--

-- busted extends `assert` with .same / .equal / etc. at runtime; luacheck cannot verify those
-- fields statically. Suppress warning 143 (accessing undefined field of a global variable).
-- luacheck: globals describe it before_each
-- luacheck: ignore 143

describe("Filter", function()
  local filter

  before_each(function()
    -- re-run code/Filter.lua to get a fresh `me` (rgp.filter) backed by an empty `filters` list
    dofile("code/Filter.lua")
    filter = rgp.filter
  end)

  it("does not filter any tag on an empty registry", function()
    assert.is_false(filter.ShouldFilterTag("Energy"))
  end)

  it("filters a tag matched by a literal-string filter, and only that tag", function()
    filter.RegisterFilter("energy", "Energy")

    assert.is_true(filter.ShouldFilterTag("Energy"))
    assert.is_false(filter.ShouldFilterTag("Mana"))
  end)

  it("filters by Lua pattern, not just literal equality", function()
    filter.RegisterFilter("energyTick", "Energy.*")

    assert.is_true(filter.ShouldFilterTag("EnergyTick"))
    assert.is_true(filter.ShouldFilterTag("Energy regenerated 20"))
    assert.is_false(filter.ShouldFilterTag("Mana"))
  end)

  it("DeregisterFilter removes one named filter and leaves the rest", function()
    filter.RegisterFilter("energy", "Energy")
    filter.RegisterFilter("mana", "Mana")

    filter.DeregisterFilter("energy")

    assert.is_false(filter.ShouldFilterTag("Energy"))
    assert.is_true(filter.ShouldFilterTag("Mana"))
  end)

  it("DeregisterFilter of an unknown name is a no-op", function()
    filter.RegisterFilter("energy", "Energy")

    filter.DeregisterFilter("doesNotExist")

    assert.is_true(filter.ShouldFilterTag("Energy"))
  end)

  it("does not bleed the registry between it() blocks", function()
    -- if the previous block's "energy" filter leaked, this empty-registry assertion would fail
    assert.is_false(filter.ShouldFilterTag("Energy"))
  end)
end)
