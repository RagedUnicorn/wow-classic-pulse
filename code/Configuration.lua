--[[
  MIT License

  Copyright (c) 2025 Michael Wiesendanger

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

-- luacheck: globals GetAddOnMetadata

local mod = rgp
local me = {}
mod.configuration = me

me.tag = "Configuration"

-- forward declarations for local functions
local SetAddonVersion

PulseConfiguration = {
  ["addonVersion"] = nil,
  --[[
    Whether the energyBar is locked from moving or not
  ]]--
  ["lockEnergyBar"] = false,

  --[[
    Energy bar dimensions
  ]]--
  ["energyBarWidth"] = nil,
  ["energyBarHeight"] = nil,

  --[[
    Framepositions for user draggable Frames
    frames = {
      -- should match the actual frame name
      ["P_Frame"] = {
      point: "CENTER",
        posX: 0,
        posY: 0
      }
      ...
    }
  ]]--
  ["frames"] = {}
}

--[[
  Set default values if property is nil. This might happen after an addon upgrade
]]--
function me.SetupConfiguration()
  if PulseConfiguration.lockEnergyBar == nil then
    mod.logger.LogInfo(me.tag, "lockEnergyBar has unexpected nil value")
    PulseConfiguration.lockEnergyBar = true
  end

  if PulseConfiguration.frames == nil then
    mod.logger.LogInfo(me.tag, "frames has unexpected nil value")
    PulseConfiguration.frames = {}
  end

  if PulseConfiguration.energyBarWidth == nil then
    mod.logger.LogInfo(me.tag, "energyBarWidth has unexpected nil value")
    PulseConfiguration.energyBarWidth = RGP_CONSTANTS.ELEMENT_ENERGY_BAR_WIDTH
  end

  if PulseConfiguration.energyBarHeight == nil then
    mod.logger.LogInfo(me.tag, "energyBarHeight has unexpected nil value")
    PulseConfiguration.energyBarHeight = RGP_CONSTANTS.ELEMENT_ENERGY_BAR_HEIGHT
  end

  --[[
    Set saved variables with addon version. This can be used later to determine whether
    a migration path applies to the current saved variables or not
  ]]--
  SetAddonVersion()
end

--[[
  Set addon version on addon options. Before setting a new version make sure
  to run through migration paths.
]]--
SetAddonVersion = function()
  -- if no version set so far make sure to set the current one
  if PulseConfiguration.addonVersion == nil then
    PulseConfiguration.addonVersion = GetAddOnMetadata(RGP_CONSTANTS.ADDON_NAME, "Version")
  end

  -- me.MigrationPath()
  -- migration done update addon version to current
  PulseConfiguration.addonVersion = GetAddOnMetadata(RGP_CONSTANTS.ADDON_NAME, "Version")
end

--[[
  Enable moving of gearBar window
]]--
function me.UnlockEnergyBar()
  PulseConfiguration.lockEnergyBar = false
end

--[[
  Disable moving of gearBar window
]]--
function me.LockEnergyBar()
  PulseConfiguration.lockEnergyBar = true
end

--[[
  @return {boolean}
    true - if the gearBar is locked
    false - if the gearBar is not locked
]]--
function me.IsEnergyBarLocked()
  return PulseConfiguration.lockEnergyBar
end

--[[
  Save the position of a frame in the addon variables allowing to persist its position

  @param {string} frameName
  @param {string} point
  @param {string} relativeTo
  @param {string} relativePoint
  @param {number} posX
  @param {number} posY
]]--
function me.SaveUserPlacedFramePosition(frameName, point, relativeTo, relativePoint, posX, posY)
  if PulseConfiguration.frames[frameName] == nil then
    PulseConfiguration.frames[frameName] = {}
  end

  PulseConfiguration.frames[frameName].posX = posX
  PulseConfiguration.frames[frameName].posY = posY
  PulseConfiguration.frames[frameName].point = point
  PulseConfiguration.frames[frameName].relativeTo = relativeTo
  PulseConfiguration.frames[frameName].relativePoint = relativePoint

  mod.logger.LogDebug(me.tag, "Saved frame position for - " .. frameName
    .. " - new pos: posX " .. posX .. " posY " .. posY .. " point " .. point)
end

--[[
  Get the position of a saved frame

  @param {string} frameName
  @return {table | nil}
    table - the returned x and y position
    nil - if no frame with the passed name could be found
]]--
function me.GetUserPlacedFramePosition(frameName)
  local frameConfig = PulseConfiguration.frames[frameName]

  if type(frameConfig) == "table" then
    return frameConfig
  end

  return nil
end

--[[
  Set the energy bar width

  @param {number} width
]]--
function me.SetEnergyBarWidth(width)
  PulseConfiguration.energyBarWidth = width
end

--[[
  Get the energy bar width

  @return {number}
]]--
function me.GetEnergyBarWidth()
  return PulseConfiguration.energyBarWidth
end

--[[
  Set the energy bar height

  @param {number} height
]]--
function me.SetEnergyBarHeight(height)
  PulseConfiguration.energyBarHeight = height
end

--[[
  Get the energy bar height

  @return {number}
]]--
function me.GetEnergyBarHeight()
  return PulseConfiguration.energyBarHeight
end
