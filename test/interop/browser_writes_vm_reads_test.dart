@TestOn('browser')
library;

import 'dart:async';
import 'dart:convert';

import 'package:stream_channel/stream_channel.dart';
import 'package:test/test.dart';
import 'package:tom_kpasslib/tom_kpasslib.dart';

/// Files written in the browser (dart2js, pointycastle's Argon2) open on the
/// VM (pure-Dart engine), read by a hybrid isolate (`vm_reader_hybrid.dart`).
void main() {
  late StreamChannelReader reader;

  setUpAll(() {
    reader = StreamChannelReader(
        spawnHybridUri('/test/interop/vm_reader_hybrid.dart'));
  });

  Future<Map<String, Object?>> writeAndReadOnVm(
      String cipherId, void Function(KdbxHeader header) kdf) async {
    final db = KdbxDatabase.create(
        credentials:
            KdbxCredentials(password: ProtectedData.fromString('interop')),
        name: 'browser');
    db.header.dataCipherUuid = KdbxUuid.fromString(cipherId);
    kdf(db.header);
    final entry = db.createEntry(parent: db.root);
    entry.fields['Title'] = KdbxTextField.fromText(text: 'interop title');
    entry.fields['Password'] =
        KdbxTextField.fromText(text: 'interop secret', protected: true);
    entry.fields['Note'] = KdbxTextField.fromText(text: 'unicode ✓ äöü');
    entry.binaries['a.txt'] = db.binaries.add(
        PlainBinary(data: utf8.encode('attached bytes'), compressed: false));
    db.meta.customData.map['k'] = KdbxCustomItem(value: 'v');
    return reader.ask(base64.encode(await db.save()));
  }

  test('BWV-1: Argon2d and AES, written in the browser, open on the VM',
      () async {
    final answer = await writeAndReadOnVm(CipherId.aes,
        (h) => h.setArgon2(type: Argon2Type.argon2d, memory: 256 * 1024));
    expect(answer['error'], isNull);
    expect(answer['problems'], isEmpty);
    expect(answer['ok'], isTrue);
    expect(answer['cipher'], CipherId.aes);
    expect(answer['argon2'], contains('argon2d'));
  });

  test('BWV-2: Argon2id with 2 lanes and ChaCha20 open on the VM', () async {
    final answer = await writeAndReadOnVm(
        CipherId.chaCha20,
        (h) => h.setArgon2(
            type: Argon2Type.argon2id,
            memory: 512 * 1024,
            iterations: 3,
            parallelism: 2));
    expect(answer['error'], isNull);
    expect(answer['problems'], isEmpty);
    expect(answer['cipher'], CipherId.chaCha20);
    expect(
        answer['argon2'],
        const KdbxArgon2Settings(
                type: Argon2Type.argon2id,
                version: Argon2Version.v13,
                memory: 512 * 1024,
                iterations: 3,
                parallelism: 2)
            .toString());
  });

  test('BWV-3: AES-KDF, written in the browser, opens on the VM', () async {
    final answer =
        await writeAndReadOnVm(CipherId.aes, (h) => h.setAesKdf(rounds: 1000));
    expect(answer['error'], isNull);
    expect(answer['problems'], isEmpty);
    expect(answer['aesRounds'], 1000);
    expect(answer['argon2'], isNull);
  });
}

/// Sends requests to a hybrid isolate and waits for each one's answer.
class StreamChannelReader {
  final StreamChannel<Object?> _channel;
  late final StreamIterator<Object?> _answers = StreamIterator(_channel.stream);

  /// A reader over a hybrid isolate's channel.
  StreamChannelReader(this._channel);

  /// Sends [request] and answers the reply.
  Future<Map<String, Object?>> ask(Object request) async {
    _channel.sink.add(request);
    if (!await _answers.moveNext()) {
      throw StateError('the hybrid isolate closed');
    }
    return (_answers.current as Map).cast<String, Object?>();
  }
}
