# AgriConnect - Agriculture Equipment Booking App 🚜🌾

AgriConnect is a comprehensive Flutter-based platform designed to bridge the gap between farmers and equipment owners. It allows owners to list their machinery (Tractors, Harvesters, etc.) and farmers to browse, search, and book equipment based on their location and specific needs.

## 🚀 Vision
Empowering the agricultural community by providing a digital marketplace for farming equipment, ensuring efficiency, transparency, and ease of access to essential machinery.

---



## ✨ Features

### 👨‍🌾 For Farmers
- **Smart Category Browsing**: Quickly find equipment like Tractors, Harvesters, Pumps, and Sprayers.
- **Location-Based Search**: Search for equipment available in your specific city or area.
- **Detailed Listings**: View owner information, pricing, and equipment specifications before booking.
- **Advanced Booking System**: 
    - Interactive Date Picker with real-time availability.
    - Protection against double-booking (booked dates are automatically disabled).
    - Status tracking for all requests (Pending, Accepted, Rejected).
- **Direct Communication**: One-tap phone or email contact for owners once a request is accepted.

### 🚜 For Equipment Owners
- **Online/Offline Toggle**: Manage your availability status with a single switch.
- **Request Management**: View incoming requests with full farmer details, including location, duration, and personalized messages.
- **Equipment Management**: Add, edit, or delete machinery listings. Includes a dynamic image gallery for each category.
- **Interactive Dashboard**: Clickable request cards to view farmer profiles and contact them directly.

### 🛠 Shared Features
- **Dual-Role Authentication**: Flexible login and signup system for both Farmers and Owners.
- **Profile Management**: Update contact information, city, and personal details.
- **Security**: Secure password change functionality and session management via Firebase.
- **Custom Navigation**: Intuitive side drawer for seamless app navigation.

---

## Why AgriConnect?
For many small to medium-scale farmers, purchasing heavy farm machinery is financially out of reach. AgriConnect solves this by creating a localized sharing economy. Equipment owners can monetize their idle machinery, and farmers can rent what they need, exactly when they need it. It's a win-win for the agricultural ecosystem!

---

## 📸 App Gallery (Screenshots)

*Note: The following gallery contains sequential screenshots documenting the complete A-Z app flow.*

<p align="center">
  <img src="assets/images/1.png" width="32%" />
  <img src="assets/images/2.png" width="32%" />
  <img src="assets/images/3.png" width="32%" />
</p>
<p align="center">
  <img src="assets/images/4.png" width="32%" />
  <img src="assets/images/5.png" width="32%" />
  <img src="assets/images/6.png" width="32%" />
</p>
<p align="center">
  <img src="assets/images/7.png" width="32%" />
  <img src="assets/images/8.png" width="32%" />
  <img src="assets/images/9.png" width="32%" />
</p>
<p align="center">
  <img src="assets/images/10.png" width="32%" />
  <img src="assets/images/11.png" width="32%" />
  <img src="assets/images/12.png" width="32%" />
</p>
<p align="center">
  <img src="assets/images/13.png" width="32%" />
  <img src="assets/images/14.png" width="32%" />
  <img src="assets/images/15.png" width="32%" />
</p>
<p align="center">
  <img src="assets/images/16.png" width="32%" />
  <img src="assets/images/17.png" width="32%" />
  <img src="assets/images/18.png" width="32%" />
</p>
<p align="center">
  <img src="assets/images/19.png" width="32%" />
  <img src="assets/images/20.png" width="32%" />
  <img src="assets/images/21.png" width="32%" />
</p>
<p align="center">
  <img src="assets/images/22.png" width="32%" />
  <img src="assets/images/23.png" width="32%" />
  <img src="assets/images/24.png" width="32%" />
</p>
<p align="center">
  <img src="assets/images/25.png" width="32%" />
  <img src="assets/images/26.png" width="32%" />
  <img src="assets/images/27.png" width="32%" />
</p>
<p align="center">
  <img src="assets/images/28.png" width="32%" />
  <img src="assets/images/29.png" width="32%" />
  <img src="assets/images/30.png" width="32%" />
</p>
<p align="center">
  <img src="assets/images/31.png" width="32%" />
  <img src="assets/images/32.png" width="32%" />
  <img src="assets/images/33.png" width="32%" />
</p>
<p align="center">
  <img src="assets/images/34.png" width="32%" />
  <img src="assets/images/35.png" width="32%" />
  <img src="assets/images/36.png" width="32%" />
</p>
<p align="center">
  <img src="assets/images/37.png" width="32%" />
  <img src="assets/images/38.png" width="32%" />
  <img src="assets/images/39.png" width="32%" />
</p>
<p align="center">
  <img src="assets/images/40.png" width="32%" />
  <img src="assets/images/41.png" width="32%" />
  <img src="assets/images/42.png" width="32%" />
</p>

---

## 🛠 Tech Stack

- **Frontend**: Flutter (Dart)
- **State Management**: Provider
- **Backend & Database**: Firebase (Auth, Cloud Firestore)
- **Utilities**: 
    - `intl`: For date formatting.
    - `url_launcher`: For phone and email integration.
- **Architecture**: Centralized Asset Management and Standardized Data Sets for global consistency.

---

## 📂 Project Structure

```text
lib/
├── Auth/               # Authentication Logic & Services
├── Providers/          # State Management (AuthProvider)
├── Screens/
│   ├── Auth/           # Login, Signup, Splash
│   ├── Farmer/         # Farmer specific UI (Search, Booking, History)
│   ├── Owner/          # Owner specific UI (Dashboard, Add Equipment)
│   └── Shared/         # Common UI (Profile, Drawer, Password)
└── utils/              # Colors, Standardized AssetManager, Constants
```

---

## ⚙️ Setup Instructions

### Prerequisites
- Flutter SDK (v3.0.0+)
- Firebase Account & Project

### Installation
1.  **Clone the Repository**:
    ```bash
    git clone https://github.com/NoorMustafa4556/Agri-Connect-App-Flutter.git
    cd agri_connect_app
    ```
2.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Configure Firebase**:
    - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) to the respective directories.
    - Ensure `firebase_options.dart` is updated.
4.  **Run the App**:
    ```bash
    flutter run
    ```

---

## 👨‍💻 Developer
Developed with ❤️ by **Noor Mustafa**.

---

## 📜 License
This project is for educational and professional demonstration purposes.
