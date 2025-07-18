# Pulse

![](docs/p_ragedunicorn_love_classic.png)

> Pulse aims to give a visual interpretation of when the next resources tick happens. This can be used by multiple classes but the most prominent one might be rogue and his energy regeneration.

![](docs/wow_badge.svg)
![](docs/license_mit.svg)
![Lint](https://github.com/RagedUnicorn/wow-classic-pulse/actions/workflows/lint.yaml/badge.svg?branch=master)

## Providers

[![](docs/curseforge.svg)](https://www.curseforge.com/wow/addons/pulse)
[![](docs/wago.svg)](https://addons.wago.io/addons/pulse)

**WoW Burning Crusade Classic Support**

> This Addon supports WoW Burning Crusade Classic see - [bcc-Pulse](https://github.com/RagedUnicorn/wow-bcc-pulse/)

<a href="https://github.com/RagedUnicorn/wow-bcc-pulse/"><img src="/docs/the_burning_crusade_logo.png" width="40%"></img></a>

## Installation

WoW-Addons are installed directly into your WoW directory:

`[WoW-installation-directory]\Interface\AddOns`

Make sure to get the newest version of the Addon from the releases tab:

[Pulse-Releases](https://github.com/RagedUnicorn/wow-classic-pulse/releases)

> Note: If the Addon is not showing up in your ingame Addonlist make sure that the Addon is named `Pulse` in your Addons folder

## What is Pulse?

Pulse is a simple addon that tracks the energy-regen tickrate and the current amount of energy. The energybar will show once the player spent some energy.

![](docs/pulse_example.jpg)

## FAQ

#### The Addon is not showing up in WoW. What can I do?

Make sure to recheck the installation part of this Readme and check that the Addon is placed inside `[WoW-installation-directory]\Interface\AddOns` and is correctly named as `Pulse`.

#### The Addon is spamming my chat with messages. Why is it doing this?

Chances are you downloaded a development version of the addon. If you directly download the master branch you will get a development version that is printing a lot of debug message to the chat. Make sure that you download a release version of the addon here - [Pulse-Releases](https://github.com/RagedUnicorn/wow-classic-pulse/releases)

#### I get a red error (Lua Error) on my screen. What is this?

This is what we call a Lua error, and it usually happens because of an oversight or error by the developer (in this case me). Take a screenshot off the error and create a GitHub Issue with it, and I will see if I can resolve it. It also helps if you can add any additional information of what you were doing at the time and what other addons you have active. Additionally, if you are able to reproduce the error make sure to check if it still happens if you disable all others addons.

## Development

For detailed development documentation including:
- Environment setup and switching
- Debugging and log filtering
- Code style guidelines
- Building and packaging
- Deployment procedures
- Common development tasks

See [DEVELOPMENT.md](DEVELOPMENT.md).

## License

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
