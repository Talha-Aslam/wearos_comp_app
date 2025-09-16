# 📸 Screenshots Guide

## 📁 Directory Structure
```
screenshots/
├── mobile/
│   ├── mobile_home.png       # Mobile app home screen
│   ├── mobile_messages.png   # Mobile messaging interface
│   ├── mobile_settings.png   # Mobile settings screen
│   └── mobile_connection.png # Mobile connection status
└── wear/
    ├── wear_home.png         # Wear OS home screen
    ├── wear_messages.png     # Wear OS messaging interface
    ├── wear_compact.png      # Wear OS compact view
    └── wear_circular.png     # Wear OS circular layout
```

## 📱 How to Add Mobile Screenshots

1. **Take screenshots** of your mobile app running on Android device/emulator
2. **Save images** in PNG format with descriptive names
3. **Place files** in `screenshots/mobile/` directory
4. **Update README.md** with correct file paths:

```markdown
### 📱 Mobile App
<div align="center">
  <img src="screenshots/mobile/mobile_home.png" alt="Mobile Home Screen" width="300"/>
  <img src="screenshots/mobile/mobile_messages.png" alt="Mobile Messages" width="300"/>
  <img src="screenshots/mobile/mobile_settings.png" alt="Mobile Settings" width="300"/>
</div>
```

## ⌚ How to Add Wear OS Screenshots

1. **Take screenshots** of your Wear OS app running on watch/emulator
2. **Save images** in PNG format (preferably square/circular crops)
3. **Place files** in `screenshots/wear/` directory
4. **Update README.md** with correct file paths:

```markdown
### ⌚ Wear OS App
<div align="center">
  <img src="screenshots/wear/wear_home.png" alt="Wear Home Screen" width="250"/>
  <img src="screenshots/wear/wear_messages.png" alt="Wear Messages" width="250"/>
  <img src="screenshots/wear/wear_compact.png" alt="Wear Compact UI" width="250"/>
</div>
```

## 📐 Recommended Image Specifications

### 📱 **Mobile Screenshots**
- **Format**: PNG or JPG
- **Resolution**: 1080x1920 (or device native)
- **Aspect Ratio**: 16:9 or 18:9
- **Width in README**: 300px
- **Background**: App actual UI (no mock-ups)

### ⌚ **Wear OS Screenshots**
- **Format**: PNG (supports transparency)
- **Resolution**: 450x450 (square) or device native
- **Aspect Ratio**: 1:1 (square/circular)
- **Width in README**: 250px
- **Background**: Dark theme recommended

## 🎨 Screenshot Tips

### 📱 **For Mobile App:**
- Capture key screens: Home, Messages, Settings, Connection Status
- Show different states: Connected, Disconnected, Messaging
- Use consistent device orientation (portrait recommended)
- Ensure text is readable and UI elements are clear

### ⌚ **For Wear OS App:**
- Capture circular UI elements properly
- Show compact design and touch targets
- Demonstrate scrolling/navigation if applicable
- Use dark theme for better visibility

## 🛠️ Taking Screenshots

### **Using Android Studio:**
1. Open emulator/connect device
2. Click camera icon in emulator toolbar
3. Save to `screenshots/` directory

### **Using ADB Command:**
```bash
# Take screenshot and save to device
adb shell screencap -p /sdcard/screenshot.png

# Pull screenshot to computer
adb pull /sdcard/screenshot.png screenshots/mobile/
```

### **Using Device:**
- Use device's built-in screenshot functionality
- Transfer files to `screenshots/` directory
- Rename with descriptive names

## 📝 After Adding Screenshots

1. **Update README.md** with correct file paths
2. **Test image display** by viewing README in GitHub
3. **Optimize file sizes** if images are too large
4. **Commit and push** to repository

## 📋 Checklist

- [ ] Mobile home screen screenshot
- [ ] Mobile messaging interface screenshot  
- [ ] Mobile connection status screenshot
- [ ] Wear OS home screen screenshot
- [ ] Wear OS messaging interface screenshot
- [ ] Wear OS compact UI screenshot
- [ ] Updated README.md paths
- [ ] Tested image display on GitHub
- [ ] Committed and pushed changes

---

*Replace placeholder image paths in README.md once you add your actual screenshots*