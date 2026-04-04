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
     ```
     ```
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

# 👋🏻 Hi, I'm Noor Mustafa

A passionate and results-driven *Flutter Developer* from *Bahawalpur, Pakistan, specializing in building elegant, scalable, and high-performance cross-platform mobile applications using **Flutter* and *Dart*.

With a strong understanding of *UI/UX principles, **state management, and **API integration*, I aim to deliver apps that are not only functional but also user-centric and visually compelling. My development approach emphasizes clean code, reusability, and performance.

---

## 🚀 What I Do

- 🧑🏻💻 *Flutter App Development* – I build cross-platform apps for Android, iOS, and the web using Flutter.
- 🔗 *API Integration* – I connect apps to powerful RESTful APIs and third-party services.
- 🎨 *UI/UX Design* – I craft responsive and animated interfaces that elevate the user experience.
- 🔐 *Authentication & Firebase* – I implement secure login systems and integrate Firebase services.
- ⚙ *State Management* – I use Provider, setState, and Riverpod (in-progress) for scalable app architecture.
- 🧠 *Clean Architecture* – I follow MVVM and MVC patterns for maintainable code.

---


## 🌟 Projects I'm Proud Of

- 🌤 **[Live Weather Check App](https://github.com/NoorMustafa4556/Live-Weather-Check-App)** – Real-time weather forecast using OpenWeatherMap API  
- 🤖 **[AI Chatbot (Gemini)](https://github.com/NoorMustafa4556/Ai-ChatBot)** – Conversational AI chatbot powered by Google’s Gemini  

- 🍔 **[Recipe App](https://github.com/NoorMustafa4556/Recipe-App)** – Discover recipes with images, categories, and step-by-step instructions  

- 📚 **[Palindrome Checker](https://github.com/NoorMustafa4556/Palindrome-Checker-App)** – A Theory of Automata-based project to identify palindromic strings  

> 🎯 Check out all my repositories on [github.com/NoorMustafa4556](https://github.com/NoorMustafa4556?tab=repositories)

---

## 🛠 Tech Stack & Tools

| Area                | Tools/Technologies |
|---------------------|--------------------|
| *Languages*       | Dart, JavaScript, Python (basic) |
| *Mobile Framework*| Flutter            |
| *Backend/Cloud*   | Firebase (Auth, Realtime DB, Storage), Django, Flask |
| *Frontend (Web)*  | React.js (basic), HTML, CSS, Bootstrap |
| *State Management*| Provider, setState, Riverpod (learning) |
| *API & Storage*   | REST APIs, HTTP, Shared Preferences, SQLite |
| *Design*          | Material, Cupertino, Lottie Animations, Gradient UI |
| *Version Control* | Git, GitHub        |
| *Tools*           | Android Studio, VS Code, Postman, Figma (basic) |

---

## 🧰 Tech Toolbox

<p align="left">
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white"/>
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white"/>
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black"/>
  <img src="https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white"/>
  <img src="https://img.shields.io/badge/Django-092E20?style=for-the-badge&logo=django&logoColor=white"/>
  <img src="https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB"/>
  <img src="https://img.shields.io/badge/Postman-FF6C37?style=for-the-badge&logo=postman&logoColor=white"/>
  <img src="https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white"/>
</p>

---

## 📈 Current Focus

- 💡 Enhancing Flutter animations and transitions
- 🤖 Implementing AI-based logic with Google Gemini API
- 📲 Building portfolio-level applications using full-stack Django & Flutter

---

## 📫 Let's Connect!

<p align="left">
  <a href="https://x.com/NoorMustafa4556" target="blank">
    <img src="https://raw.githubusercontent.com/rahuldkjain/github-profile-readme-generator/master/src/images/icons/Social/twitter.svg" alt="X / Twitter" height="30" width="40" />
  </a>
  <a href="https://www.linkedin.com/in/noormustafa4556/" target="blank">
    <img src="https://raw.githubusercontent.com/rahuldkjain/github-profile-readme-generator/master/src/images/icons/Social/linked-in-alt.svg" alt="LinkedIn" height="30" width="40" />
  </a>
  <a href="https://www.facebook.com/NoorMustafa4556" target="blank">
    <img src="https://raw.githubusercontent.com/rahuldkjain/github-profile-readme-generator/master/src/images/icons/Social/facebook.svg" alt="Facebook" height="30" width="40" />
  </a>
  <a href="https://instagram.com/noormustafa4556" target="blank">
    <img src="https://raw.githubusercontent.com/rahuldkjain/github-profile-readme-generator/master/src/images/icons/Social/instagram.svg" alt="Instagram" height="30" width="40" />
  </a>
  <a href="https://wa.me/923087655076" target="blank">
    <img src="https://raw.githubusercontent.com/rahuldkjain/github-profile-readme-generator/master/src/images/icons/Social/whatsapp.svg" alt="WhatsApp" height="30" width="40" />
  </a>
  <a href="https://www.tiktok.com/@noormustafa4556" target="blank">
    <img src="https://cdn-icons-png.flaticon.com/512/3046/3046122.png" alt="TikTok" height="30" width="30" />
  </a>
</p>

- 📍 *Location:* Bahawalpur, Punjab, Pakistan

---

> “Learning never stops. Every app I build makes me a better developer — one widget at a time.”

---

## 📜 License
This project is for educational and professional demonstration purposes.
