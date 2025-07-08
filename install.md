# Quick Installation Guide

## Prerequisites
- FiveM Server running
- rmf-core resource installed and working

## Installation Steps

1. **Copy Resource**
   ```bash
   # Copy the entire rmf-phone folder to your resources directory
   cp -r rmf-phone /path/to/your/server/resources/
   ```

2. **Update server.cfg**
   ```bash
   # Add to your server.cfg (make sure rmf-core loads first)
   ensure rmf-core
   ensure rmf-phone
   ```

3. **Restart Server**
   ```bash
   # In your server console
   restart rmf-phone
   # or restart the entire server
   ```

4. **Test the Phone**
   - Join your server
   - Press `F1` to open the phone
   - Complete the setup screen
   - Enjoy your new iPhone-style phone!

## Quick Configuration

Edit `shared/config.lua` for basic customization:

```lua
-- Change the phone key
Config.PhoneKey = 'F2'  -- or any other key

-- Disable battery drain
Config.BatteryDrain = false

-- Change phone scale
Config.PhoneScale = 0.8  -- smaller phone
```

## Common Issues

- **Phone not opening**: Check if rmf-core is running and loaded
- **No phone number**: Players get auto-assigned numbers on first use
- **Styling issues**: Make sure all HTML/CSS files are properly uploaded

## Need Help?

Check the main README.md file for detailed documentation and troubleshooting.