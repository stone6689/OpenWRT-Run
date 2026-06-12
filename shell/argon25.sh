#!/bin/bash

set -euo pipefail

declare -A PLATFORMS=(
  ["x86_64"]="https://mirrors.pku.edu.cn/immortalwrt/releases/25.12.0/packages/x86_64"
  ["aarch64_generic"]="https://mirrors.pku.edu.cn/immortalwrt/releases/25.12.0/packages/aarch64_generic"
  ["aarch64_cortex-a53"]="https://mirrors.pku.edu.cn/immortalwrt/releases/25.12.0/packages/aarch64_cortex-a53"
)

declare -A PACKAGE_SOURCES=(
  ["luci-theme-argon"]="luci"
  ["luci-app-argon-config"]="luci"
  ["luci-i18n-argon-config"]="luci"
)

OUT_DIR="$(pwd)"
TMP_DIR="$(mktemp -d)"

cleanup() {
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT

for platform in "${!PLATFORMS[@]}"; do

    echo
    echo "📦 Platform: $platform"

    SAVE_DIR="${OUT_DIR}/${platform}"
    mkdir -p "$SAVE_DIR"

    declare -A CACHE=()

    for pkg in "${!PACKAGE_SOURCES[@]}"; do

        feed="${PACKAGE_SOURCES[$pkg]}"
        URL="${PLATFORMS[$platform]}/${feed}"

        if [[ ! -f "${TMP_DIR}/${platform}_${feed}.html" ]]; then
            echo "🌐 Fetching ${feed} index..."
            if ! curl -fsSL "${URL}/" -o "${TMP_DIR}/${platform}_${feed}.html"; then
                echo "❌ Failed: ${URL}"
                continue
            fi
        fi

        HTML="${TMP_DIR}/${platform}_${feed}.html"

        FILE=$(
            grep -oE "${pkg}_[^\"]+\.apk" "$HTML" \
            | sort -V \
            | tail -n1
        )

        if [[ -z "$FILE" ]]; then
            echo "❌ ${pkg} not found"
            continue
        fi

        echo "⬇️  ${FILE}"

        if curl -fL \
            -o "${SAVE_DIR}/${FILE}" \
            "${URL}/${FILE}"; then
            echo "   ✔ OK"
        else
            echo "   ❌ Download failed"
        fi

    done

done

echo
echo "✅ All done."
