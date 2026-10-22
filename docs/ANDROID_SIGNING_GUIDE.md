# Android Release Signing & Play Store Guide

Panduan lengkap konfigurasi Upload Keystore, Signing, dan Build Android App Bundle (`.aab`) untuk rilis aplikasi **GS PRO** ke Google Play Store.

---

## 1. Pembuatan Upload Keystore

Keystore dibuat menggunakan perintah `keytool` melalui terminal di root project:

```bash
keytool -genkey -v -keystore android/app/gspro-keystore.jks \
        -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 \
        -alias gspro
```

### Rincian Interaktif Input:

| Prompt | Nilai Input | Keterangan |
| :--- | :--- | :--- |
| `Enter keystore password:` | `[Password Keystore Anda]` | Password utama keystore |
| `Re-enter new password:` | `[Password Keystore Anda]` | Konfirmasi password |
| `What is your first and last name?` | `Visea Developer` | CN (Common Name) |
| `What is the name of your organizational unit?` | `Mobile Development` | OU (Organizational Unit) |
| `What is the name of your organization?` | `Visea Kreasi Teknologi` | O (Organization) |
| `What is the name of your City or Locality?` | `Jakarta` | L (Locality) |
| `What is the name of your State or Province?` | `Jakarta` | ST (State/Province) |
| `What is the two-letter country code for this unit?` | `ID` | C (Country Code) |
| `Is CN=..., OU=..., O=... correct? [no]:` | **`y`** atau **`yes`** | *Wajib ketik `y`/`yes` agar terkonfirmasi* |
| `Enter key password for <gspro> (RETURN if same):` | **`[ENTER]`** | Tekan enter untuk menyamakan password |

File keystore akan tersimpan di: `android/app/gspro-keystore.jks`.

> [!WARNING]
> **PENTING: Backup Keystore!**
> Simpan file `gspro-keystore.jks` dan kredensial password di tempat aman (password manager / cloud backup terenkripsi). Keystore ini diperlukan untuk menandatangani semua update aplikasi di Google Play Store.

---

## 2. Konfigurasi `android/key.properties`

Konfigurasi kredensial disimpan pada file `android/key.properties` (file ini otomatis diabaikan oleh Git via `android/.gitignore`):

```properties
storePassword=[Password Keystore]
keyPassword=[Password Keystore]
keyAlias=gspro
storeFile=gspro-keystore.jks
```

---

## 3. Konfigurasi Build Gradle

Konfigurasi pembacaan signing telah diintegrasikan pada [`android/app/build.gradle.kts`](../android/app/build.gradle.kts):

```kotlin
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String?
                keyPassword = keystoreProperties["keyPassword"] as String?
                storeFile = keystoreProperties["storeFile"]?.let { file(it) }
                storePassword = keystoreProperties["storePassword"] as String?
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}
```

---

## 4. Build Release Android App Bundle (.aab)

Untuk membuat bundle yang siap diunggah ke Google Play Console:

> **Wajib gunakan `--no-tree-shake-icons`.** Icon tree shaking Flutter merusak data variasi (fill/weight) pada font variabel Material Symbols, sehingga ikon yang memakai `fill:` atau `weight:` tampil salah.

### Staging
```bash
fvm flutter build appbundle --release --no-tree-shake-icons --dart-define=ENV=staging
```

### Production
```bash
fvm flutter build appbundle --release --no-tree-shake-icons --dart-define=ENV=production
```

### Lokasi Output File:
```
build/app/outputs/bundle/release/app-release.aab
```

File `app-release.aab` inilah yang diunggah ke Google Play Console pada track **Internal Testing**, **Closed Testing**, atau **Production**.
