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

-- luacheck: globals CreateFrame UIParent Settings

local mod = rgp
local me = {}

mod.addonConfiguration = me

me.tag = "AddonConfiguration"

--[[
  Holds the id reference to the main category of the addon. Can be used with Settings.OpenToCategory({number})
  {number}
]]--
local mainCategoryId

--[[
  Retrieve a reference to the main category of the addon
  @return {table | nil}
    The main category of the addon or nil if not found
]]--
function me.GetMainCategory()
  if mainCategoryId ~= nil then
    return Settings.GetCategory(mainCategoryId)
  end

  return nil
end

--[[
  Create addon configuration menu(s)
]]--
function me.SetupAddonConfiguration()
  -- initialize the main addon category
  local category, menu = me.BuildCategory(RGP_CONSTANTS.ELEMENT_ADDON_PANEL, nil, rgp.L["addon_name"])
  -- add about content into main category
  mod.aboutContent.BuildAboutContent(menu)

  me.BuildCategory(
    RGP_CONSTANTS.ELEMENT_GENERAL_SUB_OPTION_FRAME,
    category,
    rgp.L["general_category_name"],
    mod.generalMenu.BuildUi
  )
end

--[[
  Builds main and subcategories

  @param {string} frameName
  @param {table} parent
  @param {string} panelText
  @param {function} onShowCallback

  @return {table}, {table}
    category, menu
]]--
function me.BuildCategory(frameName, parent, panelText, onShowCallback)
  local category
  local menu

  if parent == nil then
    menu = CreateFrame("Frame", frameName)
    category = Settings.RegisterCanvasLayoutCategory(menu, panelText)
    mainCategoryId = category.ID
    Settings.RegisterAddOnCategory(category)
  else
    menu = CreateFrame("Frame", frameName, nil)
    menu.parent = parent.name
    local subcategory = Settings.RegisterCanvasLayoutSubcategory(parent, menu, frameName)
    subcategory.name = panelText
    category = subcategory
    Settings.RegisterAddOnCategory(subcategory)
  end

  if onShowCallback ~= nil then
    menu:SetScript("OnShow", onShowCallback)
  end

  --[[
   Important to hide panel initially. Interface addon options will take care of showing the menu.
   If this is not done OnShow callbacks will not be invoked correctly.
  ]]--
  menu:Hide()

  return category, menu
end

--[[
  Open the Blizzard addon configurations panel for the addon
]]--
function me.OpenMainCategory()
  if mainCategoryId ~= nil then
    Settings.OpenToCategory(mainCategoryId)
  end
end
