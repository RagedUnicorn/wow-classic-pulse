
-- luacheck: globals GetAddOnMetadata

rgp = rgp or {}
rgp.L = {}

rgp.L["addon_name"] = "Pulse"

-- console
rgp.L["help"] = "|cFFFFC300(%s)|r: Use |cFFFFC300/rgp|r or |cFFFFC300/pulse|r for a list of options"
rgp.L["opt"] = "|cFFFFC300opt|r - display Optionsmenu"
rgp.L["reload"] = "|cFFFFC300reload|r - reload UI"
rgp.L["info_title"] = "|cFF00FFB0Pulse:|r"
rgp.L["invalid_argument"] = "Invalid argument passed"

-- about
rgp.L["author"] = "Author: Michael Wiesendanger"
rgp.L["email"] = "E-Mail: michael.wiesendanger@gmail.com"
rgp.L["version"] = "Version: " .. GetAddOnMetadata(RGP_CONSTANTS.ADDON_NAME, "Version")
rgp.L["issues"] = "Issues: https://github.com/RagedUnicorn/wow-classic-pulse/issues"

-- general
rgp.L["general_category_name"] = "Pulse Options"
rgp.L["general_title"] = "General Configuration"
rgp.L["window_lock_energy_bar"] = "Lock EnergyBar"
rgp.L["window_lock_energy_bar_tooltip"] = "Prevents EnergyBar from being moved"
rgp.L["energy_bar_width"] = "Energy Bar Width"
rgp.L["energy_bar_width_tooltip"] = "Adjust the width of the energy bar"
rgp.L["energy_bar_height"] = "Energy Bar Height"
rgp.L["energy_bar_height_tooltip"] = "Adjust the height of the energy bar"
