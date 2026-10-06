# Firebase Setup Guide — Bani Family Tree

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"** → Name it `bani-family-tree`
3. Disable Google Analytics (optional) → **"Create project"**

---

## Step 2: Enable Firebase Services

### Authentication
1. Left sidebar → **Authentication** → **Get started**
2. **Sign-in method** tab → Enable **Google**
3. Set your **support email** → Save

### Firestore Database
1. Left sidebar → **Firestore Database** → **Create database**
2. Choose **"Start in production mode"**
3. Select nearest region (e.g. `asia-southeast1` for Indonesia) → **Enable**

### Firebase Storage
1. Left sidebar → **Storage** → **Get started**
2. Choose **"Start in production mode"** → Select same region → **Done**

---

## Step 3: Register Android App

1. Left sidebar → ⚙️ **Project Settings** → **Add app** → Android icon
2. **Android package name:** `com.bani.bani`
3. **App nickname:** `Bani Android`
4. **Debug SHA-1 fingerprint** — run this on your PC:
   ```powershell
   keytool -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
   ```
   Copy the `SHA1:` line and paste it.
5. Click **"Register app"**
6. **Download `google-services.json`** → place at:
   ```
   d:\paid app\famillytree\bani\android\app\google-services.json
   ```
7. Skip the "Add Firebase SDK" steps (already in pubspec.yaml).

---

## Step 4: Configure Android build files

### `android/build.gradle` — add to `dependencies`:
```groovy
classpath 'com.google.gms:google-services:4.4.2'
```

### `android/app/build.gradle` — at the bottom, add:
```groovy
apply plugin: 'com.google.gms.google-services'
```

And ensure `minSdkVersion` is at least **21**:
```groovy
minSdkVersion 21
```

---

## Step 5: Run FlutterFire CLI (generates `firebase_options.dart`)

```powershell
# Install globally (once)
dart pub global activate flutterfire_cli

# Inside the bani project folder
cd "d:\paid app\famillytree\bani"
flutterfire configure
```

- Choose your `bani-family-tree` project
- Select **Android** (and iOS if needed)
- This overwrites the placeholder `lib/firebase_options.dart` with real values ✅

---

## Step 6: Deploy Firestore Security Rules

```powershell
# Install Firebase CLI (once)
npm install -g firebase-tools
firebase login

cd "d:\paid app\famillytree"
firebase init firestore   # select your project, accept defaults
firebase deploy --only firestore:rules
```

---

## Step 7: Deploy Storage Security Rules

In Firebase Console → **Storage → Rules**, replace with:
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /families/{familyId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null
                   && request.resource.size < 5 * 1024 * 1024
                   && request.resource.contentType.matches('image/.*');
    }
  }
}
```

---

## Step 8: Run on Emulator

```powershell
cd "d:\paid app\famillytree\bani"
flutter run
```

> [!IMPORTANT]
> Make sure your Android emulator has **Google Play** support (required for Google Sign-In). Use a `Pixel` device image with **"Google Play"** label in AVD Manager.

---

## Step 9: Firestore Indexes (create when prompted)

When you first run tree queries, Flutter will print a URL like:
```
FirebaseException: The query requires an index. You can create it here: https://console.firebase.google.com/...
```
Click the link to create required composite indexes automatically.

---

## Checklist

- [ ] Firebase project created
- [ ] Authentication → Google enabled
- [ ] Firestore database created
- [ ] Firebase Storage enabled  
- [ ] `google-services.json` placed in `android/app/`
- [ ] Android `build.gradle` files updated (`minSdk 21`, google-services plugin)
- [ ] `flutterfire configure` completed (replaces placeholder `firebase_options.dart`)
- [ ] Firestore rules deployed
- [ ] Storage rules configured
- [ ] App runs on emulator with Google Sign-In working
