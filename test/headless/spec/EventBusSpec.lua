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
  Tests for the centralized event bus (code/Event.lua).

  The bus holds its registered handlers, main-frame reference and readiness flag in file-local
  state, so the module is re-dofile'd in before_each to start every test with a clean bus (per the
  bootstrap module-state convention).

  Dispatch logs every delivered event through rgp.logger.LogEvent and gated suppression through
  LogDebug. The bootstrap loads the real Logger.lua, whose print path reaches for rgp.filter and
  C_AddOns - neither exists headless - so rgp.logger is replaced with a no-op stub for the duration
  of each test and restored afterwards (it is a deep field of the shared `rgp` table that busted's
  file insulation does not snapshot).

  Setup only calls RegisterEvent on the frame it is handed, so a recording stub table stands in for
  the main frame - no WoW API is needed.
]]--

-- busted extends `assert` with .same / .equal / etc. at runtime; luacheck cannot verify those
-- fields statically. Suppress warning 143 (accessing undefined field of a global variable).
-- luacheck: globals describe it before_each after_each rgp
-- luacheck: ignore 143

describe("Event bus", function()
  local registered
  local stubFrame

  -- rgp.logger is a deep field of the shared `rgp` table; file insulation snapshots only the
  -- top-level reference, so capture and restore it to avoid leaking the stub into later specs
  local originalLogger = rgp.logger

  before_each(function()
    -- re-run code/Event.lua so each test starts with fresh handler/ready state
    dofile("code/Event.lua")

    -- the bus logs every dispatch (LogEvent) and gated suppression (LogDebug); no-ops keep the
    -- real logger's chat prints and rgp.filter/C_AddOns lookups out of the tests
    rgp.logger = {
      LogEvent = function() end,
      LogDebug = function() end
    }

    registered = {}
    stubFrame = {
      RegisterEvent = function(_, eventName)
        registered[eventName] = true
      end,
    }
  end)

  after_each(function()
    rgp.logger = originalLogger
  end)

  it("Setup registers every declared event on the frame", function()
    rgp.event.Register("PLAYER_LOGIN", function() end)
    rgp.event.Register("UNIT_POWER_UPDATE", function() end)

    rgp.event.Setup(stubFrame)

    assert.is_true(registered["PLAYER_LOGIN"])
    assert.is_true(registered["UNIT_POWER_UPDATE"])
  end)

  it("Dispatch invokes the matching handler with the event varargs", function()
    local received

    rgp.event.Register("CUSTOM_EVENT", function(a, b)
      received = { a, b }
    end)

    rgp.event.Dispatch("CUSTOM_EVENT", "unit", 42)

    assert.same({ "unit", 42 }, received)
  end)

  it("Register accepts an array of events sharing one handler", function()
    local calls = 0

    rgp.event.Register({ "EVENT_A", "EVENT_B", "EVENT_C" }, function()
      calls = calls + 1
    end)

    rgp.event.Setup(stubFrame)

    assert.is_true(registered["EVENT_A"])
    assert.is_true(registered["EVENT_B"])
    assert.is_true(registered["EVENT_C"])

    rgp.event.Dispatch("EVENT_A")
    rgp.event.Dispatch("EVENT_C")

    assert.equal(2, calls)
  end)

  it("Dispatch ignores an unregistered event", function()
    assert.has_no.errors(function()
      rgp.event.Dispatch("UNREGISTERED_EVENT")
    end)
  end)

  it("ungated handlers fire before SetReady", function()
    local calls = 0

    rgp.event.Register("UNGATED", function() calls = calls + 1 end)

    rgp.event.Dispatch("UNGATED")

    assert.equal(1, calls)
  end)

  it("gated handlers are suppressed until SetReady, then fire", function()
    local calls = 0

    rgp.event.Register("GATED", function() calls = calls + 1 end, { gated = true })

    rgp.event.Dispatch("GATED")
    assert.equal(0, calls)

    rgp.event.SetReady()

    rgp.event.Dispatch("GATED")
    assert.equal(1, calls)
  end)
end)
