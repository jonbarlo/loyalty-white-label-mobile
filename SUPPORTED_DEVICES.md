# Supported Devices & Setup Guide

This document outlines the device requirements, setup instructions, and testing guidelines for the Flutter Loyalty Mobile App.

## 📱 Supported Devices

### **Android Devices**
- **Minimum**: Android 5.0 (API level 21) or higher
- **Recommended**: Android 8.0 (API level 26) or higher
- **Target**: Android 13 (API level 33)

### **iOS Devices**
- **Minimum**: iOS 11.0 or higher
- **Recommended**: iOS 14.0 or higher
- **Target**: iOS 16.0 or higher

### **Windows Desktop**
- **Minimum**: Windows 10 (version 1903) or higher
- **Recommended**: Windows 11 or higher
- **Architecture**: x64 (64-bit)
- **Requirements**: Visual Studio 2019 or later with C++ build tools

## 🖥️ Development Setup Options

### **1. Physical Devices (Recommended)**

#### **Android Physical Device**
- **Requirements**:
  - Android phone/tablet with Android 5.0+
  - USB cable for connection
  - Developer options enabled
  - USB debugging enabled

- **Setup Steps**:
  1. Enable Developer Options: Settings → About Phone → Tap "Build Number" 7 times
  2. Enable USB Debugging: Settings → Developer Options → USB Debugging
  3. Connect device via USB
  4. Allow USB debugging when prompted on device
  5. Run `flutter devices` to verify connection

#### **iOS Physical Device**
- **Requirements**:
  - iPhone/iPad with iOS 11.0+
  - USB cable or wireless connection
  - Apple Developer account (for app signing)
  - Xcode installed on Mac

- **Setup Steps**:
  1. Connect device to Mac
  2. Trust the computer on your device
  3. Open Xcode → Window → Devices and Simulators
  4. Register your device for development
  5. Run `flutter devices` to verify connection

### **2. Emulators/Simulators**

#### **Android Emulator**
- **Setup via Android Studio**:
  1. Open Android Studio
  2. Go to Tools → AVD Manager
  3. Click "Create Virtual Device"
  4. Select device (e.g., Pixel 6)
  5. Select system image (e.g., API 33)
  6. Start the emulator

#### **iOS Simulator** (Mac only)
- **Setup via Xcode**:
  1. Open Xcode
  2. Go to Xcode → Open Developer Tool → Simulator
  3. Select device from Hardware menu
  4. Choose iOS version

### **3. Windows Desktop**

#### **Windows Desktop Setup**
- **Requirements**:
  - Windows 10 (version 1903) or higher
  - Visual Studio 2019 or later
  - "Desktop development with C++" workload installed
  - Windows 10 SDK

- **Setup Steps**:
  1. Install Visual Studio Community 2022 (free)
  2. During installation, select "Desktop development with C++"
  3. Ensure these components are included:
     - MSVC v142 - VS 2019 C++ x64/x86 build tools
     - C++ CMake tools for Windows
     - Windows 10 SDK
  4. Enable Windows desktop: `flutter config --enable-windows-desktop`
  5. Run `flutter doctor` to verify setup

## 🔧 Device Configuration for Your Loyalty App

### **Recommended Device Specifications**

#### **For Testing**
- **Screen Size**: 5.5" to 6.7" (covers most modern phones)
- **Resolution**: 1080p or higher
- **RAM**: 4GB or more
- **Storage**: 16GB or more

#### **For Production**
- **Screen Size**: 5.0" to 7.0" (tablet support)
- **Resolution**: 720p minimum, 1080p+ recommended
- **RAM**: 3GB minimum, 6GB+ recommended
- **Storage**: 8GB minimum, 32GB+ recommended

### **Network Requirements**
- **WiFi**: For development and testing
- **Mobile Data**: For real-world testing
- **Internet Connection**: Required for API communication

## 🚀 Quick Setup Commands

### **Check Available Devices**
```bash
flutter devices
```

### **Run on Specific Device**
```bash
# Run on connected Android device
flutter run -d android

# Run on connected iOS device
flutter run -d ios

# Run on Windows desktop
flutter run -d windows

# Run on specific device by ID
flutter run -d <device-id>
```

### **Build for Specific Platform**
```bash
# Build Android APK
flutter build apk

# Build Android App Bundle
flutter build appbundle

# Build iOS (Mac only)
flutter build ios

# Build Windows desktop
flutter build windows
```

## 📋 Device Testing Checklist

### **Before Running Your Loyalty App**

1. **✅ Flutter Installation**
   ```bash
   flutter doctor
   ```

2. **✅ Device Connection**
   ```bash
   flutter devices
   ```

3. **✅ Dependencies**
   ```bash
   flutter pub get
   ```

4. **✅ API Configuration**
   - Verify `baseUrl` in `lib/core/services/api_service.dart`
   - Ensure your Loyalty Engine API is running

5. **✅ Network Access**
   - Check internet connection
   - Verify API server accessibility

## 🎯 Recommended Testing Devices

### **Android Testing**
- **Phone**: Google Pixel 6/7, Samsung Galaxy S21/S22
- **Tablet**: Samsung Galaxy Tab S7/S8, Lenovo Tab P11
- **Budget**: Xiaomi Redmi Note series, Samsung Galaxy A series

### **iOS Testing**
- **Phone**: iPhone 12/13/14 series
- **Tablet**: iPad Air/Pro (2020+)
- **Budget**: iPhone SE (2020/2022)

## 🔍 Device-Specific Considerations

### **For Your Loyalty App**

