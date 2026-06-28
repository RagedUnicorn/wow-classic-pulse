globals = {
  "rgp",
  "PulseConfiguration",
  "RGP_CONSTANTS",
  "RGP_ENVIRONMENT"
}

files = {
  ["code"] = {std = "lua51"},
  ["gui"] = {std = "lua51"},
  ["localization"] = {std = "lua51"},
  ["test"] = {std = "lua51+busted"}
}

exclude_files = {
  ".luacheckrc",
  "target/"
}
