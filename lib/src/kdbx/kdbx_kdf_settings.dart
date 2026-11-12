import '../crypto/argon2.dart';

/// The Argon2 settings of a KDBX 4 file: what `KdbxHeader.argon2Settings`
/// answers and `KdbxHeader.setArgon2` writes.
final class KdbxArgon2Settings {
  /// Argon2d or Argon2id.
  final Argon2Type type;

  /// The Argon2 version; KeePass and KeePassXC write 1.3.
  final Argon2Version version;

  /// The memory cost in bytes, a multiple of 1024 (KDBX stores bytes).
  final int memory;

  /// The number of passes over the memory.
  final int iterations;

  /// The number of lanes.
  final int parallelism;

  /// Settings with these values.
  const KdbxArgon2Settings({
    required this.type,
    required this.version,
    required this.memory,
    required this.iterations,
    required this.parallelism,
  });

  @override
  bool operator ==(Object other) =>
      other is KdbxArgon2Settings &&
      other.type == type &&
      other.version == version &&
      other.memory == memory &&
      other.iterations == iterations &&
      other.parallelism == parallelism;

  @override
  int get hashCode =>
      Object.hash(type, version, memory, iterations, parallelism);

  @override
  String toString() => 'KdbxArgon2Settings(${type.name}, '
      'v${version.value.toRadixString(16)}, memory: $memory, '
      'iterations: $iterations, parallelism: $parallelism)';
}
