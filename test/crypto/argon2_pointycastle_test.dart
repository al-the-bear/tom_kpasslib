@TestOn('vm')
library;

import 'package:convert/convert.dart';
import 'package:test/test.dart';
import 'package:tom_kpasslib/src/crypto/dart/argon2_dart.dart';
import 'package:tom_kpasslib/src/crypto/dart/argon2_pointycastle.dart';
import 'package:tom_kpasslib/tom_kpasslib.dart';

/// The web's Argon2 (pointycastle) computes what the VM's (pure Dart) does,
/// over the parameter space KDBX files use. VM only: the pure-Dart Argon2
/// needs 64-bit integers. In the browser, argon2_test.dart's vectors and the
/// KeePass and interop files check pointycastle's directly.
void main() {
  final salt = hex.decode(
      '0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f20');
  final password = hex.decode('cafebabe0123456789abcdef');

  for (final type in Argon2Type.values) {
    for (final version in Argon2Version.values) {
      for (final (memory, iterations, lanes) in [
        (64, 1, 1),
        (256, 3, 2),
        (1024, 2, 4),
      ]) {
        test(
            'A2P: ${type.name} v${version.value.toRadixString(16)} '
            '${memory}KiB x$iterations, $lanes lanes', () {
          final dart = Argon2Dart(
                  type: type,
                  version: version,
                  parallelism: lanes,
                  memorySizeKB: memory,
                  iterations: iterations,
                  salt: salt)
              .convert(password);
          final pointyCastle = Argon2PointyCastle(
                  type: type,
                  version: version,
                  parallelism: lanes,
                  memorySizeKB: memory,
                  iterations: iterations,
                  salt: salt)
              .convert(password);
          expect(hex.encode(pointyCastle), hex.encode(dart));
          expect(pointyCastle, hasLength(32));
        });
      }
    }
  }
}
