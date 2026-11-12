import 'dart:io';

/// The files of [directory] (relative to the package root) by name.
Future<Map<String, List<int>>> loadTestAssets(
        [String directory = 'assets/test']) async =>
    {
      for (final file in Directory(directory).listSync().whereType<File>())
        file.uri.pathSegments.last: file.readAsBytesSync(),
    };
