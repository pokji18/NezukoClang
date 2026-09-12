#!/bin/bash
# NezukoClang build script — LLVM release/23.x (clang 23.1.1 stable), kernel-focused toolchain
# Layout:
#   source : /serverhive1/nezuko330/clang/llvm-project
#   build  : /serverhive1/nezuko330/clang/build
#   install: /serverhive1/nezuko330/clang/NezukoClang
#
# Branding: -DPACKAGE_VENDOR/-DCLANG_VENDOR="NezukoClang " ->
#   `clang --version` prints "NezukoClang clang version 23.1.1".
#   (Vendor-prefix style like Neutron, keeps the "clang version" substring
#   that kernel Kbuild uses for compiler detection. Do NOT rename the
#   ToolName in Version.cpp — it breaks cc-name detection.)
set -e
SRC=/serverhive1/nezuko330/clang/llvm-project
BLD=/serverhive1/nezuko330/clang/build
DST=/serverhive1/nezuko330/clang/NezukoClang
HOST_TC=/serverhive1/nezuko330/clang/NezukoClang/bin   # self-hosting bootstrap

export PATH="$HOST_TC:$PATH"
export CC="$HOST_TC/clang"
export CXX="$HOST_TC/clang++"
export LDFLAGS="-fuse-ld=lld"

cmake -G Ninja -S "$SRC/llvm" -B "$BLD" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="$DST" \
  -DLLVM_ENABLE_PROJECTS="clang;lld;polly;bolt" \
  -DLLVM_TARGETS_TO_BUILD="AArch64;ARM;X86" \
  -DLLVM_DEFAULT_TARGET_TRIPLE="x86_64-unknown-linux-gnu" \
  -DLLVM_ENABLE_RUNTIMES="compiler-rt;openmp" \
  -DCOMPILER_RT_BUILD_BUILTINS=ON \
  -DCOMPILER_RT_BUILD_PROFILE=ON \
  -DCOMPILER_RT_BUILD_SANITIZERS=ON \
  -DCOMPILER_RT_SANITIZERS_TO_BUILD="asan" \
  -DCOMPILER_RT_BUILD_XRAY=OFF \
  -DCOMPILER_RT_BUILD_LIBFUZZER=OFF \
  -DCOMPILER_RT_BUILD_MEMPROF=OFF \
  -DCOMPILER_RT_BUILD_ORC=OFF \
  -DCOMPILER_RT_DEFAULT_TARGET_ONLY=ON \
  -DCLANG_DEFAULT_LINKER=lld \
  -DLLVM_ENABLE_LTO=OFF \
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
echo "  ninja -C $BLD -j96 clang lld llvm-ar llvm-nm llvm-objcopy llvm-objdump llvm-readelf llvm-strip llvm-profdata llvm-cov llvm-bolt merge-fdata clang-repl llvm-addr2line llvm-size llvm-strings llvm-symbolizer clang-format clang-resource-headers compiler-rt"
echo "Install with:"
echo "  ninja -C $BLD install-clang install-lld install-llvm-ar install-llvm-nm install-llvm-objcopy install-llvm-objdump install-llvm-readelf install-llvm-strip install-llvm-profdata install-llvm-cov install-llvm-bolt install-clang-repl install-llvm-addr2line install-llvm-size install-llvm-strings install-llvm-symbolizer install-clang-format install-clang-resource-headers install-compiler-rt"
echo "Then prune (not needed for kernel builds): rm -f $DST/bin/clang-cpp $DST/bin/clang-dxc"
