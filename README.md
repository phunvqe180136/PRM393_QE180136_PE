# 🍳 RecipeBox — Personal Recipe Collection Mobile Application

[![Flutter](https://img.shields.io/badge/Flutter-v3.0+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-v3.0+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![Platform](https://img.shields.io/badge/Platform-Android%20(API%2021+)-green?logo=android&logoColor=white)](https://www.android.com)

> **PRM393 Practical Examination — Fall 2026**  
> **Course:** Mobile Programming (`PRM393`) | **Semester:** FALL 2026  
> **Application:** **RecipeBox** — Private personal recipe collection and culinary management application with real-time Firebase authentication & Cloud Firestore database.

---

## 📌 Executive Summary & Submission Credentials

This project strictly adheres to all requirements, exact visible screen texts, validation error messages, security rules, and structural guidelines outlined in the **PRM393 Practical Exam Specification (Fall 2026)**.

| Field | Detail |
| :--- | :--- |
| **Student Code** | **`QE180136`** |
| **Full Name** | **Nguyen Vinh Phu** |
| **Course** | PRM393 — Mobile Programming |
| **GitHub Repository** | [https://github.com/phunvqe180136/PRM393_QE180136_PE](https://github.com/phunvqe180136/PRM393_QE180136_PE) |
| **Direct APK Release Download** | [app-release.apk (v1.0)](https://github.com/phunvqe180136/PRM393_QE180136_PE/releases/download/v1.0/app-release.apk) |
| **Firebase Project ID** | `prm393-pe26` |
| **Test Account Email** | `grader.qe180136@example.com` |
| **Test Account Password** | `Ntyl0305` |

---

## 🚀 Key Features & Functional Specifications

### 1. 🔐 User Authentication & Session Control
- **Email & Password Authentication**: Powered by Firebase Authentication (`firebase_auth`).
- **Dynamic Auto-Routing**: Listens to `AuthService.authStateChanges`.
  - When logged out: User lands on the public `HomeScreen` with Login and Register buttons, title `RecipeBox`, description, and 3 feature cards ("Save your recipes", "Sort by cooking time", "Mark your favorites").
  - When logged in: Automatically redirects to `ListScreen` without flash or wrong navigation; shows a clean loading indicator while checking auth status.
- **Strict Form Validation**:
  - `Email`: Required (`Email is required`), validated against standard email format (`Please enter a valid email address`).
  - `Password`: Required (`Password is required`), minimum 6 characters on Register (`Password must be at least 6 characters`).
  - `Confirm password`: Required (`Confirm password is required`), must match password (`Passwords do not match`).
  - Success Feedback: Register displays `Registration successful`.
- **Back-button Prevention**: Disables back navigation on `ListScreen` (`PopScope(canPop: false)`), ensuring users cannot return to the Login or Register forms.
- **Header & Logout**: Shows the logged-in user's email and a working `Logout` button in the AppBar.

### 2. 🍲 Recipe Management (CRUD Operations)
- **Ordered Recipe Catalog**: All recipes belonging to the logged-in user are automatically ordered by **cook time (shortest first)**; equal cook times ordered by name (case-insensitive).
- **Recipe List Item**: Shows name, category badge (`Breakfast`, `Lunch`, `Dinner`, `Dessert`), difficulty badge (`Easy`, `Medium`, `Hard`), cooking time in minutes (e.g. `25 min`), favorite toggle star, and tap to view details.
- **Add Recipe Modal Sheet**:
  - `name`: Required, max 80 chars (`Name is required` / `Name must be at most 80 characters`)
  - `category`: Dropdown with `Choose category` (`Please choose a category`)
  - `difficulty`: Dropdown with `Choose difficulty` (`Please choose a difficulty`)
  - `cookTime`: 1 to 600 min (`Cook time is required` / `Cook time must be a whole number from 1 to 600`)
  - `servings`: Optional, 1 to 20 (`Servings must be a whole number from 1 to 20`)
  - `notes`: Optional, max 300 chars (`Notes must be at most 300 characters`)
- **Detail Screen**: Full view mode, inline edit mode with identical validations, and delete with confirmation dialog.

### 3. 🔍 Dynamic Real-time Filters & Live Summary
- **Multi-criteria Filter & Search**: Category filter (`All`, `Breakfast`, `Lunch`, `Dinner`, `Dessert`), Difficulty filter (`All`, `Easy`, `Medium`, `Hard`), Favorites only toggle, search query box matching name and notes (case-insensitive, trimmed). `Clear` button resets all filters.
- **Dynamic Summary**:
  - `Recipes: N`
  - `Favorites: N`
  - `Total time: N min`
  - Category breakdown with highest count first (equal counts: Breakfast, Lunch, Dinner, Dessert).

---

## 🔒 Firebase Cloud Firestore Security Rules

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    match /recipes/{recipeId} {
      allow read, delete: if request.auth != null && resource.data.userId == request.auth.uid;
      allow create: if request.auth != null
        && request.resource.data.userId == request.auth.uid
        && isValidRecipe(request.resource.data);
      allow update: if request.auth != null
        && resource.data.userId == request.auth.uid
        && request.resource.data.userId == request.auth.uid
        && isValidRecipe(request.resource.data);
    }

    function isValidRecipe(data) {
      return data.name is string
          && data.name.trim().size() > 0
          && data.name.trim().size() <= 80
          && data.category in ['Breakfast', 'Lunch', 'Dinner', 'Dessert']
          && data.difficulty in ['Easy', 'Medium', 'Hard']
          && data.cookTime is int
          && data.cookTime >= 1
          && data.cookTime <= 600
          && (!('servings' in data) || data.servings == null || (data.servings is int && data.servings >= 1 && data.servings <= 20))
          && (!('favorite' in data) || data.favorite is bool)
          && (!('notes' in data) || data.notes == null || (data.notes is string && data.notes.size() <= 300));
    }
  }
}
```
