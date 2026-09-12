#!/bin/bash
# NezukoClang build script — LLVM main (clang 24.0.0git), kernel-focused toolchain
# Layout:
#   source : /serverhive1/nezuko330/nezuko-clang/llvm-project
#   build  : /serverhive1/nezuko330/nezuko-clang/build
#   install: /serverhive1/nezuko330/NezukoClang
#
# Branding: -DPACKAGE_VENDOR/-DCLANG_VENDOR="NezukoClang " ->
#   `clang --version` prints "NezukoClang clang version 24.0.0git".
#   (Vendor-prefix style like Neutron, keeps the "clang version" substring
#   that kernel Kbuild uses for compiler detection. Do NOT rename the
#   ToolName in Version.cpp — it breaks cc-name detection.)
set -e
SRC=/serverhive1/nezuko330/nezuko-clang/llvm-project
BLD=/serverhive1/nezuko330/nezuko-clang/build
DST=/serverhive1/nezuko330/NezukoClang
HOST_TC=/serverhive1/nezuko330/clang/bin   # Neutron clang 19 bootstrap

export PATH="$HOST_TC:$PATH"
export CC="$HOST_TC/clang"
export CXX="$HOST_TC/clang++"
export LDFLAGS="-fuse-ld=lld"

cmake -G Ninja -S "$SRC/llvm" -B "$BLD" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="$DST" \
  -DLLVM_ENABLE_PROJECTS="clang;lld;polly" \
  -DLLVM_TARGETS_TO_BUILD="AArch64;ARM" \
  -DCLANG_ENABLE_STATIC_ANALYZER=OFF \
  -DCLANG_ENABLE_ARCMT=OFF \
  -DCLANG_DEFAULT_LINKER=lld \
  -DPACKAGE_VENDOR="NezukoClang " \
  -DCLANG_VENDOR="NezukoClang " \
  -DLLVM_ENABLE_ASSERTIONS=OFF \
  -DLLVM_ENABLE_WARNINGS=OFF \
  -DLLVM_INCLUDE_TESTS=OFF \
  -DLLVM_INCLUDE_EXAMPLES=OFF \
  -DLLVM_INCLUDE_BENCHMARKS=OFF \
  -DCLANG_INCLUDE_TESTS=OFF \
  -DLLVM_APPEND_VC_REV=OFF \
  -DLLVM_PARALLEL_LINK_JOBS=8 \
  -DCMAKE_C_FLAGS="-ffunction-sections -fdata-sections" \
  -DCMAKE_CXX_FLAGS="-ffunction-sections -fdata-sections" \
  -DCMAKE_EXE_LINKER_FLAGS="-fuse-ld=lld -Wl,--gc-sections" \
  -DCMAKE_SHARED_LINKER_FLAGS="-fuse-ld=lld -Wl,--gc-sections" \
  -DCMAKE_MODULE_LINKER_FLAGS="-fuse-ld=lld -Wl,--gc-sections"

echo "Configured. Build with:"
echo "  ninja -C $BLD -j96 clang lld llvm-ar llvm-nm llvm-objcopy llvm-objdump llvm-readelf llvm-strip clang-resource-headers"
echo "Install with:"
echo "  ninja -C $BLD install-clang install-lld install-llvm-ar install-llvm-nm install-llvm-objcopy install-llvm-objdump install-llvm-readelf install-llvm-strip install-clang-resource-headers"
echo "Then prune (not needed for kernel builds): rm -f $DST/bin/clang-cpp $DST/bin/clang-dxc"
