import 'dart:convert';

import 'package:test/test.dart';

/// The files of [directory] (relative to the package root) by name, sent by
/// a hybrid isolate on the VM.
Future<Map<String, List<int>>> loadTestAssets(
    [String directory = 'assets/test']) async {
  final channel =
      spawnHybridUri('/test/test_assets_hybrid.dart', message: directory);
  final files = (await channel.stream.first as Map).cast<String, String>();
  return files.map((name, data) => MapEntry(name, base64.decode(data)));
}
