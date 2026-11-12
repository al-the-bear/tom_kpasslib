import 'package:test/test.dart';
import 'package:tom_kpasslib/tom_kpasslib.dart';

import '../test_resources.dart';

/// The public KDF API of [KdbxHeader]: Argon2 type, memory, iterations,
/// parallelism and version, and AES-KDF rounds, on a new and on an existing
/// database. Runs on the VM and in the browser.
void main() {
  KdbxCredentials credentials() =>
      KdbxCredentials(password: ProtectedData.fromString('kdf'));

  Future<KdbxDatabase> reopen(KdbxDatabase db, KdbxCredentials c) async =>
      KdbxDatabase.fromBytes(data: await db.save(), credentials: c);

  KdbxDatabase newDatabase() {
    final db = KdbxDatabase.create(credentials: credentials(), name: 'kdf');
    db.createEntry(parent: db.root).fields['Title'] =
        KdbxTextField.fromText(text: 'kept');
    return db;
  }

  setUpAll(() async {
    await TestResources.init();
  });

  test('KDF-1: a new database uses Argon2d, 1 MiB, 2 iterations, 1 lane, 1.3',
      () {
    final header = newDatabase().header;
    expect(
        header.argon2Settings,
        const KdbxArgon2Settings(
            type: Argon2Type.argon2d,
            version: Argon2Version.v13,
            memory: 1024 * 1024,
            iterations: 2,
            parallelism: 1));
    expect(header.aesKdfRounds, isNull);
  });

  test('KDF-2: every Argon2 setting is written and read back', () async {
    final db = newDatabase();
    db.header.setArgon2(
        type: Argon2Type.argon2id,
        memory: 256 * 1024,
        iterations: 3,
        parallelism: 2,
        version: Argon2Version.v10);
    final again = await reopen(db, credentials());
    expect(
        again.header.argon2Settings,
        const KdbxArgon2Settings(
            type: Argon2Type.argon2id,
            version: Argon2Version.v10,
            memory: 256 * 1024,
            iterations: 3,
            parallelism: 2));
    expect(
        (again.root.allEntries.single.fields['Title'] as PlainTextField).text,
        'kept');
  });

  test('KDF-3: a setting not given keeps the current one', () {
    final header = newDatabase().header
      ..setArgon2(memory: 128 * 1024, iterations: 4, parallelism: 2)
      ..setArgon2(type: Argon2Type.argon2id);
    expect(
        header.argon2Settings,
        const KdbxArgon2Settings(
            type: Argon2Type.argon2id,
            version: Argon2Version.v13,
            memory: 128 * 1024,
            iterations: 4,
            parallelism: 2));
  });

  test('KDF-4: an existing KeePass file takes new settings and keeps its data',
      () async {
    final keePassCredentials = () => KdbxCredentials(
        password: ProtectedData.fromString('demo'),
        keyData: TestResources.demoKey);
    final db = await KdbxDatabase.fromBytes(
        data: TestResources.argon2, credentials: keePassCredentials());
    expect(db.header.argon2Settings?.type, Argon2Type.argon2d);
    final entries = db.root.allEntries.length;
    db.header.setArgon2(type: Argon2Type.argon2id, memory: 64 * 1024);
    final again = await reopen(db, keePassCredentials());
    expect(again.header.argon2Settings?.type, Argon2Type.argon2id);
    expect(again.header.argon2Settings?.memory, 64 * 1024);
    expect(again.root.allEntries.length, entries);
    expect(again.meta.generator, db.meta.generator);
  });

  test('KDF-5: AES-KDF rounds are written and read back, and Argon2 returns',
      () async {
    final db = newDatabase()..header.setAesKdf(rounds: 1500);
    expect(db.header.argon2Settings, isNull);
    final again = await reopen(db, credentials());
    expect(again.header.aesKdfRounds, 1500);
    expect(again.header.argon2Settings, isNull);
    again.header.setArgon2(memory: 64 * 1024);
    expect(again.header.aesKdfRounds, isNull);
    expect(
        again.header.argon2Settings,
        const KdbxArgon2Settings(
            type: Argon2Type.argon2d,
            version: Argon2Version.v13,
            memory: 64 * 1024,
            iterations: 2,
            parallelism: 1));
    final third = await reopen(again, credentials());
    expect(third.header.argon2Settings?.memory, 64 * 1024);
  });

  test('KDF-6: values outside the ranges are refused, nothing changes', () {
    final header = newDatabase().header;
    final before = header.argon2Settings;
    for (final set in <void Function()>[
      () => header.setArgon2(memory: 64 * 1024 + 1),
      () => header.setArgon2(memory: 4 * 1024),
      () => header.setArgon2(memory: 16 * 1024, parallelism: 4),
      () => header.setArgon2(iterations: 0),
      () => header.setArgon2(parallelism: 0),
      () => header.setArgon2(parallelism: 0x1000000),
      () => header.setAesKdf(rounds: 0),
    ]) {
      expect(set, throwsA(isA<UnsupportedValueError>()));
    }
    expect(header.argon2Settings, before);
  });

  test('KDF-7: a KDBX 3 file has no KDF parameters to set', () {
    final header = newDatabase().header..version = (3, 1);
    expect(header.argon2Settings, isNull);
    expect(header.aesKdfRounds, isNull);
    expect(() => header.setArgon2(memory: 64 * 1024),
        throwsA(isA<InvalidStateError>()));
    expect(
        () => header.setAesKdf(rounds: 10), throwsA(isA<InvalidStateError>()));
  });
}
