-- luacheck: globals GetLocale GetAddOnMetadata
-- Translator ZamestoTV
if (GetLocale() == "ruRU") then
  rgp = rgp or {}
  rgp.L = {}

rgp.L["addon_name"] = "Pulse"

-- console
rgp.L["help"] = "|cFFFFC300(%s)|r: Используйте |cFFFFC300/rgp|r или |cFFFFC300/pulse|r для списка опций"
rgp.L["opt"] = "|cFFFFC300opt|r — показать меню настроек"
rgp.L["reload"] = "|cFFFFC300reload|r — перезагрузить интерфейс"
rgp.L["info_title"] = "|cFF00FFB0Pulse:|r"
rgp.L["invalid_argument"] = "Недопустимый аргумент"

-- about
rgp.L["author"] = "Автор: Michael Wiesendanger"
rgp.L["email"] = "E-Mail: michael.wiesendanger@gmail.com"
rgp.L["version"] = "Версия: " .. GetAddOnMetadata(RGP_CONSTANTS.ADDON_NAME, "Version")
rgp.L["issues"] = "Проблемы: https://github.com/RagedUnicorn/wow-classic-pulse/issues"

-- general
rgp.L["general_category_name"] = "Настройки Pulse"
rgp.L["general_title"] = "Общая конфигурация"
rgp.L["window_lock_energy_bar"] = "Заблокировать панель энергии"
rgp.L["window_lock_energy_bar_tooltip"] = "Запрещает перемещение панели энергии"
rgp.L["energy_bar_width"] = "Ширина панели энергии"
rgp.L["energy_bar_width_tooltip"] = "Настройка ширины панели энергии"
rgp.L["energy_bar_height"] = "Высота панели энергии"
rgp.L["energy_bar_height_tooltip"] = "Настройка высоты панели энергии"
end
