# Tara Mobile

Flutter app (Android only for now).

## Running

```bash
cd tara/mobile
flutter run
```

By default the app calls the API at `https://tara-ukju.onrender.com`. You can
override it per run with:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

## App icon

Update `assets/icon.png`, then run:

```bash
flutter pub get
dart run flutter_launcher_icons
```

## Release APK

1) Create `android/key.properties` based on `android/key.properties.example`.
2) Place the keystore at `android/app/tara-keystore.jks`.
3) Build:

```bash
flutter build apk --release
```

The release APK will be named `tara-app.apk` in
`build/app/outputs/flutter-apk/`.
