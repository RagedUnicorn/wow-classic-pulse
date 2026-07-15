-- luacheck: globals GetLocale C_AddOns
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
  rgp.L["update_available"] = "Доступна новая версия |cFFFFC300%s|r — |cFF00FFB0рекомендуется обновление!|r"

  -- about
  rgp.L["author"] = "Автор: Michael Wiesendanger"
  rgp.L["email"] = "E-Mail: michael.wiesendanger@gmail.com"
  rgp.L["version"] = "Версия: " .. C_AddOns.GetAddOnMetadata(RGP_CONSTANTS.ADDON_NAME, "Version")
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

  -- profile
  rgp.L["profile_category_name"] = "Профили"
  rgp.L["profile_title"] = "Профили конфигурации"
  rgp.L["profile_list_label"] = "Сохранённые профили"
  rgp.L["profile_string_label"] = "Строка профиля (экспорт / импорт)"
  rgp.L["profile_save_button"] = "Сохранить текущий как..."
  rgp.L["profile_apply_button"] = "Применить"
  rgp.L["profile_rename_button"] = "Переименовать"
  rgp.L["profile_delete_button"] = "Удалить"
  rgp.L["profile_export_button"] = "Экспорт"
  rgp.L["profile_import_button"] = "Импорт"
  rgp.L["profile_name_prompt"] = "Введите имя нового профиля:"
  rgp.L["profile_rename_prompt"] = "Введите новое имя профиля:"
  rgp.L["profile_import_name_prompt"] = "Введите имя, под которым сохранить импортированный профиль:"
  rgp.L["profile_apply_confirm"] = "Применить профиль \"%s\"? Это перезапишет текущие настройки "
    .. "и перезагрузит интерфейс."
  rgp.L["profile_delete_confirm"] = "Удалить профиль \"%s\"?"
  rgp.L["profile_save_success"] = "Профиль \"%s\" сохранён"
  rgp.L["profile_import_success"] = "Профиль \"%s\" импортирован"
  rgp.L["profile_delete_success"] = "Профиль \"%s\" удалён"
  rgp.L["profile_rename_success"] = "Профиль переименован в \"%s\""
  rgp.L["profile_error_empty"] = "Нет строки профиля для импорта"
  rgp.L["profile_error_invalid"] = "Строка профиля недействительна или не может быть прочитана"
  rgp.L["profile_error_checksum"] = "Строка профиля повреждена (несовпадение контрольной суммы)"
  rgp.L["profile_error_wrong_addon"] = "Эта строка профиля создана не Pulse"
  rgp.L["profile_error_version"] = "Эта строка профиля создана более новой версией Pulse"
  rgp.L["profile_error_name_empty"] = "Имя профиля не может быть пустым"
  rgp.L["profile_error_name_exists"] = "Профиль с таким именем уже существует"
  rgp.L["profile_error_no_selection"] = "Профиль не выбран"
end
