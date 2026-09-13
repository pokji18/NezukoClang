#!/bin/bash
# NezukoClang env setup — source this file:
#   source /path/to/NezukoClang/setup-env.sh
TC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# patch agar clang --version tampil link llvm seperti clang pada umumnya
if [ -f "$TC_DIR/bin/clang-23" ] && ! "$TC_DIR/bin/clang" --version 2>&1 | grep -q "llvm-project"; then
  [ -f "$TC_DIR/bin/clang-23.real" ] || cp "$TC_DIR/bin/clang-23" "$TC_DIR/bin/clang-23.real"
  cat > "$TC_DIR/bin/clang-23" << 'EOSWRAP'
#!/bin/bash
DIR="$(dirname "$0")"
REAL="$DIR/clang-23.real"
[ -f "$REAL" ] || REAL="$DIR/clang.real"
if [[ "$*" == *"--version"* ]]; then
  "$REAL" --version 2>&1 | sed 's/$/ (https:\/\/github.com\/llvm\/llvm-project)/'
  exit $?
fi
exec "$REAL" "$@"
EOSWRAP
  chmod +x "$TC_DIR/bin/clang-23"
fi
export PATH="$TC_DIR/bin:$TC_DIR/aarch64-linux-android-4.9/bin:$TC_DIR/arm-linux-androideabi-4.9/bin:$PATH"
export CLANG_DIR="$TC_DIR"
export GCC64_DIR="$TC_DIR/aarch64-linux-android-4.9"
export GCC32_DIR="$TC_DIR/arm-linux-androideabi-4.9"
echo "NezukoClang ready: $(clang --version | head -n 1)"
echo "CLANG_DIR=$CLANG_DIR"
echo "GCC64_DIR=$GCC64_DIR"
echo "GCC32_DIR=$GCC32_DIR"
echo ""
echo "Kernel build example (arm64):"
echo "  make O=out ARCH=arm64 miatoll_defconfig"
echo "  make -j\$(nproc) O=out ARCH=arm64 \\"
echo "    CC=clang LD=ld.lld AR=llvm-ar NM=llvm-nm STRIP=llvm-strip \\"
echo "    OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump READELF=llvm-readelf \\"
echo "    LLVM=1 LLVM_IAS=1 \\"
echo "    CROSS_COMPILE=\"\$CLANG_DIR/bin/aarch64-linux-gnu-\" \\"
echo "    CROSS_COMPILE_ARM32=\"\$GCC32_DIR/bin/arm-linux-androideabi-\" Image.gz"
