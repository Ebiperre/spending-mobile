# Troubleshooting Xcode Build Error

## Error: "Xcode build is missing expected TARGET_BUILD_DIR build setting"

This is a common iOS/Xcode build configuration issue. Try these solutions in order:

### Solution 1: Clean Flutter Build
```bash
flutter clean
flutter pub get
cd ios
pod deintegrate
pod install
cd ..
flutter run
```

### Solution 2: Clean Xcode Derived Data
1. Open Xcode
2. Go to **Xcode** → **Settings** → **Locations**
3. Click the arrow next to **Derived Data** path
4. Delete the folder for your project
5. Close Xcode
6. Run `flutter clean` and `flutter pub get`
7. Try `flutter run` again

### Solution 3: Reset iOS Build
```bash
flutter clean
rm -rf ios/Pods
rm -rf ios/.symlinks
rm -rf ios/Flutter/Flutter.framework
rm -rf ios/Flutter/Flutter.podspec
rm ios/Podfile.lock
flutter pub get
cd ios
pod install
cd ..
flutter run
```

### Solution 4: Open in Xcode and Clean
1. Open `ios/Runner.xcworkspace` in Xcode (NOT `.xcodeproj`)
2. In Xcode: **Product** → **Clean Build Folder** (Shift+Cmd+K)
3. Close Xcode
4. Run `flutter run`

### Solution 5: Check Flutter Doctor
```bash
flutter doctor -v
```
Make sure all components are properly installed, especially:
- Xcode
- CocoaPods
- iOS toolchain

### Solution 6: Update CocoaPods
```bash
sudo gem install cocoapods
pod repo update
cd ios
pod install
cd ..
```

### Solution 7: Check iOS Deployment Target
Make sure your `ios/Podfile` has a valid iOS deployment target (e.g., `platform :ios, '13.0'`)

If none of these work, try:
- Updating Xcode to the latest version
- Updating Flutter: `flutter upgrade`
- Checking if there are any Xcode command line tools issues: `xcode-select --print-path`

