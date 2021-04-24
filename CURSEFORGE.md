# Pulse
&nbsp;  
![](https://raw.githubusercontent.com/RagedUnicorn/wow-classic-pulse/master/docs/p_ragedunicorn_love_classic.png)
&nbsp;  
_Pulse aims to give a visual interpretation of when the next resources tick happens. This can be used by multiple classes but the most prominent one might be rogue and his energy regeneration._

## What is Pulse?

Pulse is a simple addon that tracks the energy-regen tickrate and the current amount of energy. The energybar will showup once the player spent some energy.

![](https://raw.githubusercontent.com/RagedUnicorn/wow-classic-pulse/master/docs/pulse_example.jpg)

## FAQ

#### The Addon is not showing up in WoW. What can I do?

Make sure to recheck the installation part of this Readme and check that the Addon is placed inside `[WoW-installation-directory]\Interface\AddOns` and is correctly named as `Pulse`.

#### The Addon is spamming my chat with messages. Why is it doing this?

Chances are you downloaded a development version of the addon. If you directly download the master branch you will get a development version that is printing a lot of debug message to the chat. Make sure that you download a release version of the addon here - [Pulse-Releases](https://github.com/RagedUnicorn/wow-classic-pulse/releases)

#### I get a red error (Lua Error) on my screen. What is this?

This is what we call a Lua error and it usually happens because of an oversight or error by the developer (in this case me). Take a screenshot off the error and create a Github Issue with it and I will see if I can resolve it. It also helps if you can add any additional information of what you we're doing at the time and what other addons you have active. Also if you are able to reproduce the error make sure to check if it still happens if you disable all others addons.
