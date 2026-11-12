import '../argon2.dart';
import 'argon2_dart.dart';

/// Creates the default [Argon2] on the VM: [Argon2Dart].
Argon2 createPlatformArgon2({
  required Argon2Type type,
  required Argon2Version version,
  required int parallelism,
  required int memorySizeKB,
  required int iterations,
  required List<int> salt,
}) =>
    Argon2Dart(
      type: type,
      version: version,
      parallelism: parallelism,
      memorySizeKB: memorySizeKB,
      iterations: iterations,
      salt: salt,
    );
