import 'dart:convert';
import 'dart:io';

import 'package:stream_channel/stream_channel.dart';

/// Sends the files of the directory named by [message] (relative to the
/// package root), base64 by name, to a browser test.
void hybridMain(StreamChannel<Object?> channel, Object? message) {
  channel.sink.add({
    for (final file
        in Directory(message as String).listSync().whereType<File>())
      file.uri.pathSegments.last: base64.encode(file.readAsBytesSync()),
  });
}
