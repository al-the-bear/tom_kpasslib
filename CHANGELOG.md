# KPassLib changelog

## 1.1.2+tom.5

- Saving a file with large attachments is several times faster (40 MB:
  about 12 s to 2 s on the VM). `CryptoUtils.wipeData` overwrites with
  zeros instead of drawing each byte from `Random.secure`, which took about
  4 s per 40 MB, and a save wiped three such buffers. The inner header's
  binaries, the inner header with the XML, and the header with the body are
  joined into typed buffers instead of list concatenations, so gzip gets a
  `Uint8List`. The HMAC of a block is computed over its parts without
  copying the block first.

## 1.1.2+tom.4

- The auto-type types are exported (`KdbxAutoType`, `KdbxAutoTypeItem`,
  `AutoTypeObfuscationOptions`): an entry's `autoType` was readable, but a
  window association could not be made outside the library.

## 1.1.2+tom.3

- A KDBX 3 file with a protected binary keeps its protected values: the XML
  was built Root first and Meta second, so the protected binaries in Meta took
  their bytes of the inner random stream after every protected field, while a
  reader takes them in document order (Meta first). Every protected value of
  such a file read back as garbage, in KeePass and KeePassXC too.

## 1.1.2+tom.2

- A KDBX 4 binary's protected flag reads correctly: the inner header marks a
  protected binary with bit 0x01, which was read inverted, so every binary
  came back with the other kind and each save flipped it again.

## 1.1.2+tom.1

Fork of kpasslib 1.1.2 (al-the-bear/tom_kpasslib, branch `tom/1.1.2-patches`),
published on pub.dev as `tom_kpasslib`; its library is
`package:tom_kpasslib/tom_kpasslib.dart`:

- Runs on the web (dart2js): `CryptoFfi` is exported from `dart:ffi` platforms
  only (a stub that cannot be constructed elsewhere); the default engine's
  Argon2 is pointycastle's on the web and the pure-Dart one on the VM; 64-bit
  values are read and written as two 32-bit halves (exact up to 2^53 on the
  web); the header HMAC key's block index is written as bytes; the AES-KDF
  runs in the event loop where there are no isolates.
- KDF parameters: `KdbxHeader.argon2Settings` and `setArgon2` (type, memory,
  iterations, parallelism, version), `aesKdfRounds` and `setAesKdf`, with
  `KdbxArgon2Settings`; `Argon2Type` and `Argon2Version` are exported.
- Accepts `xml` 7 as well as 6.
- The test suite runs in the browser too (`dart test -p chrome`), with interop
  fixtures written by `tom_kdbx` and on the VM, and files written in the
  browser opened on the VM.

## 1.1.2

- Exported `CryptoFfi` from main library import.

## 1.1.1

- General improvements.

## 1.1.0

- Improved cryptography performance.
- Added pure Dart implementations of AES, ChaCha20, Salsa20, and Argon2.
- Added Rust implementations of AES, ChaCha20, Salsa20, and Argon2, and integrated them using FFI.
- Removed third-party dependencies for cryptographic operations.

## 1.0.8

- Fixed _KdbxDatabase.getGroup()_ method.
- Fixed _KdbxBinaries_ inconsistency.

## 1.0.7

- Minor fixes.

## 1.0.6

- Fixed KDBX4 incompatibility with KeePass Desktop.
- General improvements.

## 1.0.5

- Improved performance.

## 1.0.4

- Renamed _Icon_ enum to _KdbxIcon_.

## 1.0.3

- Removed _meta_ dependency.

## 1.0.2

- Support Web platform.

## 1.0.1

- Minor fix.

## 1.0.0

- Initial version.
