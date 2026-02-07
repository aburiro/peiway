# 🌍 Peiway

Peiway is a Flutter-based mobile application designed to help tourists and local users explore points of interest using real-time GPS location and interactive maps. The application integrates Geoapify map services to provide smart place search, dynamic map styles, and accurate location tracking, offering a smooth and user-friendly navigation experience on both Android and iOS platforms.

## 🚀 Features

* 📍 Real-time GPS location tracking
* 🔎 Search for cities, landmarks, and points of interest
* 🗺️ Interactive maps with multiple map styles
* 📌 Custom markers and popups
* 📱 Clean and responsive Flutter UI
* 🌐 Cross-platform support (Android & iOS)

## 🛠️ Technologies Used

* **Flutter** – Cross-platform mobile development framework
* **Dart** – Programming language
* **Geoapify API** – Maps, tiles, and location services
* **flutter_map** – Map rendering
* **geolocator** – Device location access
* **http** – API communication

## 📋 Prerequisites

Before running this project, make sure you have:

* Flutter SDK (version 3.3.0 or higher)
* Android Studio or VS Code
* Android emulator or physical device
* A free Geoapify API key

## 📥 Installation

1. Clone the repository:

```bash
git clone https://github.com/aburiro/peiway.git
cd peiway
```

2. Install dependencies:

```bash
flutter pub get
```

3. Add your Geoapify API key:

Open the relevant Dart file and replace:

```dart
YOUR_GEOAPIFY_API_KEY
```

with your actual API key.

## 📱 Platform Permissions

### Android

Add the following permission in `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

### iOS

Add the following to `Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app requires location access to show nearby places.</string>
```

## ▶️ Run the App

```bash
flutter run
```

## 🤝 Contributing

Contributions are welcome! Please fork the repository, create a new branch, commit your changes, and open a pull request.

## 📄 License

This project is open-source and available under the MIT License.

---

Developed with ❤️ using Flutter.
