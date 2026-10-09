# Android Release Build & Distribution Guide — RealCash

This document describes the steps required to generate a signed Android APK for testing and an Android App Bundle (.aab) for Google Play Store submission.

---

## 1. Prerequisites
- Android Studio with Android SDK (API level 33+)
- Flutter SDK installed (`flutter doctor`)
- Java Development Kit (JDK 17)

---

## 2. Generating Keystore & Signing Key

Run the following command to generate a upload keystore file:

```bash
keytool -genkey -v -keystore android/app/upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Create a file at `android/key.properties` with the following content:

```properties
storePassword=<YOUR_STORE_PASSWORD>
keyPassword=<YOUR_KEY_PASSWORD>
keyAlias=upload
storeFile=upload-keystore.jks
```

---

## 3. Building Signed Android Release Targets

### A. APK for Direct Testing
To build a standalone signed APK:

```bash
cd mobile
flutter build apk --release
```

The compiled APK will be located at:
`mobile/build/app/outputs/flutter-apk/app-release.apk`

### B. App Bundle (.aab) for Google Play Store
To build an Android App Bundle for Google Play Console submission:

```bash
cd mobile
flutter build appbundle --release
```

The output bundle will be located at:
`mobile/build/app/outputs/bundle/release/app-release.aab`

---

## 4. Google Play Console Submission Checklist
- Upload `app-release.aab` under Production / Internal Testing track.
- Provide Privacy Policy URL pointing to RealCash compliance page.
- Complete Gambling & Real-Money Games Declaration Form in Google Play Console (if applicable in your jurisdiction).
