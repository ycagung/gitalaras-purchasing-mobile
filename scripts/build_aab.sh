#!/usr/bin/env bash

# ==============================================================================
# 📦 GS PRO — Build Android App Bundle (AAB) for Release (Google Play)
# ==============================================================================

set -e

# --- Color Formatting ---
BOLD='\033[1m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo -e "${CYAN}${BOLD}====================================================${NC}"
echo -e "${CYAN}${BOLD}📦 GS PRO — Build Release AAB (Google Play Store)${NC}"
echo -e "${CYAN}${BOLD}====================================================${NC}"

# 1. Check Flutter SDK (Prefer FVM if installed, fallback to global Flutter)
if command -v fvm &> /dev/null; then
  FLUTTER_CMD="fvm flutter"
  FLUTTER_VERSION=$(fvm flutter --version | head -n 1)
  echo -e "• Flutter Tool: ${GREEN}FVM (${FLUTTER_CMD})${NC}"
elif command -v flutter &> /dev/null; then
  FLUTTER_CMD="flutter"
  FLUTTER_VERSION=$(flutter --version | head -n 1)
  echo -e "• Flutter Tool: ${GREEN}Global (${FLUTTER_CMD})${NC}"
else
  echo -e "${RED}❌ Neither 'fvm' nor 'flutter' command was found in PATH.${NC}"
  echo -e "Silakan install Flutter atau jalankan melalui environment dengan Flutter terpasang."
  exit 1
fi

echo -e "• Flutter SDK:  ${GREEN}${FLUTTER_VERSION}${NC}"

# 2. Check android/key.properties
if [ ! -f "android/key.properties" ]; then
  echo -e "${RED}❌ android/key.properties not found!${NC}"
  echo -e "Silakan salin template: cp android/key.properties.example android/key.properties"
  echo -e "dan lengkapi dengan kredensial upload keystore yang valid."
  exit 1
fi

# 3. Resolve Keystore file from key.properties
STORE_FILE=$(grep "^storeFile=" android/key.properties | cut -d'=' -f2- | tr -d '\r' | tr -d ' ')
if [ -z "$STORE_FILE" ]; then
  echo -e "${RED}❌ 'storeFile' tidak ditemukan di android/key.properties!${NC}"
  exit 1
fi

STORE_BASENAME=$(basename "$STORE_FILE")
RESOLVED_KEYSTORE=""
if [ -f "android/app/$STORE_FILE" ]; then
  RESOLVED_KEYSTORE="android/app/$STORE_FILE"
elif [ -f "android/app/$STORE_BASENAME" ]; then
  RESOLVED_KEYSTORE="android/app/$STORE_BASENAME"
elif [ -f "android/app/${STORE_FILE}.jks" ]; then
  RESOLVED_KEYSTORE="android/app/${STORE_FILE}.jks"
elif [ -f "android/app/${STORE_BASENAME}.jks" ]; then
  RESOLVED_KEYSTORE="android/app/${STORE_BASENAME}.jks"
elif [ -f "android/$STORE_FILE" ]; then
  RESOLVED_KEYSTORE="android/$STORE_FILE"
elif [ -f "$STORE_FILE" ]; then
  RESOLVED_KEYSTORE="$STORE_FILE"
fi

if [ -z "$RESOLVED_KEYSTORE" ] || [ ! -f "$RESOLVED_KEYSTORE" ]; then
  echo -e "${RED}❌ Keystore file '$STORE_FILE' tidak ditemukan di android/app/ atau android/!${NC}"
  echo -e "Pastikan file keystore (.jks) diletakkan di dalam folder android/app/."
  exit 1
fi

KEY_ALIAS=$(grep "^keyAlias=" android/key.properties | cut -d'=' -f2- | tr -d '\r' | tr -d ' ')
echo -e "• Keystore:     ${GREEN}${RESOLVED_KEYSTORE} (OK)${NC}"
if [ -n "$KEY_ALIAS" ]; then
  echo -e "• Key Alias:    ${GREEN}${KEY_ALIAS}${NC}"
fi

# Optional: preflight validate keystore credentials via keytool if installed
if command -v keytool &> /dev/null; then
  STORE_PASS=$(grep "^storePassword=" android/key.properties | cut -d'=' -f2- | tr -d '\r' | tr -d ' ')
  if [ -n "$STORE_PASS" ] && [ -n "$KEY_ALIAS" ]; then
    if ! keytool -list -keystore "$RESOLVED_KEYSTORE" -alias "$KEY_ALIAS" -storepass "$STORE_PASS" &> /dev/null; then
      echo -e "${RED}❌ Validasi Keystore gagal! Password atau alias '$KEY_ALIAS' tidak cocok dengan $RESOLVED_KEYSTORE.${NC}"
      exit 1
    fi
  fi
