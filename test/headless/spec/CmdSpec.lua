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
  Tests for the slash-command dispatch (code/Cmd.lua).

  SetupSlashCmdList registers the /rgp and /pulse tokens and installs HandleSlashCommand as the
  PULSE handler. HandleSlashCommand splits the message on whitespace and routes the first token:
  empty / "help" / no args -> ShowInfoMessage (three chat prints); "rl" / "reload" -> ReloadUI;
  "opt" -> addonConfiguration.OpenMainCategory; anything else -> logger.PrintUserError. The handler
  is file-local (only reachable through SlashCmdList["PULSE"]), so each spec installs the registry
  via SetupSlashCmdList and dispatches through the captured handler.

  The WoW globals it touches (SlashCmdList, SLASH_PULSE1/2, ReloadUI, print) are installed via
  WowStubs and restored afterwards. The collaborators it reaches through `rgp` (logger,
  addonConfiguration, the L localization table) are absent in the headless bootstrap, so they are
  installed as recording stubs and restored -- they are deep fields of the shared `rgp` table that
  busted's file insulation does not snapshot. The module is re-dofile'd in before_each per the
  bootstrap module-state convention.
]]--

-- busted extends `assert` with .same / .equal / etc. at runtime; luacheck cannot verify those
-- fields statically. Suppress warning 143 (accessing undefined field of a global variable).
-- luacheck: globals describe it before_each after_each rgp SLASH_PULSE1 SLASH_PULSE2 SlashCmdList
-- luacheck: ignore 143

local wowStubs = require("WowStubs")

describe("Cmd", function()
  local cmd
  local handle
  local restore
  local prints
  local userErrors
  local reloadCalls
  local openCalls

  -- rgp.logger / rgp.addonConfiguration / rgp.L are deep fields of the shared `rgp` table; file
  -- insulation snapshots only the top-level reference, so capture and restore them to avoid leaking
  -- the stubs into later specs (addonConfiguration and L do not exist in the bootstrap -> nil).
  local originalLogger = rgp.logger
  local originalAddonConfiguration = rgp.addonConfiguration
  local originalL = rgp.L

  before_each(function()
    prints = {}
    userErrors = {}
    reloadCalls = 0
    openCalls = 0

    -- SLASH_PULSE1/2 are assigned by SetupSlashCmdList; installing them (as false) lets restore put
    -- the headless-absent globals back to their original (nil) afterwards.
    restore = wowStubs.install({
      SlashCmdList = {},
      SLASH_PULSE1 = false,
      SLASH_PULSE2 = false,
      ReloadUI = function() reloadCalls = reloadCalls + 1 end,
      print = function(msg) prints[#prints + 1] = msg end
    })

    rgp.logger = {
      LogDebug = function() end,
      PrintUserError = function(msg) userErrors[#userErrors + 1] = msg end
    }
    rgp.addonConfiguration = { OpenMainCategory = function() openCalls = openCalls + 1 end }
    -- ShowInfoMessage / the error path read several L keys; fall back to the key name for any other
    rgp.L = setmetatable({
      info_title = "Pulse",
      reload = "reload help",
      opt = "opt help",
      invalid_argument = "invalid argument"
    }, { __index = function(_, key) return key end })

    -- re-run code/Cmd.lua to get a fresh module, then register and capture the slash handler
    dofile("code/Cmd.lua")
    cmd = rgp.cmd
    cmd.SetupSlashCmdList()
    handle = SlashCmdList["PULSE"]
  end)

  after_each(function()
    restore()
    rgp.logger = originalLogger
    rgp.addonConfiguration = originalAddonConfiguration
    rgp.L = originalL
  end)

  describe("SetupSlashCmdList", function()
    it("registers the /rgp and /pulse tokens and the PULSE handler", function()
      assert.are.equal("/rgp", SLASH_PULSE1)
      assert.are.equal("/pulse", SLASH_PULSE2)
      assert.is_function(SlashCmdList["PULSE"])
    end)
  end)

  describe("HandleSlashCommand", function()
    it("shows the info message for no argument", function()
      handle("")
      -- ShowInfoMessage prints the title plus the two help lines
      assert.are.equal(3, #prints)
      assert.are.equal(0, reloadCalls)
      assert.are.equal(0, openCalls)
    end)

    it("shows the info message for the 'help' argument", function()
      handle("help")
      assert.are.equal(3, #prints)
    end)

    it("reloads the UI for 'rl'", function()
      handle("rl")
      assert.are.equal(1, reloadCalls)
    end)

    it("reloads the UI for 'reload'", function()
      handle("reload")
      assert.are.equal(1, reloadCalls)
    end)

    it("opens the options category for 'opt'", function()
      handle("opt")
      assert.are.equal(1, openCalls)
    end)

    it("dispatches on the first token and ignores trailing arguments", function()
      handle("rl now please")
      assert.are.equal(1, reloadCalls)
      assert.are.equal(0, openCalls)
    end)

    it("reports a user error for an unknown argument", function()
      handle("bogus")
      assert.are.equal(1, #userErrors)
      assert.are.equal("invalid argument", userErrors[1])
      assert.are.equal(0, reloadCalls)
      assert.are.equal(0, openCalls)
    end)
  end)
end)
