# Flutter Firebase – Tugas Praktikum

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-Framework-blue?logo=flutter" />
  <img src="https://img.shields.io/badge/Firebase-Backend-orange?logo=firebase" />
  <img src="https://img.shields.io/badge/Platform-Android-green?logo=android" />
</p>

## Deskripsi Project

Project ini merupakan implementasi Firebase pada aplikasi Flutter, meliputi Firebase Cloud Messaging (FCM), pengiriman notifikasi, pengelolaan topic, notifikasi bergambar, dan penyimpanan token perangkat menggunakan Cloud Firestore.

---

## 1. Notifikasi Berdasarkan Kategori Promo

<marquee behavior="alternate" scrollamount="5">🛒 TUGAS 1 — PUSH NOTIFICATION KATEGORI PROMO 🛒</marquee>

**Deskripsi:**

Mengimplementasikan Firebase Cloud Messaging untuk menerima notifikasi dengan kategori tertentu.

**Implementasi:**
- Mengirim notifikasi menggunakan FCM HTTP v1.
- Mengirim data tambahan melalui payload `data`.
- Mengidentifikasi kategori notifikasi menggunakan key `kategori`.
- Mengubah ikon notifikasi menjadi `Icons.shopping_cart` apabila kategori bernilai `promo`.

**Contoh data:**

```json
{
  "kategori": "promo",
  "id_pesan": "002",
  "isi_lengkap": "Diskon spesial untuk mahasiswa!"
}
```

---

## 2. Subscribe dan Unsubscribe Topic

<marquee behavior="alternate" scrollamount="5">📢 TUGAS 2 — SUBSCRIBE & UNSUBSCRIBE TOPIC KELAS 📢</marquee>

**Deskripsi:**

Mengimplementasikan fitur berlangganan dan berhenti berlangganan notifikasi berdasarkan topic menggunakan Firebase Cloud Messaging.

**Implementasi:**
- Membuat tombol Subscribe pada Dashboard.
- Membuat tombol Unsubscribe pada Dashboard.
- Menggunakan topic `kelas`.
- Mengirim notifikasi kepada seluruh perangkat yang berlangganan topic `kelas`.
- Menguji bahwa perangkat yang sudah unsubscribe tidak lagi menerima pesan topic tersebut.

**Nama Topic:**

```text
kelas
```

---

## 3. Notifikasi dengan Gambar

<marquee behavior="alternate" scrollamount="5">🖼️ TUGAS 3 — FIREBASE CLOUD MESSAGING IMAGE NOTIFICATION 🖼️</marquee>

**Deskripsi:**

Mengimplementasikan notifikasi Firebase Cloud Messaging yang menyertakan gambar.

**Implementasi:**
- Menambahkan field `image` pada bagian `message.notification`.
- Menggunakan URL gambar sebagai sumber gambar notifikasi.
- Menguji tampilan notifikasi ketika aplikasi berada di background.

**URL Gambar:**

```text
https://picsum.photos/600/300
```

---

## 4. Menyimpan FCM Token ke Cloud Firestore

<marquee behavior="alternate" scrollamount="5">🔥 TUGAS 4 — FIRESTORE USER TOKEN MANAGEMENT 🔥</marquee>

**Deskripsi:**

Mengimplementasikan penyimpanan FCM Token setiap pengguna ke Cloud Firestore setelah berhasil login.

**Implementasi:**
- Mengambil FCM Token dari perangkat menggunakan Firebase Messaging.
- Mengidentifikasi pengguna menggunakan Firebase Authentication UID.
- Menyimpan token ke Cloud Firestore.
- Memperbarui token ketika terjadi perubahan token perangkat.
- Menggunakan UID sebagai document ID pengguna.

**Struktur Firestore:**

```text
users/
 └── {uid}/
      ├── email
      ├── fcmToken
      └── updatedAt
```

---

## Teknologi yang Digunakan

| Teknologi | Kegunaan |
|---|---|
| Flutter | Framework aplikasi |
| Dart | Bahasa pemrograman |
| Firebase Authentication | Autentikasi pengguna |
| Firebase Cloud Messaging | Push notification |
| Cloud Firestore | Penyimpanan data pengguna |
| Postman | Pengujian FCM HTTP v1 |

---

## Instalasi Project

Clone repository:

```bash
git clone URL_REPOSITORY
```

Masuk ke folder project:

```bash
cd login_firebase
```

Instal dependensi:

```bash
flutter pub get
```

Jalankan aplikasi:

```bash
flutter run
```

---

## Author

**Fahry Achmad Wibowo**

Project Praktikum Aplikasi Mobile – Semester 5
