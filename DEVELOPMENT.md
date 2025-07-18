# Development Guide

This guide provides information for developers working on the Pulse addon.

## Development Environment Setup

### Switching Between Development and Release Environments

The addon supports different configurations for development and release environments. To switch between them:

**Development Mode (default):**

```bash
mvn generate-resources -D generate.sources.overwrite=true -P development
```

**Release Mode:**

```bash
mvn generate-resources -D generate.sources.overwrite=true -P release
```

**Important:** Always keep the repository in development mode. Do not commit `Pulse.toc` and `Environment.lua` in their release state.

## Debugging and Logging

### Log Levels

The addon uses different log levels for debugging:
- `LogDebug` - Detailed debugging information
- `LogInfo` - General information
- `LogEvent` - Event tracking
- `LogWarn` - Warning messages
- `LogError` - Error messages
- `PrintUserError` - User-facing error messages

### Filtering Logs

The addon includes a filtering system that allows you to **hide** specific log messages during development. This is useful when you want to reduce log noise from modules you're not currently debugging.

**Important:** The filter system works as a blacklist - registered filters will **hide** matching logs, not show them.

#### How to Use Log Filters

The filter system is accessible through the `rgp.filter` module:

```lua
-- Hide logs from a specific module
rgp.filter.RegisterFilter("hide_core", "Core")

-- Hide logs using a pattern (regex)
rgp.filter.RegisterFilter("hide_energy", "Energy.*")

-- Hide multiple modules to reduce noise
rgp.filter.RegisterFilter("hide_ticker", "Ticker")
rgp.filter.RegisterFilter("hide_config", "Configuration")

-- Remove a filter to show logs again
rgp.filter.DeregisterFilter("hide_core")
```

#### Filter Examples

1. **Hide logs from verbose modules:**

   ```lua
   rgp.filter.RegisterFilter("quiet_ticker", "Ticker")
   ```

2. **Hide multiple related modules:**

   ```lua
   -- Hide UI-related logs when debugging core logic
   rgp.filter.RegisterFilter("hide_ui", "Frame")
   rgp.filter.RegisterFilter("hide_menu", "Menu")
   rgp.filter.RegisterFilter("hide_about", "About")
   ```

3. **Use patterns to hide groups of logs:**

   ```lua
   -- Hide all configuration-related logs
   rgp.filter.RegisterFilter("hide_config_all", ".*[Cc]onfig.*")
   ```

#### Where to Add Filters

During development, you can add temporary filters in the `Initialize` function in `Core.lua`:

```lua
Initialize = function()
  -- Hide noisy modules while debugging specific functionality
  rgp.filter.RegisterFilter("hide_ticker", "Ticker")
  rgp.filter.RegisterFilter("hide_tooltip", "Tooltip")

  me.logger.LogDebug(me.tag, "Initialize addon")
  -- ... rest of initialization
end
```

**Remember:** Remove all temporary filters before committing your changes.

## Code Style Guidelines

### File Naming

- Lua files use PascalCase (e.g., `Configuration.lua`, `EnergyBar.lua`)
- UI element names keep the `P_` prefix (e.g., `P_EnergyBar`, `P_MainFrame`)

### Function Visibility

- Use local functions for internal module functions
- Only expose functions that need to be accessed from other modules
- Always use forward declarations for local functions

Example:

```lua
-- forward declarations
local InternalHelper

-- Public function
function module.PublicFunction()
  InternalHelper()
end

-- Local function
InternalHelper = function()
  -- implementation
end
```

## Testing

Before committing changes:

1. Test in development mode
2. Switch to release mode and test again
3. Verify no debug logs appear in release mode
4. Test with `/reload` to ensure saved variables work correctly
5. Test the main functionality (energy tick tracking)

## Build and Package

### Development Package
```bash
mvn package -D generate.sources.overwrite=true -P development
```

### Release Package
```bash
mvn package -D generate.sources.overwrite=true -P release
```

## Common Development Tasks

### Adding a New Module

1. Create the new Lua file in the appropriate directory (`/code` or `/gui`)
2. Add the file reference to the template files:
   - `build-resources/pulse-development.toc.tpl`
   - `build-resources/pulse-release.toc.tpl`
   
   **Note:** Do not modify `Pulse.toc` directly as it's generated from the templates when running Maven commands.
   
3. Initialize the module structure:
   ```lua
   local mod = rgp
   local me = {}
   mod.newModule = me

   me.tag = "NewModule"
   ```
   
4. Generate the new `Pulse.toc` file:
   ```bash
   mvn generate-resources -D generate.sources.overwrite=true -P development
   ```

### Debugging Energy Tick Issues

1. Hide non-essential logs to focus on energy-related modules:
   ```lua
   -- Hide everything except Energy and Ticker logs
   rgp.filter.RegisterFilter("hide_config", "Configuration")
   rgp.filter.RegisterFilter("hide_cmd", "Cmd")
   rgp.filter.RegisterFilter("hide_tooltip", "Tooltip")
   rgp.filter.RegisterFilter("hide_frame", "Frame")
   rgp.filter.RegisterFilter("hide_menu", "Menu")
   ```

2. Monitor the `UNIT_POWER_UPDATE` events in `Core.lua`

3. Check the ticker timing in `Ticker.lua`

## Troubleshooting

### Logs Not Appearing
- Ensure you're in development mode
- Check if filters are too restrictive
- Verify the log level in `Environment.lua`

### Addon Not Loading
- Check for Lua errors with `/console scriptErrors 1`
- Verify file references in `Pulse.toc`
- Ensure all required files exist

### Build Issues
- Clean the `/target` directory
- Ensure Maven is properly installed
- Check file permissions in the addon directory

## Deployment

### Deploy GitHub Release

Before creating a new release update `addon.tag.version` in `pom.xml`. Afterwards to create a new release and deploy to GitHub the `deploy-github` profile has to be used.

```bash
# switch environment to release
mvn generate-resources -D generate.sources.overwrite=true -P release
# deploy release to GitHub
mvn package -P deploy-github -D github.auth-token=[token]
```

**Note:** This is only intended for manual deployment to GitHub. With GitHub actions the token is supplied as a secret to the build process

### Deploy CurseForge Release

**Note:** It's best to create the release for GitHub first and only afterwards the CurseForge release. That way the tag was already created.

```bash
# switch environment to release
mvn generate-resources -D generate.sources.overwrite=true -P release
# deploy release
mvn package -P deploy-curseforge -D curseforge.auth-token=[token]
```

**Note:** This is only intended for manual deployment to CurseForge. With GitHub actions the token is supplied as a secret to the build process

### Deploy Wago.io Release

**Note:** It's best to create the release for GitHub first and only afterwards the Wago.io release. That way the tag was already created.

```bash
# switch environment to release
mvn generate-resources -D generate.sources.overwrite=true -P release
# deploy release
mvn package -P deploy-wago -D wago.auth-token=[token]
```

**Note:** This is only intended for manual deployment to Wago.io. With GitHub actions the token is supplied as a secret to the build process

### GitHub Action Profiles

This project has GitHub action profiles for different DevOps related work such as linting and deployments to different providers. See `.github` folder for details.
