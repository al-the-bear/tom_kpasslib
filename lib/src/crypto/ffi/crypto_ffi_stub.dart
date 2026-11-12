import 'dart:typed_data';

import '../aes.dart';
import '../argon2.dart';
import '../chacha20.dart';
import '../crypto_engine.dart';
import '../salsa20.dart';

/// [CryptoFfi] where `dart:ffi` is not available (the web).
///
/// There is no native library to load there, so it cannot be constructed:
/// the default engine, [Crypto.engine], runs the pure-Dart implementations.
class CryptoFfi extends CryptoEngine {
  /// Throws [UnsupportedError]: `dart:ffi` is not available on this platform.
  CryptoFfi(Object lib) {
    throw UnsupportedError('CryptoFfi needs dart:ffi, which this platform '
        'does not have; use the default engine.');
  }

  @override
  Aes256 createAes256({required Uint8List key}) => throw UnsupportedError('');

  @override
  ChaCha20 createChaCha20({required Uint8List key}) =>
      throw UnsupportedError('');

  @override
  Salsa20 createSalsa20({required Uint8List key}) => throw UnsupportedError('');

  @override
  Argon2 createArgon2({
    Argon2Type type = Argon2Type.argon2id,
    Argon2Version version = Argon2Version.v13,
    required int parallelism,
    required int memorySizeKB,
    required int iterations,
    required List<int> salt,
  }) =>
      throw UnsupportedError('');
}
