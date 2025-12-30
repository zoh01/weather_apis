# ⛅ Weather App

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![OpenWeather](https://img.shields.io/badge/OpenWeather-EB6E4B?style=for-the-badge&logo=weather&logoColor=white)

Beautiful weather forecasts at your fingertips.

[Features](#-features) • [Installation](#-installation) • [Usage](#-usage)

![Star](https://img.shields.io/github/stars/zoh01/weather_apis?style=social)
![Social](https://img.shields.io/github/forks/zoh01/weather_apis?style=social)

</div>

---

## 📖 Introduction
A sleek, modern weather application built with Flutter that provides real-time weather information and forecasts for any location worldwide. Get accurate weather updates with a beautiful, intuitive interface.

---

## ✨ Features
### 🌤️ Weather Information
- **Current Weather** - Real-time temperature, humidity, and conditions
- **5-Day Forecast** - Extended weather predictions
- **Hourly Updates** - Hour-by-hour weather breakdown
- **Multiple Locations** - Track weather in multiple cities
- **Search** - Find weather for any city worldwide

## 📊 Detailed Metrics
- **Temperature** - Current, feels-like, min/max
- **Wind** - Speed and direction
- **Humidity** - Moisture levels
- **Pressure** - Atmospheric pressure
- **Visibility** - Distance you can see
- **UV Index** - Sun exposure levels
- **Sunrise/Sunset** - Solar times

## 🎨 User Experience
- **Beautiful UI** - Clean, modern design
- **Weather Icons** - Animated weather conditions
- **Dark Mode** - Easy on the eyes
- **Auto Location** - GPS-based current location
- **Unit Toggle** - Switch between Celsius/Fahrenheit
- **Fast Loading** - Quick data retrieval

## 📱 Cross-Platform
- Android, iOS, Web, Windows, macOS, Linux

---

## 🛠️ Tech Stack
    # Core
    flutter: ^3.0.0
    dart: ^3.0.0
    
    # State Management
    provider: ^latest              # State management
    # or flutter_bloc: ^latest
    
    # Networking
    http: ^latest                  # HTTP requests
    dio: ^latest                   # Advanced HTTP client
    
    # Location
    geolocator: ^latest            # GPS location
    geocoding: ^latest             # Reverse geocoding
    
    # UI
    google_fonts: ^latest          # Custom fonts
    intl: ^latest                  # Date formatting
    lottie: ^latest               # Animations
    cached_network_image: ^latest  # Image caching
    
    # Storage
    shared_preferences: ^latest    # Local storage

---

## 🚀 Installation
### Prerequisites
- Flutter SDK (3.0+)
- OpenWeatherMap API Key [Get Free API Key](https://openweathermap.org/api)

### Setup
    # 1. Clone repository
    git clone https://github.com/zoh01/weather_apis.git
    cd weather_apis
    
    # 2. Install dependencies
    flutter pub get
    
    # 3. Configure API Key
    # Open api.env file and add your API key:
    echo "WEATHER_API_KEY=your_api_key_here" > api.env
    
    # 4. Run the app
    flutter run

### Get Your API Key
1. Visit [OpenWeatherMap](https://openweathermap.org/api)
2. Sign up for a free account
3. Navigate to **API Keys** section
4. Copy your **API key**
5. Paste it in api.env file

