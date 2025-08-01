
-- luacheck: globals GetLocale GetAddOnMetadata

if (GetLocale() == "deDE") then
  rgp = rgp or {}
  rgp.L = {}

  rgp.L["addon_name"] = "Pulse"

  -- console
  rgp.L["help"] = "|cFFFFC300(%s)|r: Benutze |cFFFFC300/rgp|r oder |cFFFFC300/pulse|r "
    .. "für eine Liste der verfügbaren Optionen"
  rgp.L["opt"] = "|cFFFFC300opt|r - zeige Optionsmenu an"
  rgp.L["reload"] = "|cFFFFC300reload|r - UI neu laden"
  rgp.L["info_title"] = "|cFF00FFB0Pulse:|r"
  rgp.L["invalid_argument"] = "Ungültiges Argument übergeben"

  -- about tab
  rgp.L["author"] = "Autor: Michael Wiesendanger"
  rgp.L["email"] = "E-Mail: michael.wiesendanger@gmail.com"
  rgp.L["version"] = "Version: " .. GetAddOnMetadata(RGP_CONSTANTS.ADDON_NAME, "Version")
  rgp.L["issues"] = "Probleme: https://github.com/RagedUnicorn/wow-classic-pulse/issues"

  -- general
  rgp.L["general_category_name"] = "Pulse Optionen"
  rgp.L["general_title"] = "Allgemeine Konfiguration"
  rgp.L["window_lock_energy_bar"] = "Sperre Energiebalken"
  rgp.L["window_lock_energy_bar_tooltip"] = "Verhindert das bewegen des Energiebalken"
  rgp.L["energy_bar_width"] = "Energiebalken Breite"
  rgp.L["energy_bar_width_tooltip"] = "Breite des Energiebalkens anpassen"
  rgp.L["energy_bar_height"] = "Energiebalken Höhe"
  rgp.L["energy_bar_height_tooltip"] = "Höhe des Energiebalkens anpassen"
end
