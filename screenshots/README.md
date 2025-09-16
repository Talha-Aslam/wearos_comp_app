# 📸 Universal Screenshots Guide

## 📁 Directory Structure
```
screenshots/
├── mobile/
│   ├── android_home.png       # Android phone home screen
│   ├── android_messages.png   # Android messaging interface  
│   └── android_settings.png   # Android settings screen
├── ios/
│   ├── ios_home.png           # iOS phone home screen
│   ├── ios_messages.png       # iOS messaging interface
│   └── ios_settings.png       # iOS settings screen
├── wear/
│   ├── wearos_home.png        # Wear OS home screen
│   ├── wearos_messages.png    # Wear OS messaging interface
│   └── wearos_compact.png     # Wear OS compact view
└── watchos/
    ├── watchos_home.png       # watchOS home screen
    ├── watchos_messages.png   # watchOS messaging interface  
    └── watchos_actions.png    # watchOS quick actions
```

## 📱 Mobile Screenshots

### 🤖 Android Screenshots
1. **Take screenshots** of your Android mobile app
2. **Save as PNG files** in `screenshots/mobile/` directory
3. **Recommended names**:
   - `android_home.png` - Home screen with connection status
   - `android_messages.png` - Message conversation view
### 🍎 iOS Screenshots  
1. **Take screenshots** of your iOS mobile app
2. **Save as PNG files** in `screenshots/ios/` directory
3. **Recommended names**:
   - `ios_home.png` - iOS home screen with Cupertino design
   - `ios_messages.png` - iOS message conversation
   - `ios_settings.png` - iOS settings with action sheet

## ⌚ Watch Screenshots

### 🤖 Wear OS Screenshots
1. **Take screenshots** of your Wear OS app
2. **Save as PNG files** in `screenshots/wear/` directory  
3. **Recommended names**:
   - `wearos_home.png` - Wear OS home screen
   - `wearos_messages.png` - Compact message view
   - `wearos_compact.png` - Circular UI elements

### 🍎 watchOS Screenshots
1. **Take screenshots** of your Apple Watch app
2. **Save as PNG files** in `screenshots/watchos/` directory
3. **Recommended names**:
   - `watchos_home.png` - watchOS home with dark theme
   - `watchos_messages.png` - watchOS message bubbles
   - `watchos_actions.png` - Quick action buttons

## 📐 Image Specifications

### 📱 **Mobile Screenshots**
| Platform | Resolution | Aspect Ratio | Width in README |
|----------|------------|--------------|-----------------|
| Android | 1080x1920+ | 16:9/18:9 | 300px |
| iOS | 1170x2532+ | 19.5:9 | 300px |

### ⌚ **Watch Screenshots**  
| Platform | Resolution | Shape | Width in README |
|----------|------------|-------|-----------------|
| Wear OS | 450x450+ | Round/Square | 250px |
| watchOS | 368x448+ | Round | 250px |

## 🖼️ README Integration

### Mobile Screenshots in README
```markdown
### 📱 Mobile Apps
<div align="center">
  <img src="screenshots/mobile/android_home.png" alt="Android Home" width="300"/>
  <img src="screenshots/ios/ios_home.png" alt="iOS Home" width="300"/>
  <img src="screenshots/mobile/android_messages.png" alt="Android Messages" width="300"/>
</div>
```

### Watch Screenshots in README
```markdown
### ⌚ Watch Apps
<div align="center">
  <img src="screenshots/wear/wearos_home.png" alt="Wear OS Home" width="250"/>
  <img src="screenshots/watchos/watchos_home.png" alt="watchOS Home" width="250"/>
  <img src="screenshots/wear/wearos_messages.png" alt="Wear OS Messages" width="250"/>
</div>
```

## 🛠️ Taking Screenshots

### **Android/Wear OS**
```bash
# Using ADB
adb shell screencap -p /sdcard/screenshot.png
adb pull /sdcard/screenshot.png screenshots/mobile/

# Using Android Studio
# Click camera icon in emulator toolbar
```

### **iOS/watchOS**  
```bash
# Using iOS Simulator
Device → Screenshot → Save to screenshots/ios/

# Using Xcode
Product → Profile → Choose screenshot location
```

### **Physical Devices**
- **Android**: Power + Volume Down
- **Wear OS**: Long press on power button
- **iOS**: Power + Volume Up  
- **watchOS**: Digital Crown + Side Button

## 📋 Platform-Specific Tips

### 🤖 **Android/Wear OS**
- Use Material Design 3 colors and themes
- Show different connection states
- Demonstrate responsive layouts
- Capture circular UI on Wear OS

### 🍎 **iOS/watchOS**
- Use iOS system backgrounds
- Show Cupertino design elements
- Capture native iOS controls
- Demonstrate dark theme on watchOS

## ✅ Checklist

### Mobile Apps
- [ ] Android home screen
- [ ] Android messaging interface  
- [ ] iOS home screen with Cupertino design
- [ ] iOS messaging with native bubbles

### Watch Apps  
- [ ] Wear OS circular home screen
- [ ] Wear OS compact messaging
- [ ] watchOS dark themed home
- [ ] watchOS quick action buttons

### Documentation
- [ ] Updated README.md with all platform screenshots
- [ ] Verified image paths work on GitHub
- [ ] Optimized file sizes (<500KB each)
- [ ] Committed and pushed changes

---

*Your universal companion app now supports screenshots for all four platforms: Android, iOS, Wear OS, and watchOS!* 📱⌚