1. **Responsive Design**: The app is designed to work on various screen sizes
2. **Touch Interactions**: Optimized for touch input (punch card interactions)
3. **Network Handling**: Graceful handling of poor network conditions
4. **Storage**: Minimal local storage requirements
5. **Performance**: Optimized for smooth animations and transitions

### **Testing Scenarios**
- **Portrait Mode**: Primary orientation
- **Landscape Mode**: Supported for tablets
- **Different Screen Densities**: Test on various pixel densities
- **Network Conditions**: Test with slow/fast internet
- **Background/Foreground**: App state management

## 🛠️ Troubleshooting Device Issues

### **Common Problems**

1. **Device Not Detected**:
   ```bash
   flutter doctor
   adb devices  # for Android
   ```

2. **Build Errors**:
   ```bash
   flutter clean
   flutter pub get
   ```

3. **Performance Issues**:
   - Enable performance overlay: `flutter run --profile`
   - Check for memory leaks
   - Optimize image assets

4. **Network Issues**:
   - Verify API server is running
   - Check firewall settings
   - Test with different network conditions

## 📊 Device Compatibility Matrix

| Device Type | Android Version | iOS Version | Windows Version | Status | Notes |
|-------------|----------------|-------------|----------------|--------|-------|
| Modern Phones | 8.0+ | 14.0+ | - | ✅ Full Support | Optimal experience |
| Mid-range Phones | 7.0+ | 12.0+ | - | ✅ Supported | Good performance |
| Budget Phones | 6.0+ | 11.0+ | - | ⚠️ Limited | Basic functionality |
| Tablets | 8.0+ | 12.0+ | - | ✅ Supported | Responsive design |
| Windows Desktop | - | - | 10 (1903)+ | ✅ Full Support | Native desktop experience |
| Older Devices | 5.0+ | 11.0+ | - | ❌ Not Recommended | Performance issues |

## 🔧 Development Environment Setup

### **Windows Development**
- **Required**: Visual Studio with C++ build tools, Android Studio, Android SDK
- **Optional**: VS Code with Flutter extension
- **Testing**: Windows desktop, Android emulator, or physical device

### **macOS Development**
- **Required**: Xcode, Android Studio
- **Optional**: VS Code with Flutter extension
- **Testing**: iOS Simulator, Android emulator, or physical devices

### **Linux Development**
- **Required**: Android Studio, Android SDK
- **Optional**: VS Code with Flutter extension
- **Testing**: Android emulator or physical device

## 📱 App-Specific Device Features

### **Required Features**
- **Touch Screen**: Multi-touch support
- **Internet Connectivity**: WiFi or mobile data
- **Storage**: At least 50MB free space
- **RAM**: 2GB minimum for smooth operation

### **Optional Features**
- **Biometric Authentication**: Fingerprint/Face ID
- **Camera**: QR code scanning (future feature)
- **GPS**: Location-based rewards (future feature)
- **NFC**: Contactless payments (future feature)

## 🎨 UI/UX Considerations

### **Screen Sizes**
- **Small Phones**: 4.7" - 5.5" (iPhone SE, older Android)
- **Standard Phones**: 5.5" - 6.5" (Most modern phones)
- **Large Phones**: 6.5" - 7.0" (iPhone Pro Max, Samsung Ultra)
- **Tablets**: 7.0" - 12.9" (iPad, Android tablets)

### **Orientation Support**
- **Primary**: Portrait mode
- **Secondary**: Landscape mode (tablets)
- **Responsive**: Automatic layout adjustment

### **Accessibility**
- **Text Scaling**: Support for system font size
- **High Contrast**: Dark/light theme support
- **Touch Targets**: Minimum 44x44 points
- **Screen Readers**: VoiceOver/TalkBack support

## 🔄 Continuous Testing

### **Automated Testing**
```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Run widget tests
flutter test test/widget_test.dart
```

### **Manual Testing Checklist**
- [ ] App launches successfully
- [ ] Login/registration works
- [ ] Dashboard loads correctly
- [ ] Punch cards display properly
- [ ] Points system functions
- [ ] Rewards are accessible
- [ ] Notifications work
- [ ] Profile management functions
- [ ] App handles network errors gracefully
- [ ] Performance is acceptable

## 📈 Performance Benchmarks

### **Target Performance**
- **App Launch**: < 3 seconds
- **Screen Transitions**: < 300ms
- **API Calls**: < 2 seconds
- **Memory Usage**: < 100MB
- **Battery Impact**: Minimal

### **Testing Tools**
- **Flutter Inspector**: UI debugging
- **Performance Overlay**: Real-time metrics
- **DevTools**: Advanced debugging
- **Firebase Performance**: Production monitoring

## 🔒 Security Considerations

### **Device Security**
- **Biometric Authentication**: Optional login method
- **Secure Storage**: Encrypted local data
- **Network Security**: HTTPS API communication
- **App Signing**: Verified app distribution

### **Data Protection**
- **Token Storage**: Secure JWT storage
- **User Data**: Local encryption
- **Network Requests**: Certificate pinning (optional)
- **Privacy**: GDPR compliance

## 📞 Support & Resources

### **Flutter Documentation**
- [Flutter.dev](https://flutter.dev/docs)
- [Dart.dev](https://dart.dev/guides)
- [Flutter GitHub](https://github.com/flutter/flutter)

### **Device Testing Resources**
- [Android Developer](https://developer.android.com/guide)
- [Apple Developer](https://developer.apple.com/ios/)
- [Flutter Testing](https://flutter.dev/docs/testing)

### **Community Support**
- [Flutter Community](https://flutter.dev/community)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)
- [Reddit r/FlutterDev](https://reddit.com/r/FlutterDev)

---

**Note**: This document should be updated as new devices and Flutter versions are released. Always test on multiple devices before releasing to production. 