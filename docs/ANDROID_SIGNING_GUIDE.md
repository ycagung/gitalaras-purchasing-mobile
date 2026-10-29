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
keyAlias=upload
storeFile=gspro-upload-2026.jks
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
                val storeFilePath = keystoreProperties["storeFile"] as String?
                storeFile = if (storeFilePath != null) {
                    val fileName = java.io.File(storeFilePath).name
                    val localFile = file(storeFilePath)
                    val localByName = file(fileName)
                    val localJks = file("$storeFilePath.jks")
                    val rootFile = rootProject.file(storeFilePath)
                    val rootByName = rootProject.file("app/$fileName")
                    val rootJks = rootProject.file("$storeFilePath.jks")
                    when {
                        localFile.exists() -> localFile
                        localByName.exists() -> localByName
                        localJks.exists() -> localJks
                        rootFile.exists() -> rootFile
                        rootByName.exists() -> rootByName
                        rootJks.exists() -> rootJks
                        else -> localFile
                    }
                } else {
                    null
                }
                storePassword = keystoreProperties["storePassword"] as String?
            }
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}
```

Aturan ProGuard/R8 untuk proteksi bytecode native dan plugin terdaftar di [`android/app/proguard-rules.pro`](../android/app/proguard-rules.pro).

---

## 4. Build Release Android App Bundle (.aab)

### Cara Cepat (Menggunakan Skrip Otomatisasi)

Gunakan skrip yang telah disiapkan di root project:

```bash
# Build Production standar
./scripts/build_aab.sh

# Build Production dengan Obfuscation kode Dart (Direkomendasikan)
./scripts/build_aab.sh --obfuscate

# Build Staging
./scripts/build_aab.sh --staging
```

### Cara Manual (Flutter CLI)

> [!IMPORTANT]
> **Wajib gunakan `--no-tree-shake-icons`.** Icon tree shaking Flutter merusak data variasi (fill/weight) pada font variabel Material Symbols, sehingga ikon yang memakai `fill:` atau `weight:` tampil salah/hilang. Skrip `./scripts/build_aab.sh` sudah otomatis menyertakan flag ini.

```bash
# Staging
fvm flutter build appbundle --release --no-tree-shake-icons --dart-define=ENV=staging

# Production
fvm flutter build appbundle --release --no-tree-shake-icons --dart-define=ENV=production

# Production dengan Obfuscation
fvm flutter build appbundle --release --no-tree-shake-icons --dart-define=ENV=production \
  --obfuscate --split-debug-info=build/app/outputs/symbols
```

### Lokasi Output File:
```
build/app/outputs/bundle/release/app-release.aab
```

File `app-release.aab` inilah yang diunggah ke Google Play Console pada track **Internal Testing**, **Closed Testing**, atau **Production**.
Jika mengaktifkan `--obfuscate`, berkas simbol debug disimpan di folder `build/app/outputs/symbols` untuk memetakan stack trace saat debugging.
