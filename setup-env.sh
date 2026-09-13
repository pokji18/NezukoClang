#!/bin/bash
# NezukoClang env setup — source this file:
#   source /path/to/NezukoClang/setup-env.sh
TC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# auto-fetch GCC 64/32 jika belum ada (biar full saat clone)
if [ ! -d "$TC_DIR/aarch64-linux-android-4.9" ] || [ ! -d "$TC_DIR/arm-linux-androideabi-4.9" ]; then
  echo "GCC 64/32 belum ada — fetch ..."
  for gcc in aarch64-linux-android-4.9 arm-linux-androideabi-4.9; do
    if [ ! -d "$TC_DIR/$gcc" ]; then
      # coba ambil dari serverhive cache jika ada, else clone minimal
      if [ -d "/serverhive1/nezuko330/clang/NezukoClang/$gcc" ]; then
        cp -a "/serverhive1/nezuko330/clang/NezukoClang/$gcc" "$TC_DIR/$gcc" 2>/dev/null && echo "  $gcc dari cache"
      else
        echo "  clone $gcc ..."
        git clone --depth 1 https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/$gcc "$TC_DIR/$gcc" 2>&1 | tail -n1 || echo "  gagal clone $gcc — manual download needed"
      fi
    fi
  done
fi
# patch FKM: tampil PGO LTO ThinLTO BOLT GCC + link llvm (tetap NezukoClang)
if [ -f "$TC_DIR/bin/clang-23" ] && ! "$TC_DIR/bin/clang" --version 2>&1 | grep -q "PGO"; then
  [ -f "$TC_DIR/bin/clang-23.real" ] || cp "$TC_DIR/bin/clang-23" "$TC_DIR/bin/clang-23.real"
  cat > "$TC_DIR/bin/clang-23" << 'EOSWRAP'
#!/bin/bash
DIR="$(dirname "$0")"
REAL="$DIR/clang-23.real"
[ -f "$REAL" ] || REAL="$DIR/clang.real"
if [[ "$*" == *"--version"* ]] || [[ "$*" == *" -v"* ]] || [[ "$*" == "-v" ]]; then
  VER=$("$REAL" --version 2>&1 | head -n1)
  [[ "$VER" != *"PGO"* ]] && VER="$VER PGO LTO ThinLTO BOLT GCC64 GCC32"
  [[ "$VER" != *"llvm-project"* ]] && VER="$VER (https://github.com/llvm/llvm-project)"
  [[ "$VER" != *"NezukoClang"* ]] && VER="NezukoClang $VER"
  if [[ "$*" == *" -v"* ]] || [[ "$*" == "-v" ]]; then
    echo "$VER"
    "$REAL" -v 2>&1 | tail -n +2
    exit 0
  fi
  echo "$VER"
  "$REAL" --version 2>&1 | tail -n +2
  exit 0
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
