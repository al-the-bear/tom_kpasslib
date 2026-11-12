import 'dart:convert';

import 'package:stream_channel/stream_channel.dart';
import 'package:tom_kpasslib/tom_kpasslib.dart';

import 'interop_expect.dart';

/// Opens, on the VM, the KDBX files a browser test sends (base64), and answers
/// for each what it found: `ok` with the cipher and KDF settings, or the error.
void hybridMain(StreamChannel<Object?> channel) {
  channel.stream.listen((message) async {
    final file = base64.decode(message as String);
    try {
      final db = await KdbxDatabase.fromBytes(
          data: file, credentials: interopCredentials());
      final problems = interopContentProblems(db);
      channel.sink.add({
        'ok': problems.isEmpty,
        'problems': problems,
        'cipher': db.header.dataCipherUuid?.string,
        'argon2': db.header.argon2Settings?.toString(),
        'aesRounds': db.header.aesKdfRounds,
      });
    } catch (error) {
      channel.sink.add({'ok': false, 'error': '$error'});
    }
  });
}
