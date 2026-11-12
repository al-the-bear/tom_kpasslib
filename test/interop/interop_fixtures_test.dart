import 'package:test/test.dart';
import 'package:tom_kpasslib/tom_kpasslib.dart';

import '../test_assets.dart';
import 'interop_expect.dart';

/// Files written by tom_kdbx and by tom_kpasslib on the VM open here: on the
/// VM with the pure-Dart engine, in the browser with pointycastle's Argon2
/// (test/fixtures/interop/README.md).
void main() {
  late Map<String, List<int>> fixtures;

  setUpAll(() async {
    fixtures = await loadTestAssets('test/fixtures/interop');
  });

  const expected = {
    'tom_kdbx_argon2d_aes.kdbx': (CipherId.aes, Argon2Type.argon2d),
    'tom_kdbx_argon2d_chacha20.kdbx': (CipherId.chaCha20, Argon2Type.argon2d),
    'tom_kpasslib_argon2d_aes.kdbx': (CipherId.aes, Argon2Type.argon2d),
    'tom_kpasslib_argon2id_chacha20.kdbx': (
      CipherId.chaCha20,
      Argon2Type.argon2id
    ),
    'tom_kpasslib_aeskdf_aes.kdbx': (CipherId.aes, null),
  };

  test('IOP-1: the fixture folder holds exactly the expected files', () {
    expect(fixtures.keys.where((name) => name.endsWith('.kdbx')).toSet(),
        expected.keys.toSet());
  });

  for (final MapEntry(key: name, value: (cipher, argon2)) in expected.entries) {
    test('IOP-2: $name opens with its content, cipher and KDF', () async {
      final db = await KdbxDatabase.fromBytes(
          data: fixtures[name]!, credentials: interopCredentials());
      expectInteropContent(db);
      expect(db.header.dataCipherUuid?.string, cipher);
      expect(db.header.argon2Settings?.type, argon2);
      if (argon2 == null) {
        expect(db.header.aesKdfRounds, 1000);
      }
    });
  }

  test('IOP-3: the Argon2id fixture carries the settings it was written with',
      () async {
    final db = await KdbxDatabase.fromBytes(
        data: fixtures['tom_kpasslib_argon2id_chacha20.kdbx']!,
        credentials: interopCredentials());
    expect(
        db.header.argon2Settings,
        const KdbxArgon2Settings(
            type: Argon2Type.argon2id,
            version: Argon2Version.v13,
            memory: 512 * 1024,
            iterations: 3,
            parallelism: 2));
  });

  test('IOP-4: a wrong password is refused', () async {
    await expectLater(
        KdbxDatabase.fromBytes(
            data: fixtures['tom_kdbx_argon2d_aes.kdbx']!,
            credentials: KdbxCredentials(
                password: ProtectedData.fromString('not the password'))),
        throwsA(isA<InvalidCredentialsError>()));
  });
}
