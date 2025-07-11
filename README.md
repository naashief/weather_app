# weather_app
# Aplikasi Cuaca Sederhana Flutter

Aplikasi Flutter untuk menampilkan informasi cuaca saat ini menggunakan OpenWeatherMap API.

## Cara Menjalankan Proyek

1.  **Prasyarat:**
    *   Pastikan Anda telah menginstal [Flutter SDK](https://flutter.dev/docs/get-started/install).
    *   Anda memerlukan **API Key** dari [OpenWeatherMap](https://openweathermap.org/appid).

2.  **Konfigurasi API Key:**
    *   Buka file kode sumber berikut:
        *   `lib/pages/search_field.dart`
        *   `lib/pages/result.dart`
    *   Di dalam file-file tersebut, cari URL yang digunakan untuk request API (biasanya mengandung `api.openweathermap.org`).
    *   Ganti placeholder `APPID=YOUR_API_KEY` (atau yang serupa) dengan API Key OpenWeatherMap Anda yang valid.
3.  **Install Dependencies:**
    Buka terminal di direktori root proyek dan jalankan (flutter run)
    
