import 'package:test/test.dart';
import 'package:tom_kpasslib/tom_kpasslib.dart';

/// KDBX 3 protects field values and binaries in Meta with one inner random
/// stream, taken in document order: a protected binary (Meta, written first)
/// and protected fields (Root, after it) both read back.
void main() {
  test(
      'K3S-1: a KDBX 3.1 file with a protected binary and protected fields '
      'reads back, over two round trips', () async {
    final credentials =
        KdbxCredentials(password: ProtectedData.fromString('pw'));
    final db = KdbxDatabase.create(credentials: credentials, name: 'v3')
      ..header.version = (3, 1);
    final entry = db.createEntry(parent: db.root);
    entry.fields['Password'] =
        KdbxTextField.fromText(text: 'secret-value', protected: true);
    entry.fields['PIN'] = KdbxTextField.fromText(text: '1234', protected: true);
    entry.binaries['secret.bin'] = db.binaries.add(
      ProtectedBinary(protectedData: ProtectedData.fromString('binary')),
    );
    entry.pushHistory();
    entry.fields['Password'] =
        KdbxTextField.fromText(text: 'newer-value', protected: true);

    var current = db;
    for (var round = 1; round <= 2; round++) {
      current = await KdbxDatabase.fromBytes(
        data: await current.save(),
        credentials: credentials,
      );
      final back = current.root.entries.single;
      expect(back.fields['Password']!.text, 'newer-value',
          reason: 'round $round');
      expect(back.fields['PIN']!.text, '1234');
      expect(back.history.single.fields['Password']!.text, 'secret-value');
      final binary = current.binaries.getByRef(back.binaries['secret.bin']!);
      expect(String.fromCharCodes(binary!.data), 'binary');
    }
  });
}
