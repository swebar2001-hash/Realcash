# iOS Release Build & Signing Guide — RealCash

This document provides step-by-step instructions for building and signing the RealCash iOS application for TestFlight testing and Apple App Store distribution.

---

## 1. Prerequisites
- macOS machine running Xcode 15+
- Apple Developer Account with active membership
- CocoaPods (`pod install`)

---

## 2. Configuration & App Signing

1. Open `mobile/ios/Runner.xcworkspace` in Xcode.
2. In the project navigator, select the `Runner` target.
3. Under **Signing & Capabilities**:
   - Enable **Automatically manage signing**.
   - Select your registered **Development Team**.
   - Set Bundle Identifier to `com.realcash.app`.
4. Ensure `Info.plist` includes permission strings for Camera & Location (for KYC identity checks).

---

## 3. Building Archive for TestFlight & App Store

In terminal:

```bash
cd mobile
flutter build ipa --release
```

Or via Xcode:
1. Select Target: `Any iOS Device (arm64)`.
2. Go to **Product > Archive**.
3. Once archiving completes, click **Distribute App**.
4. Select **TestFlight & App Store**.
5. Upload build to App Store Connect.

---

## 4. Apple App Store Guidelines Note
- Apple requires real-money gaming apps to hold valid regional licenses.
- Ensure age restriction rating is set to 17+ / 18+ on App Store Connect.
