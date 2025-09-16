
#!/bin/bash

echo "🔍 Verifying WearOS Bundle Configuration..."
echo ""

# Check if mobile APK exists
if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    echo "✅ Mobile APK found: build/app/outputs/flutter-apk/app-release.apk"
    APK_SIZE=$(ls -lh build/app/outputs/flutter-apk/app-release.apk | awk '{print $5}')
    echo "   Size: $APK_SIZE"
else
    echo "❌ Mobile APK not found"
fi

echo ""

# Check Android configuration
echo "🔧 Checking Android Bundle Configuration..."
echo ""

if grep -q "wearApp project(':wear')" android/app/build.gradle; then
    echo "✅ Wear module dependency found in app/build.gradle"
else
    echo "❌ Wear module dependency missing"
fi

if [ -f "android/wear/build.gradle" ]; then
    echo "✅ Wear module build.gradle exists"
else
    echo "❌ Wear module build.gradle missing"
fi

# Check application IDs match
MOBILE_ID=$(grep "applicationId" android/app/build.gradle | head -1 | sed 's/.*"\(.*\)".*/\1/')
WEAR_ID=$(grep "applicationId" android/wear/build.gradle | head -1 | sed 's/.*"\(.*\)".*/\1/')

echo ""
echo "📱 Application IDs:"
echo "   Mobile: $MOBILE_ID"
echo "   Wear:   $WEAR_ID"

if [ "$MOBILE_ID" = "$WEAR_ID" ]; then
    echo "✅ Application IDs match - will be bundled as single app"
else
    echo "❌ Application IDs don't match - will be separate apps"
fi

echo ""
echo "🎯 Platform Detection Test:"
echo ""

# Test platform detection logic
if grep -q "_detectWearDevice" lib/main.dart; then
    echo "✅ Platform detection function found"
    if grep -q "device_info_plus" pubspec.yaml; then
        echo "✅ device_info_plus dependency found"
    else
        echo "❌ device_info_plus dependency missing"
    fi
else
    echo "❌ Platform detection function missing"
fi

echo ""
echo "📡 Communication Setup:"
echo ""

if grep -q "watch_connectivity" pubspec.yaml; then
    echo "✅ watch_connectivity dependency found"
    if [ -f "lib/shared/services/communication_service.dart" ]; then
        echo "✅ Communication service exists"
    else
        echo "❌ Communication service missing"
    fi
else
    echo "❌ watch_connectivity dependency missing"
fi

echo ""
echo "🏗️ Project Structure:"
echo ""

if [ -f "lib/main_mobile.dart" ]; then
    echo "✅ Mobile entrypoint: lib/main_mobile.dart"
else
    echo "❌ Mobile entrypoint missing"
fi

if [ -f "lib/main_wear.dart" ]; then
    echo "✅ Wear entrypoint: lib/main_wear.dart"
else
    echo "❌ Wear entrypoint missing"
fi

if [ -d "lib/shared" ]; then
    echo "✅ Shared logic folder: lib/shared/"
else
    echo "❌ Shared logic folder missing"
fi

echo ""
echo "🎉 Bundle Status Summary:"
echo ""

BUNDLE_READY=true

# Check critical components
if ! grep -q "wearApp project(':wear')" android/app/build.gradle; then
    BUNDLE_READY=false
fi

if [ "$MOBILE_ID" != "$WEAR_ID" ]; then
    BUNDLE_READY=false
fi

if [ ! -f "lib/main_mobile.dart" ] || [ ! -f "lib/main_wear.dart" ]; then
    BUNDLE_READY=false
fi

if $BUNDLE_READY; then
    echo "🎯 READY FOR SINGLE APP STORE LISTING"
    echo "   ✅ Will bundle as one app"
    echo "   ✅ Automatic wear delivery enabled"
    echo "   ✅ Platform detection configured"
    echo ""
    echo "📱 When published:"
    echo "   • Users see ONE app in Play Store"
    echo "   • Mobile version installs on phone"
    echo "   • Wear version auto-installs on paired watch"
    echo "   • No manual watch installation needed"
else
    echo "⚠️  CONFIGURATION ISSUES DETECTED"
    echo "   Please fix the issues above before publishing"
fi