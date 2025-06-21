# Momentum - A Daily Photo/Video Recap App

## ✨ Project Overview

**Momentum** is a lean, proof-of-concept Flutter application built to demonstrate core functionalities essential for modern social media platforms, particularly those focused on rich media sharing. Inspired by the requirements of "Another" (a next-generation social platform for photo/video sharing), this project showcases robust mobile development practices, deep integration with Firebase, and efficient handling of user-generated content.

Please note the intention is to deep dive into the core requirements and thus the MVP will just have a 
skeleton UI. As we progress we will update it for better UX.

This application is developed with a strong emphasis on **ownership, rapid iteration, and performance**, reflecting the fast-paced environment of a high-growth startup.

## 🌟 Features Implemented (Current MVP)

  * **Secure User Authentication:** Implemented with Firebase Authentication (Email/Password) for seamless user signup and login flows.
  * **Media Capture & Selection:** Users can effortlessly pick photos or videos from their device gallery using `image_picker`.
  * **Firebase Storage Integration:** Seamlessly uploads selected media (photos/videos) to Firebase Storage, demonstrating scalable content storage.
  * **Firestore Data Management:** Stores media metadata (download URL, timestamp, user ID, media type) in Firestore, establishing a robust data model for user-generated content.
  * **Personalized Media Feed:** Displays a user's uploaded photos and videos in a dynamic, real-time feed by querying Firestore and retrieving media from Storage.
  * **Cross-Platform Compatibility:** Built with Flutter for a single codebase across iOS and Android.

## 🚀 Getting Started

To run this project locally, follow these steps:

### Prerequisites

  * Flutter SDK installed ([Installation Guide](https://flutter.dev/docs/get-started/install))
  * A Firebase project configured with:
      * Firebase Authentication (Email/Password provider enabled)
      * Cloud Firestore
      * Cloud Storage
  * `google-services.json` (for Android) and `GoogleService-Info.plist` (for iOS) downloaded from your Firebase project and placed in the respective `android/app` and `ios/Runner` directories.

### Setup Instructions

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/JoshuaNgugi/momentum.git
    cd momentum-app
    ```
2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Run the app:**
    ```bash
    flutter run
    ```

## 🛠️ Technologies Used

  * **Flutter:** The UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase.
  * **Dart:** The programming language used by Flutter.
  * **Firebase:** Google's comprehensive mobile and web development platform.
      * **Firebase Authentication:** For user management.
      * **Cloud Firestore:** A flexible, scalable database for mobile, web, and server development.
      * **Cloud Storage for Firebase:** For storing and serving user-generated content like photos and videos.
  * **`image_picker`:** A Flutter plugin for picking images and videos from the image library, or taking new ones with the camera.

## 📈 Future Enhancements (Roadmap)

This project serves as a foundational MVP. Future planned enhancements to align even more closely with advanced social media app requirements include:

  * **Advanced Media Processing:**
      * Client-side image compression (using `flutter_image_compress`).
      * Integration with Firebase Cloud Functions for server-side video transcoding and image resizing for optimal delivery.
  * **Content Ephemerality:** Implementing logic for content to disappear after a set time (e.g., 7 days) using Firestore TTL or scheduled Cloud Functions.
  * **"Mutual-Viewing" System:** Refining Firestore security rules and data models to support a reciprocal viewing mechanism, ensuring privacy and controlled access.
  * **Enhanced UI/UX:** Smooth animations, loading indicators, and more polished user flows.
  * **Comprehensive Error Handling:** Robust error feedback to users for network issues, upload failures, etc.
  * **State Management:** Migrating to a more robust state management solution (e.g., Provider, Riverpod, BLoC) for larger-scale applications.
  * **Unit & Integration Testing:** Expanding test coverage to ensure stability and maintainability.

## 💡 Why This Project? (Relevance to "Another")

This "Momentum" app directly addresses key technical challenges and requirements outlined in the "Another" job description:

  * **Full Ownership:** Demonstrates the ability to take a feature set from conception (designing the data flow) to deployment (handling media uploads and display).
  * **Media-Heavy User Flows:** Provides hands-on experience with capturing, uploading, storing, and displaying photos/videos.
  * **Firebase Expertise:** Showcases deep proficiency with Firebase Auth, Firestore, and Storage – the core backend services for "Another."
  * **Performance Optimization (Foundational):** While this MVP focuses on functionality, the choice of efficient data retrieval and handling sets the stage for further performance initiatives. My prior experience includes a **24% reduction in app load time** in a previous role, a mindset carried into this project.
  * **Code Quality & Responsiveness:** Built with clean code practices and a focus on direct user interaction.

This project is a testament to my **ownership mentality** and dedication to building scalable, high-quality mobile applications in a fast-moving environment.

-----

## 🤝 Contribution

Feel free to fork the repository, open issues, or submit pull requests.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](https://www.google.com/search?q=LICENSE) file for details.

-----

### Developed with ❤️ by Joshua Ngugi

[My LinkedIn Profile](https://www.google.com/search?q=https://www.linkedin.com/in/joshua-ngugi/) | [My GitHub Profile](https://www.google.com/search?q=https://github.com/JoshuaNgugi/)

-----
