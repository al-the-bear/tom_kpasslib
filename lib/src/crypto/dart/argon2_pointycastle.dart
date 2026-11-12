import 'dart:typed_data';

import 'package:pointycastle/key_derivators/api.dart' show Argon2Parameters;
import 'package:pointycastle/key_derivators/argon2.dart'
    show Argon2BytesGenerator;

import '../argon2.dart';

/// Argon2 through pointycastle's `Argon2BytesGenerator` (MIT).
///
/// pointycastle computes the 64-bit words of Argon2 and Blake2b in 32-bit
/// halves, so this implementation runs under dart2js, where the pure-Dart
/// [Argon2] of this package (64-bit integer arithmetic) cannot. It is the
/// engine's Argon2 on the web; on the VM the pure-Dart one is faster.
class Argon2PointyCastle extends Argon2 {
  static const _hashLength = 32;

  /// The Argon2 variant.
  final Argon2Type type;

  /// The Argon2 version.
  final Argon2Version version;

  /// The number of lanes.
  final int parallelism;

  /// The memory cost in KiB.
  final int memorySizeKB;

  /// The number of passes.
  final int iterations;

  /// The salt.
  final List<int> salt;

  /// Creates an Argon2 hasher with these parameters.
  Argon2PointyCastle({
    this.type = Argon2Type.argon2id,
    this.version = Argon2Version.v13,
    required this.parallelism,
    required this.memorySizeKB,
    required this.iterations,
    required this.salt,
  });

  @override
  Uint8List convert(List<int> password) {
    final generator = Argon2BytesGenerator()
      ..init(Argon2Parameters(
        type.value,
        Uint8List.fromList(salt),
        desiredKeyLength: _hashLength,
        iterations: iterations,
        memory: memorySizeKB,
        lanes: parallelism,
        version: version.value,
      ));
    return generator.process(Uint8List.fromList(password));
  }
}
