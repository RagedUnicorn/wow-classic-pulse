-- luacheck: globals C_AddOns

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
rgp.L["version"] = "Version: " .. C_AddOns.GetAddOnMetadata(RGP_CONSTANTS.ADDON_NAME, "Version")
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

-- profile
rgp.L["profile_category_name"] = "Profiles"
rgp.L["profile_title"] = "Configuration Profiles"
rgp.L["profile_list_label"] = "Saved Profiles"
rgp.L["profile_string_label"] = "Profile String (Export / Import)"
rgp.L["profile_save_button"] = "Save current as..."
rgp.L["profile_apply_button"] = "Apply"
rgp.L["profile_rename_button"] = "Rename"
rgp.L["profile_delete_button"] = "Delete"
rgp.L["profile_export_button"] = "Export"
rgp.L["profile_import_button"] = "Import"
rgp.L["profile_name_prompt"] = "Enter a name for the new profile:"
rgp.L["profile_rename_prompt"] = "Enter a new name for the profile:"
rgp.L["profile_import_name_prompt"] = "Enter a name to save the imported profile under:"
rgp.L["profile_apply_confirm"] = "Apply profile \"%s\"? This overwrites your current settings and reloads the UI."
rgp.L["profile_delete_confirm"] = "Delete profile \"%s\"?"
rgp.L["profile_save_success"] = "Saved profile \"%s\""
rgp.L["profile_import_success"] = "Imported profile \"%s\""
rgp.L["profile_delete_success"] = "Deleted profile \"%s\""
rgp.L["profile_rename_success"] = "Renamed profile to \"%s\""
rgp.L["profile_error_empty"] = "There is no profile string to import"
rgp.L["profile_error_invalid"] = "The profile string is invalid or could not be read"
rgp.L["profile_error_checksum"] = "The profile string is corrupt (checksum mismatch)"
rgp.L["profile_error_wrong_addon"] = "This profile string was not created by Pulse"
rgp.L["profile_error_version"] = "This profile string was created by a newer version of Pulse"
rgp.L["profile_error_name_empty"] = "The profile name cannot be empty"
rgp.L["profile_error_name_exists"] = "A profile with that name already exists"
rgp.L["profile_error_no_selection"] = "No profile selected"
