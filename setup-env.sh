#!/bin/bash
# NezukoClang env setup — source this file:
#   source /path/to/NezukoClang/setup-env.sh
TC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PATH="$TC_DIR/bin:$PATH"
export CLANG_DIR="$TC_DIR"
echo "NezukoClang ready: $(clang --version | head -n 1)"
echo "CLANG_DIR=$CLANG_DIR"
echo ""
echo "Kernel build example (arm64):"
echo "  make O=out ARCH=arm64 miatoll_defconfig"
echo "  make -j\$(nproc) O=out ARCH=arm64 \\"
echo "    CC=clang LD=ld.lld AR=llvm-ar NM=llvm-nm STRIP=llvm-strip \\"
echo "    OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump READELF=llvm-readelf \\"
echo "    LLVM=1 LLVM_IAS=1 \\"
echo "    CROSS_COMPILE=\"\$CLANG_DIR/bin/aarch64-linux-gnu-\" \\"
echo "    CROSS_COMPILE_ARM32=\"<path-to>/arm-linux-androideabi-\" Image.gz"
