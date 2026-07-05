# News2Learn

## News2Learn is a Flutter-based mobile application that helps users improve their English through real-world news articles and AI-powered conversation practice. The application integrates Firebase Authentication, Firestore, Gemini AI, Translation API, Speech-to-text (STT) and Text-to-Speech (TTS) to provide an interactive language learning experience.

## Features

### User Authentication

- Register with email and password
- Login and logout
- Password reset
- User profile management

### News Reading

- Browse English news articles
- Read article details
- Bookmark favorite articles
- Search articles by keywords
- Synchronize bookmarks with Firebase

### AI Chatbot

- Practice English conversations with AI
- Multiple conversation topics:
  - Job Interview
  - Restaurant Ordering
  - Hotel Reservation
  - Travel & Directions
  - Shopping
  - Daily Conversation

- Automatic grammar and spelling correction
- Context-aware AI responses
- Conversation starter based on selected topic
- Voice-to-Text conversation

### Translation & Pronunciation

- Translate AI responses into Vietnamese
- Listen to AI messages using Text-to-Speech (TTS)

### User Experience

- Modern Flutter UI
- Responsive layout
- Material Design components
- Smooth animations

---

## Technologies

### Frontend

- Flutter
- Dart

### Backend

- Firebase Authentication
- Cloud Firestore

### Artificial Intelligence

- Google Gemini API

### Additional Services

- Translation API
- Flutter TTS

---

## Installation

### Clone the repository

```bash
git clone
cd news2learn
```

### Install dependencies

```bash
flutter pub get
```

### Configure environment variables

Create a `.env` file in the project root.

```
GEMINI_API_KEY=YOUR_GEMINI_API_KEY
```

### Run the application (for Android Emulator)

```bash
flutter run
```

#### Recommended Platform

For the best experience, it is strongly recommended to run News2Learn on a physical Android device. If a physical device is unavailable, an Android Emulator can also be used.

Although Flutter supports running on the web, some features may not work as expected or may provide a different user experience.

#### Why use a physical Android device?

- Speech-to-Text (STT) performs more accurately on a real device. Users can tap the microphone button in the AI Chatbot to speak, and the application will convert their speech into text automatically before sending it to the AI.
- Text-to-Speech (TTS) playback is generally smoother and more consistent on Android devices.
- The application's user interface is designed and optimized primarily for Android smartphones. Running the application on the web may result in layout inconsistencies or responsive issues due to differences in screen size and browser rendering.

Recommendation: Use a physical Android device whenever possible. If unavailable, use an Android Emulator. Running the application in a web browser is intended mainly for development and testing purposes and may not fully reflect the intended user experience.
(If you still want to run the program on the web, use:`bash flutter run -d chrome --web-browser-flag "--disable-web-security `" )

## Firebase Configuration

The project requires Firebase configuration.

For Android:

```
android/app/google-services.json
```

Enable:

- Authentication (Email/Password)
- Cloud Firestore

---

## Dependencies

Main packages used:

```yaml
firebase_auth
cloud_firestore
firebase_core
google_generative_ai
flutter_tts
flutter_dotenv
http
webfeed
hive
hive_flutter
audioplayers
```

---

## Screenshots

- Login
  ![alt text](image.png)
- Register
  ![alt text](image-1.png)
- News List
  ![alt text](image-2.png)
- Article Detail
  ![alt text](image-7.png)
- Bookmark
  ![alt text](image-4.png)
- AI Chatbot
  ![alt text](image-5.png)
  ![alt text](image-6.png)
- Translation
  ![alt text](image-8.png)
  ![alt text](image-9.png)
  ![alt text](image-18.png)
- Learning
  ![alt text](image-10.png)
  ![alt text](image-11.png)
  ![alt text](image-12.png)
  ![alt text](image-13.png)
- User Profile
  ![alt text](image-14.png)
  ![alt text](image-15.png)
  ![alt text](image-16.png)
  ![alt text](image-17.png)

---

## Future Improvements

- Conversation history synchronization
- AI pronunciation evaluation
- Personalized learning recommendations

---

## Author

Graduation Project

Faculty of Information Technology
