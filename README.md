# 📱 Inventory Android App

Inventory Android App is a native mobile application built using **Flutter/Android Studio** to help users manage and track inventory items. It lets users add, view, update, and delete inventory records — perfect for small stores, personal collections, or stock tracking.

## 🎯 Purpose

This app was created as part of a job application project for 2026, showcasing mobile development skills using Flutter and SQLite for local data persistence.

## 🧠 What I Learned
- Building mobile interfaces with Flutter/Android Studio  
- Managing local data storage using SQLite  
- Implementing CRUD operations in a mobile environment  
- State management for dynamic inventory lists  
- Connecting UI components to database logic  
- Debugging and testing on Android emulators and real devices  

## ✨ Features

- 📝 Add new inventory items  
- 📊 View list of all items  
- ✏️ Update existing item details  
- ❌ Delete items  
- 🔎 Search through inventory  
- 🚀 Simple and intuitive mobile UI  
- 💾 Local persistent storage (SQLite or built‑in storage)

## 🛠️ Tech Stack

- **Framework:** Flutter  
- **Language:** Dart  
- **Database:** SQLite or local device storage  
- **IDE:** Android Studio or Visual Studio Code

## 📂 Project Structure

```bash
Inventory-Android-App/
├── android/              # Native Android platform code
├── ios/                  # iOS platform support (if enabled)
├── lib/                  # Main Flutter Dart code
│   ├── main.dart         # App entrypoint
│   ├── screens/          # UI screens
│   ├── models/           # Data models
│   ├── db/               # Database helper files
│   └── widgets/          # Reusable widgets
├── pubspec.yaml          # Dependencies & config
├── README.md
└── assets/               # Images, icons, fonts
```

## 🚀 Installation Guide

### 1️⃣ Clone the repository
```bash
git clone https://github.com/AlcaydeKen/Inventory-Android-App.git
cd Inventory-Android-App
```

### 2️⃣ Install dependencies
```bash
flutter pub get
```
### 3️⃣ Connect a device or start an emulator

- Use Android Studio AVD or connect a physical Android device with USB debugging enabled.

### 4️⃣ Run the app
```bash
flutter run
```

## 📱 Screens / Main UI
- 🏠 Main inventory list
- ➕ Add new item screen
- ✏️ Update item screen
- 🔍 Search inventory
- ⚙️ Settings (if available)

## 🗄️ Storage
- The app uses local device storage (SQLite or shared preferences via Flutter plugin) to save inventory data persistently.

## 🔮 Future Improvements
- 📸 Add image support for items
- 📦 Export inventory to CSV/Excel
- 🔔 Low stock notifications
- 🔐 User login/permissions
- ☁️ Cloud sync (Firebase/Backend API)


## 👨‍💻 Author

Ken Jared Alcayde

GitHub: [@AlcaydeKen](https://github.com/AlcaydeKen)
