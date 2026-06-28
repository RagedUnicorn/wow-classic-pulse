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
  Key-set parity across Pulse's localization files (localization/*.lua).

  The recurring bug this pins down: a string added to enUS but not mirrored to the other locales.
  The locale set is glob-discovered (lfs over localization/) rather than hard-coded, so a new locale
  file is picked up automatically.

  Loading mechanics: enUS.lua sets rgp.L unconditionally, while deDE.lua / ruRU.lua are wrapped in
  `if (GetLocale() == "<locale>")`. So each file is dofile'd with GetLocale() stubbed to return that
  file's locale; every file's `version` string also reads C_AddOns.GetAddOnMetadata, so C_AddOns is
  stubbed too. Both stubs come from WowStubs and are restored after each load. rgp.L is a deep field
  of the shared rgp table that busted's file insulation does not roll back, so the original (nil) is
  restored once loading is done.
]]--

-- busted extends `assert` with .same / .equal / etc. at runtime; luacheck cannot verify those
-- fields statically. Suppress warning 143 (accessing undefined field of a global variable).
-- luacheck: globals describe it rgp
-- luacheck: ignore 143

local lfs = require("lfs")
local wowStubs = require("WowStubs")

--[[
  Glob localization/*.lua and return { { path = "localization/enUS.lua", locale = "enUS" }, ... }
  sorted by locale, so the locale set is never hard-coded.
]]--
local function discoverLocaleFiles()
  local files = {}

  for entry in lfs.dir("localization") do
    local locale = entry:match("^(%w+)%.lua$")

    if locale then
      files[#files + 1] = { path = "localization/" .. entry, locale = locale }
    end
  end

  table.sort(files, function(a, b) return a.locale < b.locale end)

  return files
end

--[[
  dofile a single localization file with GetLocale / C_AddOns stubbed and return the set of keys it
  registered on rgp.L (as { ["key"] = true }).
]]--
local function loadLocaleKeys(path, locale)
  local restore = wowStubs.install({
    GetLocale = wowStubs.stubs.GetLocale(locale),
    C_AddOns = wowStubs.stubs.C_AddOns({ Version = "1.2.3" })
  })

  rgp.L = {}
  dofile(path)

  local keys = {}
  for key in pairs(rgp.L) do
    keys[key] = true
  end

  restore()

  return keys
end

--[[
  Given { [locale] = { [key] = true } }, return a sorted list of human-readable parity problems:
  every key in the union of all locales that some locale is missing. An empty list means full parity.
]]--
local function findParityProblems(localeKeys)
  local union = {}
  for _, keys in pairs(localeKeys) do
    for key in pairs(keys) do
      union[key] = true
    end
  end

  local problems = {}
  for locale, keys in pairs(localeKeys) do
    for key in pairs(union) do
      if not keys[key] then
        problems[#problems + 1] = locale .. " is missing key '" .. key .. "'"
      end
    end
  end

  table.sort(problems)

  return problems
end

describe("Localization parity", function()
  local originalL = rgp.L

  local localeFiles = discoverLocaleFiles()

  local shippedKeys = {}
  for _, file in ipairs(localeFiles) do
    shippedKeys[file.locale] = loadLocaleKeys(file.path, file.locale)
  end

  -- restore the deep field the loads above clobbered (bootstrap never set rgp.L)
  rgp.L = originalL

  it("auto-discovers the localization files via glob (not a hard-coded list)", function()
    local discovered = {}
    for _, file in ipairs(localeFiles) do
      discovered[file.locale] = true
    end

    assert.is_true(discovered.enUS)
    assert.is_true(discovered.deDE)
    assert.is_true(discovered.ruRU)
  end)

  it("loads a non-empty key set for every discovered locale", function()
    for locale, keys in pairs(shippedKeys) do
      assert.is_true(next(keys) ~= nil, locale .. " registered no keys")
    end
  end)

  it("has identical key sets across all shipped locales", function()
    -- assert.are.same gives a readable diff of the offending "locale is missing key" lines
    assert.are.same({}, findParityProblems(shippedKeys))
  end)

  it("flags a locale that carries a key the others lack", function()
    -- guards the parity check itself: a stray key in one locale must be reported as the others
    -- missing it (this is exactly the 'added to enUS, forgotten elsewhere' regression)
    local problems = findParityProblems({
      enUS = { addon_name = true, help = true },
      deDE = { addon_name = true, help = true, stray_key = true },
      ruRU = { addon_name = true, help = true }
    })

    assert.are.same(
      { "enUS is missing key 'stray_key'", "ruRU is missing key 'stray_key'" },
      problems
    )
  end)
end)
