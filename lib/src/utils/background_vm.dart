import 'dart:isolate';

/// Runs [computation] in a new isolate.
Future<R> runInBackground<R>(R Function() computation) =>
    Isolate.run(computation);
