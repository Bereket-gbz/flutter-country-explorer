# 🌍 World Explorer — Flutter Country Explorer App

> Assignment 2 · Unit 4 · Mobile Application Development  
> Addis Ababa University · School of IT & Engineering

---

## 1. Student Information
| Field | Value |
|-------|-------|
| **Name** | [Bereket G/Egziabher] |
| **Student ID** | [ATE/7787/15 ] |

---

## 2. Track
**Track A — Country Explorer App**  
API: RestCountries (`https://restcountries.com/v3.1`) — free, no API key required.

---

## 3. App Description

World Explorer is a Flutter application that lets users browse every country on Earth, search by name, and view detailed information including flag, capital, population, currencies, languages, area, and timezones.

**Key features:**
- 🗺️ Scrollable list of all ~250 countries with flag images, region and population
- 🔍 Search by name with **400ms debounce** (Bonus: +5 marks)
- 📋 Full detail screen per country
- ⚡ Robust error handling for all 5 error types
- 🔄 Retry button on all error states
- Clean architecture: models / services / screens separated

---

## 4. Running the App Locally

### Prerequisites
- Flutter SDK ≥ 3.0.0 (`flutter --version`)
- An Android emulator or physical device, OR a Chrome browser for web

### Steps

```bash
# 1. Clone the repository
git clone https://github.com/<Bereket-gbz>/flutter-country-explorer.git
cd flutter-country-explorer

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run
```

> **No `.env` file needed** — Track A uses RestCountries which requires no API key.

---

## 5. API Endpoints Used

| Endpoint | Purpose | Screen |
|----------|---------|--------|
| `GET /all?fields=name,flags,flag,region,population,cca3` | Fetch all countries for list | Home |
| `GET /name/{name}` | Search countries by common name | Search |
| `GET /alpha/{code}` | Fetch single country by ISO alpha-3 code | Detail |

**Base URL:** `https://restcountries.com/v3.1`

All URIs are constructed with `Uri.https()` — no string concatenation.  
All requests have a **10-second timeout** and include `Content-Type: application/json` and `Accept: application/json` headers.

---

## 6. Known Limitations & Bugs

- **Image loading on slow connections:** Flag images are fetched from CDN URLs inside `RestCountries` responses. On very slow networks, images may take a moment to appear; a text/emoji fallback is shown until they load.
- **Subregion data:** Some countries return an empty subregion field from the API; the app shows "N/A" in those cases.
- **Search is name-only:** The search endpoint only supports searching by country *name*. Searching by capital or currency is not supported by this free API tier.
- **Population figures:** Population data from the API may be slightly outdated compared to real-world values.
- **No offline caching:** The app fetches fresh data on every launch. Caching (Bonus +5) was not implemented.
- **Pagination:** The home list loads all countries at once (~250 items). Load-more pagination (Bonus +5) was not implemented.

---

## Bonus Features Implemented

| Bonus | Marks | Status |
|-------|-------|--------|
| Search Debouncing (400ms Timer) | +5 | ✅ Implemented |
| Pagination | +5 | ❌ Not implemented |
| Local Caching with TTL | +5 | ❌ Not implemented |

---

## Project Structure

```
lib/
├── main.dart
├── models/
│   └── Country.dart
├── services/
│   ├── country_api_service.dart
│   └── api_exception.dart
└── screens/
    ├── home_screen.dart
    ├── search_screen.dart
    └── detail_screen.dart
```

---

## References & Citations

- [RestCountries API Documentation](https://restcountries.com)
- [Flutter `http` package](https://pub.dev/packages/http)
- [Flutter FutureBuilder documentation](https://api.flutter.dev/flutter/widgets/FutureBuilder-class.html)
- Course lecture slides — Unit 4, Networking in Flutter (Abel Tadesse)

---

*This project was developed individually in accordance with the Academic Integrity Policy of Addis Ababa University.*
