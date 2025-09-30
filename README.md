# Agora Call Application

A new Flutter project for audio and video calling functionality.

## Getting Started

This project is a starting point for a Flutter application that uses Agora for audio and video calls, Firestore for user information and call status, and an audio player for playing ringtones.

### Repository URL

The source code for this project is available at: [Agora Repository](https://github.com/shahsandeep/agora.git)

### Tech Stack

- **Framework:** Flutter
- **Real-time Communication:** Agora SDK

### Flutter Version

This project uses **Flutter version 3.24.4**.

### Installation

1. **Clone the repository:**

   ```sh
   git clone https://github.com/shahsandeep/Agora.git
   cd Agora
   ```
2. **Install dependencies:**

   ```sh
   flutter pub get
   ```
3. **Set up Firebase:**

   - Follow the instructions to set up Firebase for your Flutter project: [Firebase Setup](https://firebase.flutter.dev/docs/overview)
   - Add your `google-services.json` for Android and `GoogleService-Info.plist` for iOS to the respective directories.
4. **Run the application:**

   ```sh
   flutter run
   ```

### Usage

1. **Launch the app on two devices.**
2. **Proceed login with autofilled credentials.**
3. **From Bottom Navigation bar select calls or Users as per the requirement.**
4. **On the first device, select "I am Caller".**
5. **On the second device, select "I am Receiver".**
6. **The call logic will be executed based on the selection.**

### Features

- **Splash screen:** and app icon included.
- **Authentication & Login Screen:** a simple email/password form with validation and mock authentication using Reqres
- **Session management and logout:** persist session token (shared_preferences), validate/refresh session on app start, and provide a logout action that clears stored session data and returns to the login screen.
- **Audio and Video Calls:** Using Agora SDK for real-time communication.
- **Audio Calls UI:** Calling UI with mic, speaker, hangup button, and timer on call receive.
- **Video Calls UI:** Calling UI with camera disable, mic mute, camera flip, and hangup button, on call receive.
- **Screen Sharing:** Screen sharing capability during video calls.
- **Agora RTC Token Generation:** Using for secure call sessions.
- **Ringtone:** Using `audioplayers` package to play ringtones.
- **Notifications**: A notification with Accept and Reject buttons to handle incoming calls on the receiver screen.
- **User Information and Call Status:** Using Firestore to manage user data and call status.
- **Real-time Call UI:** Displaying call status and user interface in real-time.
- **Device Connection Status:** Checking device connection status if it is connected to network or not.
- **Users screen:** with dummy users cached in Hive (load local first, then fetch fresh from API).
- **Github Actions:** When you push code to the main branch, GitHub automatically builds the Android app and creates a Release with the generated APK files. This means you get a downloadable build without doing any manual build steps. To allow the workflow to upload releases, add a repository secret named `TOKEN`.

### Tested On

- **Android:**
- **iOS:**

### Dependencies

- **Flutter SDK**
- **Cupertino Icons:** ^1.0.8
- **Flutter Bloc:** ^9.0.0
- **Agora RTC Engine:** ^6.3.2
- **Permission Handler:** ^11.3.1
- **Firebase Core:** ^3.10.1
- **Firebase Storage:** ^12.4.1
- **Cloud Firestore:** ^5.6.2
- **Audioplayers:** ^6.1.1
- **Fluttertoast:** ^8.2.12
- **Agora UIKit:** [GitHub Repository](https://github.com/mohamedibrahim33/VideoUIKit-Flutter-min-SDK-21)
- **Agora RTM:** ^1.5.9
- **Connectivity Wrapper:** ^2.0.0 - To check if the device is connected to a network.
- **hive_flutter:** ^1.1.0
- **flutter_local_notifications:** ^19.4.2
- **dio:** ^5.9.0
- **shared_preferences:** ^2.5.3

For help getting started with Flutter development, view the [online documentation](https://docs.flutter.dev/), which offers tutorials, samples, guidance on mobile development, and a full API reference.

## Agora Flutter SDK Setup with Agora UIKit

## Overview

This guide provides the high-level steps to set up and configure the Agora Flutter SDK using  **Agora UIKit** . Agora UIKit simplifies integration by offering ready-to-use video calling components.

---

## Setup Steps

### 1. Create an Agora Account

* Sign up or log in at the [Agora Console](https://https://console.agora.io/).
* Create a new project and obtain the  **App ID** .
* Generate a temporary token for testing.

### 2. Add Dependencies

* Add the **Agora UIKit** dependency to your Flutter project.
* Run package installation to fetch the SDK.

### 3. iOS Configuration

* Update `Info.plist` with required camera and microphone permissions.
* Set the minimum iOS deployment target (12.0 or higher).

### 4. Android Configuration

* Update `AndroidManifest.xml` with required permissions (Internet, Camera, Microphone).

### 5. Initialize the SDK

* Configure Agora connection data with your App ID, channel name, and token (if used).
* Initialize the Agora client before usage.

### 6. Integrate UI Components

* Use Agora UIKit’s prebuilt widgets to quickly integrate video calling UI.

### 7. Testing

* Run the app on a physical device.
* Join the same channel from multiple devices to verify video/audio functionality.

---

## Documentation

* [Agora Flutter SDK Docs]()
* [Agora UIKit for Flutter (pub.dev)]()
* [Agora Developer Guide]()

### APKs

Download APKs from the GitHub Releases section or via a direct download link.

Download the APKs for the Agora Call Application from the following link: [APKs Downloa](https://drive.google.com/drive/folders/16C14tRzredKhMGqfBM-oGd4TaPkAInZm?usp=drive_link)d

### Demo Video

Watch the demo video of the app in action: [Demo Video](https://drive.google.com/drive/folders/1W7JuTJghTIRZSxTLBe0SXjssUaEvPFgN?usp=sharing)

### Contact

Thank you for using the Agora Call Application. If you have any questions or need further assistance, feel free to contact me:

- **Name:** Sandeep Shah
- **Contact Number:** +917500542119