fi


# 4. Extract Version from pubspec.yaml
APP_VERSION=$(grep "^version:" pubspec.yaml | sed 's/version: *//' | tr -d '\r' | tr -d ' ')
echo -e "• App Version:  ${BOLD}${APP_VERSION}${NC}"

# 5. Parse Command Line Arguments
ENV_NAME="production"
DO_CLEAN=true
DO_OBFUSCATE=false
SPLIT_DEBUG_INFO="build/app/outputs/symbols"
EXTRA_ARGS=()

for arg in "$@"; do
  case $arg in
    --env=*)
      ENV_NAME="${arg#*=}"
      ;;
    --staging)
      ENV_NAME="staging"
      ;;
    --production|--prod)
      ENV_NAME="production"
      ;;
    --no-clean)
      DO_CLEAN=false
      ;;
    --obfuscate)
      DO_OBFUSCATE=true
      ;;
    --split-debug-info=*)
      DO_OBFUSCATE=true
      SPLIT_DEBUG_INFO="${arg#*=}"
      ;;
    *)
      EXTRA_ARGS+=("$arg")
      ;;
  esac
done

echo -e "• Environment:  ${BOLD}${ENV_NAME}${NC} (--dart-define=ENV=${ENV_NAME})"
echo -e "• Target:       ${BOLD}lib/main.dart${NC}"

if [ "$DO_OBFUSCATE" = true ]; then
  mkdir -p "$SPLIT_DEBUG_INFO"
  EXTRA_ARGS+=("--obfuscate" "--split-debug-info=$SPLIT_DEBUG_INFO")
  echo -e "• Obfuscation:  ${GREEN}Enabled (Symbols: $SPLIT_DEBUG_INFO)${NC}"
else
  echo -e "• Obfuscation:  ${YELLOW}Disabled${NC} (Pass --obfuscate to enable Dart symbol obfuscation)"
fi

echo ""
START_TIME=$(date +%s)

# Step A: Clean (optional)
if [ "$DO_CLEAN" = true ]; then
  echo -e "${CYAN}${BOLD}🧹 Cleaning build cache...${NC}"
  $FLUTTER_CMD clean > /dev/null
fi

# Step B: Pub get
echo -e "${CYAN}${BOLD}📦 Resolving dependencies...${NC}"
$FLUTTER_CMD pub get

# Step C: Build AppBundle
echo ""
echo -e "${CYAN}${BOLD}🔨 Compiling Android App Bundle (AAB)...${NC}"
echo -e "Command: ${BOLD}$FLUTTER_CMD build appbundle --release -t lib/main.dart --dart-define=ENV=$ENV_NAME ${EXTRA_ARGS[*]}${NC}"
echo ""

$FLUTTER_CMD build appbundle --release -t lib/main.dart --dart-define=ENV="$ENV_NAME" "${EXTRA_ARGS[@]}"

AAB_OUTPUT="build/app/outputs/bundle/release/app-release.aab"

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
MINUTES=$((DURATION / 60))
SECONDS=$((DURATION % 60))

echo ""
echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}${BOLD}🎉 SUCCESS! GS PRO AAB Build Completed! (${MINUTES}m ${SECONDS}s)${NC}"
echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ -f "$AAB_OUTPUT" ]; then
  FILE_SIZE=$(du -h "$AAB_OUTPUT" | cut -f1)
  SHA256=$(shasum -a 256 "$AAB_OUTPUT" | cut -d' ' -f1)
  
  echo -e "• Output File:  ${BOLD}${AAB_OUTPUT}${NC}"
  echo -e "• File Size:    ${BOLD}${FILE_SIZE}${NC}"
  echo -e "• Version:      ${BOLD}${APP_VERSION}${NC}"
  echo -e "• SHA-256:      ${BOLD}${SHA256}${NC}"
  echo ""
  echo -e "${YELLOW}👉 File AAB ini siap di-upload ke Google Play Console!${NC}"
  echo -e "   Track: Internal testing / Closed testing / Production"
  if [ "$DO_OBFUSCATE" = true ]; then
    echo -e "   File debug symbols disimpan di: ${BOLD}${SPLIT_DEBUG_INFO}${NC}"
  fi
else
  echo -e "${RED}⚠️ File output $AAB_OUTPUT tidak ditemukan.${NC}"
fi
echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
