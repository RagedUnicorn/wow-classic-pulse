--[[
  MIT License

  Copyright (c) 2025 Michael Wiesendanger

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

-- luacheck: globals DEFAULT_CHAT_FRAME SLASH_PULSE1 SLASH_PULSE2 SlashCmdList ReloadUI

local mod = rgp
local me = {}
mod.cmd = me

me.tag = "Cmd"

-- forward declarations for functions
local ShowInfoMessage
local HandleSlashCommand

--[[
  Setup slash command handler
]]--
function me.SetupSlashCmdList()
  SLASH_PULSE1 = "/rgp"
  SLASH_PULSE2 = "/pulse"

  SlashCmdList["PULSE"] = HandleSlashCommand
end

--[[
  Handle slash command parsing and execution

  @param {string} msg
    The message passed to the slash command
]]--
HandleSlashCommand = function(msg)
  local args = {}

  mod.logger.LogDebug(me.tag, "/rgp passed argument: " .. msg)

  -- parse arguments by whitespace
  for arg in string.gmatch(msg, "%S+") do
    table.insert(args, arg)
  end

  if args[1] == "" or args[1] == "help" or #args == 0 then
    ShowInfoMessage()
  elseif args[1] == "rl" or args[1] == "reload" then
    ReloadUI()
  elseif args[1] == "opt" then
    mod.addonConfiguration.OpenMainCategory()
  else
    mod.logger.PrintUserError(rgp.L["invalid_argument"])
  end
end

--[[
  Print cmd options for addon
]]--
ShowInfoMessage = function()
  print(rgp.L["info_title"])
  print(rgp.L["reload"])
  print(rgp.L["opt"])
end
