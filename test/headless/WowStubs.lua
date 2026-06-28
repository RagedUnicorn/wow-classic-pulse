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
  Opt-in registry of WoW-global stubs.

  This is deliberately NOT a full Blizzard API mock. A spec requires this module and pulls only the
  stubs it needs, installs them onto the global table for the duration of the test, then restores
  the previous values so nothing leaks across specs. The Bootstrap helper prepends test/headless to
  package.path so this resolves as `require("WowStubs")`.

  Usage:
    local wowStubs = require("WowStubs")

    local restore
    before_each(function()
      restore = wowStubs.install({
        C_AddOns = wowStubs.stubs.C_AddOns({ Title = "Pulse" }),
        GetLocale = wowStubs.stubs.GetLocale("enUS"),
      })
    end)
    after_each(function() restore() end)

  `install` also accepts any ad-hoc stub the registry does not provide, e.g.
    wowStubs.install({ SomeApi = function() return 42 end })
]]--

local M = {}

--[[
  Install a table of name -> value stubs onto the global table.

  @param {table} stubs
    map of global name to stub value (function, table, ...)

  @return {function}
    a restore function that puts the previous global values back (including nil for globals that
    did not previously exist). Call it from after_each.
]]--
function M.install(stubs)
  local previous = {}
  local names = {}

  for name, value in pairs(stubs) do
    previous[name] = _G[name]
    names[#names + 1] = name
    _G[name] = value
  end

  return function()
    for _, name in ipairs(names) do
      _G[name] = previous[name]
    end
  end
end

--[[
  Ready-made stub builders for the WoW globals the Pulse specs touch. Each returns a fresh stub
  configured by its arguments; add more here as new specs need them.
]]--
M.stubs = {}

--[[
  C_AddOns namespace (Logger.PrintLogMessage, Logger.PrintUserMessage). `metadata` maps the
  requested key (e.g. "Title", "Version") to the value to return.

  @param {table} metadata
  @return {table}
]]--
function M.stubs.C_AddOns(metadata)
  metadata = metadata or {}

  return {
    GetAddOnMetadata = function(_, key)
      return metadata[key]
    end
  }
end

--[[
  UIErrorsFrame (Logger.PrintUserError) - captures messages added to it.

  @return {table}
]]--
function M.stubs.UIErrorsFrame()
  local frame = { messages = {} }

  function frame:AddMessage(message, ...)
    self.messages[#self.messages + 1] = { message = message, ... }
  end

  return frame
end

--[[
  GetLocale() -> string (localization files branch on this at load time).

  @param {string} locale
  @return {function}
]]--
function M.stubs.GetLocale(locale)
  return function()
    return locale or "enUS"
  end
end

--[[
  C_Timer namespace (Ticker.StartTickerEnergy / StopTickerEnergy). Records scheduled callbacks
  rather than running a real clock: NewTicker returns a handle exposing Cancel() and the
  _cancelled flag the Ticker module inspects, and the returned namespace exposes the captured
  tickers/timers so a spec can flush them by invoking their callbacks manually.

  @return {table}
]]--
function M.stubs.C_Timer()
  local namespace = { tickers = {}, timers = {} }

  function namespace.NewTicker(interval, callback, iterations)
    local handle = {
      interval = interval,
      callback = callback,
      iterations = iterations,
      _cancelled = false
    }

    function handle:Cancel()
      self._cancelled = true
    end

    namespace.tickers[#namespace.tickers + 1] = handle

    return handle
  end

  function namespace.After(delay, callback)
    namespace.timers[#namespace.timers + 1] = { delay = delay, callback = callback }
  end

  return namespace
end

return M
