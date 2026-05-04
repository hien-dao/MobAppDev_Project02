# 🌴 TropicaGuide – Travel Planner

TropicaGuide is a collaborative, gamified travel planning app built with Flutter and Firebase. It transforms stressful trip coordination into an engaging, social experience by helping groups plan, optimize, and manage itineraries together in real time.

---

## ✨ Core Concept

TropicaGuide acts as a digital travel companion that enables users to:

- Collaboratively build and manage trip itineraries  
- Discover and organize activities  
- Optimize travel plans based on real-world constraints  
- Coordinate packing and trip preparation  

---

## 🚀 Features

### 🔐 Authentication
- Firebase Authentication for secure user sign-in and identity management


### 🗺️ Itinerary Planning
- Create and manage trip itineraries
- Drag-and-drop interface for reordering activities
- Shared access for group collaboration
- App generate itineraray schedule

### 🔍 Activity Database & Search
- Activities stored in Firestore
- Search and browse available activities (places to visit)

### 🤝 Real-Time Collaboration
- Multi-user editing with Firestore real-time synchronization
- Instant updates across all connected users

### 🔔 Push Notifications
- Firebase Cloud Messaging (FCM)
- Alerts for trip invintations

---

## 🧠 Itinerary Optimization Engine

TropicaGuide includes a custom itinerary optimization system that:

- Schedule activities based on:
  - ⏰ Estimted durations of activities
  - 📍 Travel time and distance 
- Reorders activities when user push button

---

## 🏗️ Tech Stack

- **Frontend:** Flutter  
- **Backend & Services:** Firebase  
  - Firestore (database)  
  - Firebase Authentication  
  - Firebase Storage  
  - Firebase Cloud Messaging (FCM)  

---

## 📱 Download APK

You can download and install the latest Android APK directly from GitHub Releases:

1. Go to the **Releases** section of this repository  
2. Download the latest `.apk` file  
3. Install it on your Android device (enable "Install from unknown sources" if prompted)

🔗 Example link:  
https://github.com/hien-dao/MobAppDev_Project02/releases

---

## ⚙️ Key Challenges

- Building an intuitive drag-and-drop itinerary UI  
- Maintaining real-time synchronization across users  
- Managing complex nested Firestore data structures  
- Resolving merge conflicts in collaborative environments  
- Designing a transparent and explainable optimization algorithm  

---

## 📦 Project Structure

```
lib/
├── models/
│   ├── activity.dart
│   ├── app_notification.dart
│   ├── trip_invite.dart
│   ├── trip.dart
│   └── user.dart
├── services/
│   ├── activity_databasehelper.dart
│   ├── app_notification_service.dart
│   ├── auth_service.dart
│   ├── invite_service.dart
│   ├── itinerary_service.dart
│   ├── notification_service.dart
│   ├── place_service.dart
│   ├── route_optimizer.dart
│   └── trip_databasehelper.dart
├── screens/
│   ├── createaccount.dart
│   ├── loginscreen.dart
│   ├── activity_screen.dart
│   ├── add_activity_screen.dart
│   ├── add_trip.dart
│   ├── firstscreen.dart
│   └── mainscreen.dart
└── main.dart
```

---

## 🛠️ Setup & Installation

1. Clone the repository:
```
git clone https://github.com/hien-dao/MobAppDev_Project02.git
```

2. Install dependencies:
```
flutter pub get
```

3. Configure Firebase:
- Add `google-services.json` (Android)
- Add `GoogleService-Info.plist` (iOS)
- Enable:
  - Authentication
  - Firestore
  - Storage
  - Cloud Messaging

4. Run the app:
```
flutter run
```

---

## 📡 Firebase Usage Summary

| Service                   | Purpose                                      |
|--------------------------|----------------------------------------------|
| Firestore                | All app data (users, itineraries, checklists)|
| Firebase Authentication  | User identity                                |
| Firebase Storage         | Activity images                              |
| Firebase Cloud Messaging | Push notifications                           |

---

## 📌 Future Improvements

- AI-powered travel recommendations  
- Offline support with sync  
- Map integration for route visualization  
- Expense splitting between travelers  

---

## 🤝 Contribution

This project was developed as part of a final course requirement. Contributions and suggestions are welcome.

---

## 📄 License

This project is for educational purposes.