-- luacheck: globals GetLocale C_AddOns

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
  rgp.L["version"] = "Version: " .. C_AddOns.GetAddOnMetadata(RGP_CONSTANTS.ADDON_NAME, "Version")
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

  -- profile
  rgp.L["profile_category_name"] = "Profile"
  rgp.L["profile_title"] = "Konfigurationsprofile"
  rgp.L["profile_list_label"] = "Gespeicherte Profile"
  rgp.L["profile_string_label"] = "Profil-Zeichenkette (Export / Import)"
  rgp.L["profile_save_button"] = "Aktuelles speichern als..."
  rgp.L["profile_apply_button"] = "Anwenden"
  rgp.L["profile_rename_button"] = "Umbenennen"
  rgp.L["profile_delete_button"] = "Löschen"
  rgp.L["profile_export_button"] = "Exportieren"
  rgp.L["profile_import_button"] = "Importieren"
  rgp.L["profile_name_prompt"] = "Gib einen Namen für das neue Profil ein:"
  rgp.L["profile_rename_prompt"] = "Gib einen neuen Namen für das Profil ein:"
  rgp.L["profile_import_name_prompt"] = "Gib einen Namen ein, unter dem das importierte Profil gespeichert wird:"
  rgp.L["profile_apply_confirm"] = "Profil \"%s\" anwenden? Dies überschreibt deine aktuellen Einstellungen "
    .. "und lädt die Benutzeroberfläche neu."
  rgp.L["profile_delete_confirm"] = "Profil \"%s\" löschen?"
  rgp.L["profile_save_success"] = "Profil \"%s\" gespeichert"
  rgp.L["profile_import_success"] = "Profil \"%s\" importiert"
  rgp.L["profile_delete_success"] = "Profil \"%s\" gelöscht"
  rgp.L["profile_rename_success"] = "Profil umbenannt in \"%s\""
  rgp.L["profile_error_empty"] = "Es gibt keine Profil-Zeichenkette zum Importieren"
  rgp.L["profile_error_invalid"] = "Die Profil-Zeichenkette ist ungültig oder konnte nicht gelesen werden"
  rgp.L["profile_error_checksum"] = "Die Profil-Zeichenkette ist beschädigt (Prüfsumme stimmt nicht)"
  rgp.L["profile_error_wrong_addon"] = "Diese Profil-Zeichenkette wurde nicht von Pulse erstellt"
  rgp.L["profile_error_version"] = "Diese Profil-Zeichenkette wurde mit einer neueren Version von Pulse erstellt"
  rgp.L["profile_error_name_empty"] = "Der Profilname darf nicht leer sein"
  rgp.L["profile_error_name_exists"] = "Ein Profil mit diesem Namen existiert bereits"
  rgp.L["profile_error_no_selection"] = "Kein Profil ausgewählt"
end
