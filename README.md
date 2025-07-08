# RMF Phone - iPhone-Style Phone System for FiveM

A complete iPhone-inspired phone UI system for FiveM servers, designed to work seamlessly with rmf-core.

## Features

### 📱 **Complete iPhone Experience**
- iPhone X-style design with notch and rounded corners
- Smooth iOS-like animations and transitions
- Modern glass morphism effects and blur
- Live status bar with time, battery, and signal strength

### 🏠 **Home Screen**
- Beautiful gradient wallpaper (customizable)
- App grid with 4 main applications
- Bottom dock with quick access
- Pull-down notifications panel
- Pull-up control center

### 📞 **Phone App**
- Full dialpad with T9 letters
- Contacts list with avatars
- Recent calls history
- One-tap calling from contacts
- Call notifications and feedback

### 💬 **Messages App**
- SMS-style message threads
- Real-time message notifications
- Individual chat screens
- Send/receive messages between players
- Message history persistence

### 🔍 **Google App**
- Search interface with results
- Customizable search functionality
- Clean Google-inspired design

### 📷 **Camera App**
- Photo/Video mode toggle
- Capture button with feedback
- Camera viewfinder simulation
- Screenshot integration ready

### ⚙️ **Settings App**
- System settings interface
- Notification preferences
- Privacy & Security options
- General phone settings

### 🎛️ **Control Center**
- Airplane Mode toggle
- WiFi and Bluetooth controls
- Do Not Disturb mode
- Brightness slider
- Quick settings access

## Installation

1. **Download the Resource**
   ```bash
   git clone <repository-url> rmf-phone
   ```

2. **Place in Resources Folder**
   ```
   resources/
   └── rmf-phone/
       ├── fxmanifest.lua
       ├── html/
       ├── client/
       ├── server/
       └── shared/
   ```

3. **Add to server.cfg**
   ```
   ensure rmf-core
   ensure rmf-phone
   ```

4. **Customize Assets (Optional)**
   - Replace `html/img/background.svg` with your custom wallpaper
   - Add sound files to `html/sounds/` folder
   - Modify `shared/config.lua` for your server settings

## Configuration

Edit `shared/config.lua` to customize:

```lua
-- Key binding
Config.PhoneKey = 'F1'

-- Visual settings
Config.PhoneScale = 1.0

-- Battery simulation
Config.BatteryDrain = true
Config.BatteryDrainRate = 1

-- Signal areas
Config.SignalAreas = {
    -- Add your custom areas
}
```

## Usage

### For Players

- **Open Phone**: Press `F1` (default) or use `/phone` command
- **Navigate**: Click app icons to open applications
- **Home**: Click the home indicator bar to return to home screen
- **Control Center**: Swipe up from bottom or click battery area
- **Notifications**: Swipe down from top or click time area

### For Developers

#### Exports

```lua
-- Toggle phone visibility
exports['rmf-phone']:togglePhone()

-- Show phone
exports['rmf-phone']:showPhone()

-- Hide phone
exports['rmf-phone']:hidePhone()

-- Send notification
exports['rmf-phone']:sendNotification({
    icon = "📱",
    title = "Test Notification",
    text = "This is a test message",
    time = "now"
})

-- Make a call between players
exports['rmf-phone']:callPlayer(callerId, targetId)

-- Send message to player
exports['rmf-phone']:sendMessage(targetPlayerId, sender, message)
```

#### Server Events

```lua
-- Get player's phone number
TriggerEvent('rmf-phone:getPlayerNumber', playerId, function(number)
    print("Player phone number: " .. number)
end)

-- Send notification to player
TriggerClientEvent('rmf-phone:sendNotification', playerId, {
    icon = "💰",
    title = "Bank Transfer",
    text = "You received $5000",
    time = "now"
})
```

## RMF-Core Integration

This phone system is designed to work with rmf-core and uses the following events:

- `rmf-core:playerLoaded` - Load player phone data
- `rmf-core:playerDropped` - Save and cleanup phone data
- `rmf-core:getPlayerData` - Get player information
- `rmf-core:logEvent` - Log phone activities
- `rmf-core:giveItem` - Give items (e.g., photos)

## File Structure

```
rmf-phone/
├── fxmanifest.lua          # Resource manifest
├── README.md               # This file
├── html/                   # Frontend files
│   ├── index.html          # Main HTML
│   ├── css/
│   │   └── style.css       # iPhone-style CSS
│   ├── js/
│   │   └── script.js       # Phone functionality
│   ├── img/
│   │   └── background.svg  # Wallpaper
│   └── sounds/
│       └── ringtone.mp3    # Sound effects
├── client/
│   └── main.lua            # Client-side logic
├── server/
│   └── main.lua            # Server-side logic
└── shared/
    └── config.lua          # Configuration
```

## Customization

### Adding Custom Apps

1. **HTML**: Add app screen in `html/index.html`
2. **CSS**: Style the app in `html/css/style.css`
3. **JavaScript**: Add functionality in `html/js/script.js`
4. **Icon**: Add app icon to home screen grid

### Custom Wallpaper

Replace `html/img/background.svg` with your image:
- Recommended size: 375x812 pixels
- Formats: PNG, JPG, SVG
- Update CSS path if needed

### Sound Effects

Add sound files to `html/sounds/`:
- `ringtone.mp3` - Incoming call sound
- `notification.mp3` - Message/notification sound
- `keypad.mp3` - Dialpad button press
- `camera.mp3` - Photo capture sound

## Admin Commands

```
/givephone [playerId]     # Give phone number to player
/callplayer [from] [to]   # Force call between players
/sendmsg [playerId] [msg] # Send system message
```

## Troubleshooting

### Common Issues

1. **Phone not showing**
   - Check if rmf-core is running
   - Verify F1 key binding
   - Check console for errors

2. **Calls not working**
   - Ensure both players have phone numbers
   - Check server console for errors
   - Verify network connectivity

3. **Messages not sending**
   - Check target phone number exists
   - Verify rmf-core integration
   - Check database connection

### Debug Mode

Enable debug mode in `shared/config.lua`:
```lua
Config.Debug = true
```

## Dependencies

- **rmf-core** (required)
- **FiveM Server** (latest recommended)

## Support

For support and updates:
- Check the documentation
- Report issues on GitHub
- Join the community Discord

## License

This resource is provided as-is for FiveM servers. Customize and modify as needed for your server.

---

**Made with ❤️ for the FiveM community**
