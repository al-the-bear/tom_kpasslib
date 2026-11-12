import '../argon2.dart';
import 'argon2_pointycastle.dart';

/// Creates the default [Argon2] on the web: [Argon2PointyCastle].
Argon2 createPlatformArgon2({
  required Argon2Type type,
  required Argon2Version version,
  required int parallelism,
  required int memorySizeKB,
  required int iterations,
  required List<int> salt,
}) =>
    Argon2PointyCastle(
      type: type,
      version: version,
      parallelism: parallelism,
      memorySizeKB: memorySizeKB,
      iterations: iterations,
      salt: salt,
    );
