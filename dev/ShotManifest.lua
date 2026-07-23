--[[
  MIT License

  Copyright (c) 2026 Michael Wiesendanger

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

-- THIS FILE IS AUTO-GENERATED. ALL CHANGES ARE OVERWRITTEN
-- Source: wow-media-capture/reference/media/pulse.json
-- Regenerate: scripts/gen-shot-table.ps1 -Addon pulse

RGP_SHOTS = {
  {
    name = "pulse_example",
    shot = "energy_bar",
    frame = "P_EnergyBar",
    setup = { "previewEnergyBar" },
    includeFrames = { "PlayerFrame" },
    hideChrome = true,
    padding = 160,
    shows = "Energy bar mid-tick in the open world"
  },
  {
    name = "pulse_options_configuration",
    shot = "options_panel",
    frame = "SettingsPanel",
    setup = { "openCategory:general" },
    hideFrames = { "P_EnergyBar" },
    hideChrome = true,
    padding = 0,
    shows = "Options panel with the window-lock toggle and the energy-bar width and height sliders"
  },
  {
    name = "pulse_profile_configuration",
    shot = "profile_panel",
    frame = "SettingsPanel",
    setup = { "openCategory:profile" },
    hideFrames = { "P_EnergyBar" },
    hideChrome = true,
    padding = 0,
    shows = "Profile panel with the named-profile list and export/import controls"
  }
}
