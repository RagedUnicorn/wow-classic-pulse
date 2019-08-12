# Development

> Logger is a simple addon that helps addon developers log messages with different loglevels to the default chat


##



## What is Logger?

The logger addon is an addon that aims to improve the development process of WoW addons by providing certain log capabilities to addons. The intention is that addons us `Logger` as a dependency during testing or during the development process. The addon itself will not be particularly helpful for the normal WoW player.

### Logging

##### Tags

A tag is nothing else than a simple string that identifies a certain part of your code. This might be a module or just a specific place. As a best practice tags should have the following format. Following this format will make it much easier to filter for complete modules or addons.

```lua
"[addon-name]:[module]"

-- as an example

"GearMenu:Core"
```

##### Loglevels

Logger supports four different and one special event level. Once the addon is loaded the following functions can be used to log messages.

```lua
logger.LogDebug(me.tag, "This is a debug message")
logger.LogInfo(me.tag, "This is an info message")
logger.LogWarn(me.tag, "This is a warn message")
logger.LogError(me.tag, "This is an error message")
```

Events can be tracked and configured independently from the loglevel.

```lua
logger.LogEvent(me.tag, "This is an error message")
```

```lua

```

### Filter

me.filter.RegisterFilter("TickWatcher", "Core")
me.logger.LogDebug(me.tag, "Debug message should be filterd")
me.logger.LogDebug(me.tag, "I should be filtered as well")
me.filter.DeregisterFilter("TickWatcher")
me.logger.LogDebug(me.tag, "Message should not be filtered")
