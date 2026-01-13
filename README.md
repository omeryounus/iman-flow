# Iman Flow 🕌

A comprehensive Islamic companion app built with Flutter, featuring prayer times, Quran with AI insights, devotionals, community features, and more.

## Features

### 🕋 Prayer Tab
- Accurate prayer times based on location
- Qibla compass with AR support
- Prayer tracking and notifications
- Multiple calculation methods

### 📖 Quran & AI Tab
- Full Quran with Arabic text and translations
- AI-powered verse insights and explanations
- Voice-to-text search
- Bookmarks and reading history

### 🤲 Devotionals Tab
- Dua library with supplication wall
- Dhikr counter with customizable goals
- Daily adhkar (morning/evening)
- Audio recitations

### 👥 Community Tab
- Verse sharing with beautiful designs
- Community challenges
- Quran puzzles and games
- Women-focused mode

### 🏠 Home Dashboard
- Personalized greeting
- Next prayer countdown
- Streak tracking
- Daily verse

### ⭐ Premium Features
- Unlimited AI Quran insights
- Ad-free experience
- Custom Dhikr goals
- Premium recitations
- Offline Quran access

## Getting Started

### Prerequisites
- Flutter 3.2.0 or higher
- Dart SDK
- iOS: Xcode 14+
- Android: Android Studio with SDK 33+

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd iman-flow
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # iOS Simulator
   flutter run -d ios
   
   # Android Emulator
   flutter run -d android
   
   # Chrome (Web)
   flutter run -d chrome
   ```

## Configuration

### Firebase Setup (Optional)
1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Run FlutterFire CLI:
   ```bash
   flutterfire configure
   ```
3. This generates `firebase_options.dart` automatically

### RevenueCat Setup (Premium Features)
1. Create account at [revenuecat.com](https://revenuecat.com)
2. Add your API key in `lib/core/services/premium_service.dart`:
   ```dart
   await Purchases.configure(PurchasesConfiguration('YOUR_API_KEY'));
   ```

### AI Service (Groq)
Add your Groq API key in `lib/core/services/ai_service.dart` for AI-powered insights.

## Project Structure

```
lib/
├── app/
│   ├── app.dart          # Main app widget
│   ├── routes.dart       # GoRouter configuration
│   └── theme.dart        # App theme and colors
├── core/
│   └── services/         # Business logic services
│       ├── prayer_service.dart
│       ├── quran_service.dart
│       ├── ai_service.dart
│       ├── premium_service.dart
│       └── ...
├── features/
│   ├── home/             # Home dashboard
│   ├── prayer/           # Prayer times & Qibla
│   ├── quran_ai/         # Quran & AI insights
│   ├── devotionals/      # Duas, Dhikr, Adhkar
│   ├── community/        # Social features
│   └── premium/          # Subscription UI
├── shared/
│   └── widgets/          # Reusable components
└── main.dart             # App entry point
```

## Tech Stack

- **Framework**: Flutter 3.x
- **State Management**: flutter_bloc
- **Navigation**: go_router
- **Backend**: Firebase (Auth, Firestore, Messaging)
- **Monetization**: RevenueCat (purchases_flutter)
- **Prayer Calculation**: adhan
- **AI**: Groq API
- **Audio**: just_audio

## License

MIT License - See LICENSE file for details.
