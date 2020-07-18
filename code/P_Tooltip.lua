--[[
  MIT License

  Copyright (c) 2020 Michael Wiesendanger

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

-- luacheck: globals UIParent GameTooltip_SetDefaultAnchor

local mod = rgp
local me = {}
mod.tooltip = me

me.tag = "Tooltip"

--[[
  Remove tooltip after region leave
]]--
function me.TooltipClear()
  _G[RGP_CONSTANTS.ELEMENT_TOOLTIP]:Hide()
end

--[[
  @param {string} line1
  @param {string} line2
]]--
function me.BuildTooltipForOption(line1, line2)
  local tooltip = _G[RGP_CONSTANTS.ELEMENT_TOOLTIP]

  tooltip:SetOwner(UIParent)
  GameTooltip_SetDefaultAnchor(tooltip, UIParent)
  tooltip:AddLine(line1)
  tooltip:AddLine(line2, .8, .8, .8, 1)

  tooltip:Show()
end
