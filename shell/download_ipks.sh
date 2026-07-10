#!/bin/bash
set -euo pipefail

echo "=== Starting download ==="

mkdir -p all x86 arm64 arm64-a53

# 下载函数（失败时只警告，不立即退出）
download() {
  local url=$1
  local dir=$2
  if [ -z "$url" ]; then
    echo "⚠️  URL is empty, skipping: $dir"
    return 0
  fi
  echo "Downloading to $dir/: $url"
  if ! wget -q "$url" -P "$dir/"; then
    echo "❌ Failed to download: $url"
    # 不 exit，继续尝试其他文件
  fi
}

# 下载文件
download "$LUCI_MAIN_URL" "all"
download "$X86_DAED_URL" "x86"
download "$X86_DAE_URL" "x86"
download "$X86_VMLINUX_BTF_URL" "x86"

download "$ARM_GENERIC_DAED_URL" "arm64"
download "$ARM_GENERIC_DAE_URL" "arm64"
download "$ARM_GENERIC_VMLINUX_BTF_URL" "arm64"
cp all/*.ipk arm64/ 2>/dev/null || echo "No luci ipk to copy to arm64"

download "$ARM_A53_DAED_URL" "arm64-a53"
download "$ARM_A53_DAE_URL" "arm64-a53"
download "$ARM_A53_VMLINUX_BTF_URL" "arm64-a53"
cp all/*.ipk arm64-a53/ 2>/dev/null || echo "No luci ipk to copy to arm64-a53"

# 版本提取
fname=$(basename "$LUCI_MAIN_URL")
VERSION=$(echo "$fname" | grep -oP '\d{4}\.\d{2}\.\d{2}' | head -n1)

if [ -z "$VERSION" ]; then
  VERSION=$(date +'%Y.%m.%d')
  echo "⚠️  Could not extract version, using today's date: $VERSION"
fi

echo "VERSION=$VERSION" >> $GITHUB_ENV
echo "✅ Extracted VERSION = $VERSION"

echo "=== Download step finished ==="
ls -lh */*.ipk 2>/dev/null || echo "No ipk files found"
