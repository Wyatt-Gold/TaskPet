# TaskPet Setup

TaskPet is a UIKit (storyboard) iOS app using Firebase Auth and Firestore, in MVVM (closure-based, no Combine/SwiftUI).

## 1. One-time Firebase console setup

Already done for the shared "TaskPet" Firebase project (`task-pet-58e5b`). If you're spinning up a fresh project instead:

1. [console.firebase.google.com](https://console.firebase.google.com) → Add project → skip Google Analytics → Create.
2. Add app → iOS → bundle ID `wyattgolden.EOY-Project` → Register → download `GoogleService-Info.plist`.
3. Build → Authentication → Get started → Sign-in method → enable **Email/Password** → Save.
4. Build → Firestore Database → Create database → nearest region → start in **production mode**.
5. Firestore Database → Rules tab → replace contents with [`firestore.rules`](./firestore.rules) → Publish.

## 2. Clone & run

1. Get `GoogleService-Info.plist` from the team (it's gitignored — it's per-Firebase-project config, not shared source).
2. Drag it into the `EOY_Project` folder in Xcode's navigator, with target membership checked for `EOY_Project`.
3. Open `EOY_Project.xcodeproj`. Xcode resolves the `firebase-ios-sdk` Swift Package automatically (FirebaseAuth, FirebaseFirestore, FirebaseCore).
4. Build & run on a Simulator.

## 3. Verifying it works

1. Launch the app → brief Loading screen → routes to Login (first run, no account yet).
2. Sign up with a test account → check the Firebase Console:
   - **Authentication** tab shows the new user.
   - **Firestore → Data** tab shows `users/{uid}` (displayName, email, settings, connections) and `users/{uid}/pet/current` (default dog stats).
3. Force-quit and relaunch → should route straight to Home (session persisted).
4. Try "Forgot password?" on the Login screen → check the test account's inbox for Firebase's reset email.

## Notes

- `GoogleService-Info.plist` is gitignored — never commit it.
- Tasks/Daily Stats Firestore collections are modeled (`TaskItem`, `DailyStats`) but have no repository/UI yet — add those when the Tasks/Home features are built.
- Pet care, step tracking, Canvas/calendar integration are out of scope here — only stub screens exist for those flows.
