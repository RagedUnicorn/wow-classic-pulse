--[[
  Writable globals: the addon namespace and the SavedVariables - their fields are set
  across many files. Everything else a file reads from the global environment (the
  RGP_* constants below, the WoW API in each file's inline `-- luacheck: read globals`
  header) is read-only, so an accidental assignment is reported.
]]--
globals = {
  "rgp",
  "PulseConfiguration",
  "PulseShotLog"
}

read_globals = {
  "RGP_CONSTANTS",
  "RGP_ENVIRONMENT",
  "RGP_SHOTS"
}

files = {
  ["code"] = {std = "lua51"},
  ["gui"] = {std = "lua51"},
  ["localization"] = {std = "lua51"},
  ["test"] = {std = "lua51"},
  ["test/headless/spec"] = {std = "lua51+busted"},
  ["dev"] = {std = "lua51"},
  -- the files that define an RGP_* constant table may assign it
  ["code/Constants.lua"] = {globals = {"RGP_CONSTANTS"}},
  ["code/Environment.lua"] = {globals = {"RGP_ENVIRONMENT"}},
  ["test/headless/Bootstrap.lua"] = {globals = {"RGP_ENVIRONMENT"}},
  ["dev/ShotManifest.lua"] = {globals = {"RGP_SHOTS"}}
}

exclude_files = {
  ".luacheckrc",
  "target/"
}
