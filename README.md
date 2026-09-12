# NezukoClang — clang 24.0.0git for Android kernel builds

```
NezukoClang clang version 24.0.0git
Target: x86_64-unknown-linux-gnu
```

Kernel-focused LLVM toolchain (built from `llvm/llvm-project` main):
`clang` + `lld` + `polly`, targets `AArch64` + `ARM`.
Branding keeps the `clang version` substring so Kbuild compiler
detection (`cc-name`) keeps working.

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
Source commit: llvm-project main `5eff11f8e`.
