# WearOS App Testing Guide

## Testing Without Physical Watch

### 1. Android Studio Wear OS Emulator Setup

#### Step 1: Install Wear OS System Images
1. Open Android Studio
2. Go to **Tools → AVD Manager**
3. Click **Create Virtual Device**
4. Select **Wear OS** category
5. Choose a device (e.g., "Wear OS Large Round", "Wear OS Small Round")
6. Download a Wear OS system image (API 30+ recommended)
7. Create the emulator

#### Step 2: Set up Pairing
1. Start both phone emulator and Wear OS emulator
2. On phone emulator: Install "Wear OS by Google" companion app from Play Store
3. Open Wear OS companion app and follow pairing setup
4. Use the pairing codes to connect the devices

#### Step 3: Test App Installation
1. Install your app on phone emulator: `flutter install`
2. Verify watch app automatically appears on Wear emulator
3. Test bidirectional communication between both instances

### 2. Alternative Testing Methods

#### A. Emulator Pairing Commands
```bash
# Pair emulators via ADB
adb -s emulator-5554 forward tcp:5601 tcp:5601
adb -s emulator-5556 forward tcp:5601 tcp:5601
```

#### B. Manual APK Testing
```bash
# Install mobile APK on phone emulator
adb -s phone_emulator install app-release.apk

# Install wear APK on watch emulator  
adb -s wear_emulator install wear-release.apk
```

#### C. Device Farm Testing
- Use Firebase Test Lab (has Wear OS virtual devices)
- AWS Device Farm (limited Wear OS support)
- BrowserStack App Live (some Wear OS devices)

### 3. Verification Checklist

#### Bundle Verification
- [ ] Single APK contains both mobile and wear modules
- [ ] Mobile APK size includes embedded wear APK
- [ ] Both APKs share same application ID
- [ ] Manifest includes wear app declaration

#### Communication Testing
- [ ] Messages send from phone to watch
- [ ] Messages send from watch to phone  
- [ ] Connection status syncs properly
- [ ] Platform detection works correctly

#### UI Testing
- [ ] Mobile UI loads on phone-sized screens
- [ ] Wear UI loads on watch-sized screens
- [ ] Layouts don't overflow on either platform
- [ ] Touch interactions work appropriately

### 4. Production Verification Options

#### A. Internal Testing Track
1. Upload APK to Google Play Console
2. Use Internal Testing track
3. Test on real devices through beta testers
4. Verify automatic wear app delivery

#### B. Community Testing
- Post in r/WearOS subreddit asking for testers
- Use TestFlight-like services for Android
- Partner with Wear OS device owners

#### C. Device Rental Services
- Google Cloud Test Lab
- Samsung Remote Test Lab
- Some companies rent physical devices

### 5. Debugging Tips

#### Logs to Monitor
```bash
# Check if wear app is detected
adb logcat | grep "WearableListenerService"

# Monitor communication
adb logcat | grep "WatchConnectivity"

# Platform detection logs
adb logcat | grep "Device Detection"
```

#### Common Issues
- Emulator pairing sometimes unstable
- Watch emulator may need restart
- Communication timing issues in emulators
- Some features only work on real hardware

### 6. Pre-Production Checklist

Before publishing to Play Store:
- [ ] Test on multiple Android versions
- [ ] Verify APK includes wear module
- [ ] Test communication reliability
- [ ] Check battery usage patterns
- [ ] Validate UI on different screen sizes
- [ ] Test installation/uninstallation flow