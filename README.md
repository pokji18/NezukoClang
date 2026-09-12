# NezukoClang — clang 23.1.1 for Android kernel builds

```
NezukoClang clang version 23.1.1
Target: x86_64-unknown-linux-gnu
```

Kernel-focused LLVM toolchain (built from `llvm/llvm-project` release/23.x):
`clang` + `lld` + `polly`, targets `AArch64` + `ARM` + `X86`.
Branding keeps the `clang version` substring so Kbuild compiler
detection (`cc-name`) keeps working.

PGO/LTO support: `llvm-profdata`, `llvm-cov`, and the compiler-rt
profile + builtins runtimes (`lib/clang/23/lib/...`) are included.
Tested: host PGO cycle (instrument → run → merge → `-fprofile-use`)
and miatoll full-LTO (`CONFIG_LTO_CLANG=y`) kernel build — both OK.

Mods:
- GNU cross-prefix wrappers (`aarch64-linux-gnu-*`, `arm-linux-gnueabi-*`
  for gcc/g++/cc/c++/as/ld/ar/nm/objcopy/objdump/readelf/strip/addr2line/
  size/strings) — freestanding/kernel-oriented, so generic
  `CROSS_COMPILE=<prefix>-` build scripts work out of the box.
- `llvm-bolt` suite (bolt, boltdiff, heatmap, binary-analysis,
  merge-fdata, perf2bolt) for post-link optimization.
- `clang-repl` — interactive C++ interpreter
  (https://clang.llvm.org/docs/ClangRepl.html).
- Full binutils set: `llvm-ar/nm/objcopy/objdump/readelf/readobj/strip/
  addr2line/size/strings/symbolizer`, plus `clang-format`.
- Bundled GCC 4.9 pair (`aarch64-linux-android-4.9/`,
  `arm-linux-androideabi-4.9/`) — the proven combo for 4.14 kernel
  builds (64-bit via clang, 32-bit compat via `CROSS_COMPILE_ARM32`).
  `setup-env.sh` exports `CLANG_DIR`, `GCC64_DIR`, `GCC32_DIR`.

## Tested

`miatoll` (sm6250, 4.14.369) full `Image.gz` build — OK.

## Usage

```bash
export PATH="$PWD/NezukoClang/bin:$PATH"
make O=out ARCH=arm64 miatoll_defconfig
make -j$(nproc) O=out ARCH=arm64 \
  CC=clang LD=ld.lld AR=llvm-ar NM=llvm-nm STRIP=llvm-strip \
  OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump READELF=llvm-readelf \
  LLVM=1 LLVM_IAS=1 \
  CROSS_COMPILE="$PWD/NezukoClang/bin/aarch64-linux-gnu-" \
  CROSS_COMPILE_ARM32="<path-to>/arm-linux-androideabi-" \
  Image.gz
```

The kernel `build.sh` in the miatoll tree expects the toolchain dir
to be named `clang` next to the kernel source, or set `CLANG_DIR`
accordingly.

## Reproduce

See `build-nezuko-clang.sh` (bootstrap needs a host clang + lld).
Source commit: llvm-project release tag `llvmorg-23.1.1` (stable).
