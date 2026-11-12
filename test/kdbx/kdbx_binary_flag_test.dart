import 'dart:convert';

import 'package:test/test.dart';
import 'package:tom_kpasslib/tom_kpasslib.dart';

/// A KDBX 4 binary's protected flag (bit 0x01 of its inner-header flag byte)
/// survives a save and a read, in both directions and over two round trips.
void main() {
  final credentials = KdbxCredentials(password: ProtectedData.fromString('pw'));

  Future<KdbxDatabase> roundTrip(KdbxDatabase db) async =>
      KdbxDatabase.fromBytes(data: await db.save(), credentials: credentials);

  test('BF-1: a protected and a plain binary keep their kind', () async {
    final db = KdbxDatabase.create(credentials: credentials, name: 'b');
    final entry = db.createEntry(parent: db.root);
    entry.binaries['protected'] = db.binaries.add(ProtectedBinary(
        protectedData: ProtectedData.fromBytes(utf8.encode('secret'))));
    entry.binaries['plain'] = db.binaries
        .add(PlainBinary(data: utf8.encode('open'), compressed: false));

    var current = db;
    for (var round = 1; round <= 2; round++) {
      current = await roundTrip(current);
      final back = current.root.entries.single;
      final protected = current.binaries.getByRef(back.binaries['protected']!);
      final plain = current.binaries.getByRef(back.binaries['plain']!);
      expect(protected, isA<ProtectedBinary>(), reason: 'round $round');
      expect(plain, isA<PlainBinary>(), reason: 'round $round');
      expect(utf8.decode(protected!.data), 'secret');
      expect(utf8.decode(plain!.data), 'open');
    }
  });
}
