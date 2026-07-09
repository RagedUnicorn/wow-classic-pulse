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
  Tests for the energyBar update ticker (code/Ticker.lua).

  Ticker is a thin guard around C_Timer: StartTickerEnergy creates a repeating ticker only when none
  is live (energyBarTicker nil or already cancelled), StopTickerEnergy cancels a live one. The live
  handle is held in a file-local `energyBarTicker`, so the module is re-dofile'd in before_each to
  reset that state (per the bootstrap module-state convention).

  C_Timer is pulled from the WowStubs registry: its NewTicker records each handle on
  `timer.tickers` and exposes the Cancel()/IsCancelled() pair the guard uses, so the specs can
  count creations and flip the cancelled flag without a real clock. mod.energyBar (the ticker
  callback target) and mod.logger (LogInfo) are not present in the headless bootstrap, so both are
  installed as recording stubs and restored afterwards -- they are deep fields of the shared `rgp`
  table that busted's file insulation does not snapshot.
]]--

-- busted extends `assert` with .same / .equal / etc. at runtime; luacheck cannot verify those
-- fields statically. Suppress warning 143 (accessing undefined field of a global variable).
-- luacheck: globals describe it before_each after_each rgp RGP_CONSTANTS
-- luacheck: ignore 143

local wowStubs = require("WowStubs")

describe("Ticker", function()
  local ticker
  local timer
  local restore
  local updateCalls

  -- rgp.logger / rgp.energyBar are deep fields of the shared `rgp` table; file insulation snapshots
  -- only the top-level reference, so capture and restore them to avoid leaking the stubs into later
  -- specs (rgp.energyBar does not exist in the bootstrap, so its original is nil).
  local originalLogger = rgp.logger
  local originalEnergyBar = rgp.energyBar

  before_each(function()
    timer = wowStubs.stubs.C_Timer()
    restore = wowStubs.install({ C_Timer = timer })

    -- record callback invocations on the ticker target
    updateCalls = 0
    rgp.energyBar = { UpdateTickerBar = function() updateCalls = updateCalls + 1 end }

    -- Ticker only logs through LogInfo; a no-op keeps the chat prints out of the test output
    rgp.logger = { LogInfo = function() end }

    -- re-run code/Ticker.lua to reset the file-local energyBarTicker handle
    dofile("code/Ticker.lua")
    ticker = rgp.ticker
  end)

  after_each(function()
    restore()
    rgp.logger = originalLogger
    rgp.energyBar = originalEnergyBar
  end)

  it("creates the ticker once and does not double-start while one is live", function()
    ticker.StartTickerEnergy()
    assert.are.equal(1, #timer.tickers)

    -- second start is guarded by the live (non-cancelled) handle: no new ticker
    ticker.StartTickerEnergy()
    assert.are.equal(1, #timer.tickers)
  end)

  it("passes the configured interval and the energyBar update callback to C_Timer", function()
    ticker.StartTickerEnergy()

    local handle = timer.tickers[1]
    assert.are.equal(RGP_CONSTANTS.ENERGY_BAR_UPDATE_INTERVAL, handle.interval)

    -- the registered callback drives energyBar.UpdateTickerBar
    handle.callback()
    assert.are.equal(1, updateCalls)
  end)

  it("StopTickerEnergy cancels the live ticker, and a later start creates a fresh one", function()
    ticker.StartTickerEnergy()
    local first = timer.tickers[1]
    assert.is_false(first:IsCancelled())

    ticker.StopTickerEnergy()
    assert.is_true(first:IsCancelled())

    -- the previous handle is cancelled, so the guard allows a brand new ticker
    ticker.StartTickerEnergy()
    assert.are.equal(2, #timer.tickers)
  end)

  it("StopTickerEnergy is a no-op when no ticker is live", function()
    -- fresh module: energyBarTicker is nil, so Stop must not error or cancel anything
    assert.has_no.errors(function() ticker.StopTickerEnergy() end)
    assert.are.equal(0, #timer.tickers)
  end)

  it("does not leak the live ticker between it() blocks", function()
    -- if the previous block's handle leaked, the guard would suppress this first start
    ticker.StartTickerEnergy()
    assert.are.equal(1, #timer.tickers)
  end)
end)
