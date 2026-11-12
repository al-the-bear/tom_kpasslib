import 'dart:ffi';
import 'dart:io';

import 'package:tom_kpasslib/tom_kpasslib.dart';

/// The native engine when `native/kreepto-rust` has been built, else `null`.
CryptoEngine? loadNativeEngine() {
  final name = switch (Platform.operatingSystem) {
    'macos' || 'ios' => 'libkreepto.dylib',
    'linux' || 'android' => 'libkreepto.so',
    'windows' => 'kreepto.dll',
    _ => throw UnsupportedError(
        'Unsupported platform: ${Platform.operatingSystem}'),
  };
  final path =
      '${Directory.current.path}/native/kreepto-rust/target/release/$name';
  return File(path).existsSync() ? CryptoFfi(DynamicLibrary.open(path)) : null;
}
