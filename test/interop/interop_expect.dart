import 'dart:convert';

import 'package:test/test.dart';
import 'package:tom_kpasslib/tom_kpasslib.dart';

/// The password of every interop fixture.
const interopPassword = 'interop';

/// The credentials of every interop fixture.
KdbxCredentials interopCredentials() =>
    KdbxCredentials(password: ProtectedData.fromString(interopPassword));

/// Where [db] differs from the content every interop fixture holds; empty
/// when it holds it. A list, not `expect`, so a hybrid isolate can report it.
List<String> interopContentProblems(KdbxDatabase db) {
  final problems = <String>[];
  void check(String what, Object? actual, Object? expected) {
    if (actual != expected) {
      problems.add('$what: expected $expected, found $actual');
    }
  }

  final entries = db.root.allEntries.toList();
  if (entries.length != 1) {
    return ['entries: expected 1, found ${entries.length}'];
  }
  final entry = entries.single;
  final title = entry.fields['Title'];
  check('Title', title is PlainTextField ? title.text : title, 'interop title');
  final password = entry.fields['Password'];
  check('Password', password is ProtectedTextField ? password.text : password,
      'interop secret');
  final note = entry.fields['Note'];
  check('Note', note is PlainTextField ? note.text : note, 'unicode ✓ äöü');
  final reference = entry.binaries['a.txt'];
  final binary =
      reference is BinaryReference ? db.binaries.getByRef(reference) : null;
  final bytes = switch (binary) {
    PlainBinary(:final data) => data,
    ProtectedBinary(:final protectedData) => protectedData.bytes,
    _ => null,
  };
  check('a.txt', bytes == null ? null : utf8.decode(bytes), 'attached bytes');
  check('custom data k', db.meta.customData.map['k']?.value, 'v');
  return problems;
}

/// Expects [db] to hold the content every interop fixture holds.
void expectInteropContent(KdbxDatabase db) =>
    expect(interopContentProblems(db), isEmpty);
