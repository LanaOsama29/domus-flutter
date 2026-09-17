# DOMUS 🏠

> **A modern Flutter-based real estate mobile application for discovering, searching, booking, and managing apartment listings.**

---

## 📌 Overview

**DOMUS** is a mobile real estate application developed with **Flutter** to provide users with a convenient way to discover and explore apartment listings, search and filter available properties, manage favorites, make bookings, communicate through chat, and interact with apartment listings through ratings.

The application also provides dedicated functionality for apartment owners to publish and manage their listings and handle incoming booking requests.

This repository contains the **Flutter frontend** of the DOMUS application.

---

## ✨ Features

### 👤 User Features

* User authentication
* Apartment browsing and exploration
* Apartment search
* Apartment filtering
* Detailed apartment information
* Favorites management
* Apartment booking
* Booking management
* Booking editing
* Rating functionality
* In-app chat
* User profile
* Application settings
* Light and dark theme support

### 🏢 Owner Features

* Owner authentication
* Add apartment listings
* Upload apartment images
* Manage published apartments
* Manage apartment information
* View incoming booking requests
* Manage booking-related information

---

## 🛠️ Tech Stack

| Technology                   | Purpose                                                |
| ---------------------------- | ------------------------------------------------------ |
| **Flutter**                  | Cross-platform mobile application development          |
| **Dart**                     | Application programming language                       |
| **GetX**                     | State management, dependency injection, and navigation |
| **GetStorage**               | Local data persistence                                 |
| **Dio**                      | HTTP/API communication                                 |
| **Firebase Authentication**  | Authentication services                                |
| **Cloud Firestore**          | Cloud data services                                    |
| **Firebase Storage**         | File and image storage                                 |
| **Firebase Cloud Messaging** | Push notifications                                     |
| **Google Sign-In**           | Google authentication                                  |
| **WebSocket Channel**        | Real-time communication                                |
| **Lottie**                   | UI animations                                          |
| **Image Picker**             | Image selection                                        |
| **Flutter SVG**              | SVG rendering                                          |
| **Provider**                 | State management support                               |
| **Shared Preferences**       | Local preferences                                      |
| **Intl**                     | Date and number formatting                             |

The project's declared dependencies include these Flutter, Firebase, networking, storage, UI, and utility packages.

---

## 🏗️ Architecture

DOMUS follows a layered Flutter architecture that separates application logic, data models, services, and UI components.

```text
lib/
│
├── Binding/
│   └── Dependency & route bindings
│
├── controller/
│   └── Application controllers
│
├── model/
│   └── Data models
│
├── services/
│   └── API and service layer
│
├── view/
│   └── Application UI
│
└── main.dart
```

### State Management

The application uses **GetX** for:

* Reactive state management
* Dependency injection
* Navigation
* Controller-based business logic

### Local Storage

**GetStorage** is used for local persistence and application state.

### API Communication

The frontend uses dedicated service classes and **Dio** for communication with the backend API.

---

## 📱 Application Flow

### User

```text
Authentication
      ↓
Home
      ↓
Explore
      ↓
Search / Filter
      ↓
Apartment Details
      ↓
Booking
      ↓
Booking Management
      ↓
Rating
```

Additional user functionality includes:

```text
Favorites
Chat
Profile
Settings
```

### Owner

```text
Authentication
      ↓
Owner Dashboard
      ↓
Add Apartment
      ↓
Publish Listing
      ↓
Manage Apartments
      ↓
Manage Booking Requests
```

---

## 🎨 User Experience

DOMUS focuses on providing a clean and intuitive experience for discovering and managing apartment listings.

The application includes:

* Custom Flutter UI components
* Light and dark themes
* Custom navigation
* Interactive forms
* Image selection and upload
* Animated UI elements
* Custom application branding
* Native splash screen

The project also defines custom application icon and splash-screen configuration in `pubspec.yaml`.

---

## 📂 Project Structure

```text
domus/
│
├── android/
├── ios/
├── images/
├── lib/
│   ├── Binding/
│   ├── controller/
│   ├── model/
│   ├── services/
│   ├── view/
│   └── main.dart
│
├── test/
├── analysis_options.yaml
├── pubspec.yaml
├── pubspec.lock
├── .gitignore
└── README.md
```

---

## ⚙️ Requirements

Before running the project, make sure you have:

* Flutter SDK
* Dart SDK
* Android Studio or another supported Flutter development environment
* Android/iOS emulator or physical device
* Access to the DOMUS backend API

The project currently specifies Dart SDK compatibility using:

```yaml
sdk: ^3.7.2
```

---

## 🚀 Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/YOUR_USERNAME/domus-flutter.git
```

### 2. Navigate to the project

```bash
cd domus-flutter
```

### 3. Install dependencies

```bash
flutter pub get
```

### 4. Configure the backend

Configure the API endpoint according to your local or deployed backend environment.

### 5. Run the application

```bash
flutter run
```

---

## 🔌 Backend Integration

The DOMUS frontend communicates with a backend API for application data and operations.

The backend is **not included in this repository**.

This repository contains the **Flutter mobile frontend only**.

---

## 🔐 Configuration & Security

For security reasons, sensitive credentials and environment-specific configuration should not be committed to the repository.

Before running the application, configure the required Firebase and backend settings for your environment.

Do not commit:

```text
.env
google-services.json
GoogleService-Info.plist
private keys
API secrets
authentication tokens
```

---

## 📦 Flutter Configuration

DOMUS uses Flutter configuration for:

* Application assets
* Material icons
* Application launcher icon
* Native splash screen
* Custom fonts and visual resources

The project currently uses `flutter_native_splash` and `flutter_launcher_icons` for application branding.

---

## 🎓 Project Context

DOMUS was developed as a **university software project** as a practical Flutter application focused on real estate and apartment rental management.

The project demonstrates the implementation of:

* Mobile UI development
* State management
* REST API integration
* Authentication
* Local data persistence
* Image handling
* Booking workflows
* Real-time communication
* Firebase services

---

## 📄 License

This project was developed for educational purposes.

---

## 👩‍💻 DOMUS

**DOMUS — Real Estate Mobile Application**

Built with ❤️ using Flutter & Dart.
