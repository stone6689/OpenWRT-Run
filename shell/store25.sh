#!/bin/bash

set -e

BASE_URL="https://istore.istoreos.com/repo-apk/all/store/"
TARGET_DIR="store"

mkdir -p "$TARGET_DIR"

# 指定要下载的包名前缀
packages=(
    "luci-app-store"
    "luci-lib-taskd"
    "luci-lib-xterm"
    "taskd"
)

echo "[+] Fetching index page..."
page_content=$(curl -fsSL "$BASE_URL")

echo "[+] Parsing .apk links..."
all_apks=$(echo "$page_content" | grep -oE 'href="[^"]+\.apk"' | cut -d'"' -f2)

for prefix in "${packages[@]}"; do
    match=$(echo "$all_apks" | grep "^${prefix}_" | head -n1)

    if [ -n "$match" ]; then
        echo "[+] Downloading $match ..."
        curl -fL -o "$TARGET_DIR/$match" "${BASE_URL}${match}"
    else
        echo "[!] Warning: No .apk found for $prefix"
    fi
done

echo "[✓] Done. Saved in: $TARGET_DIR"
