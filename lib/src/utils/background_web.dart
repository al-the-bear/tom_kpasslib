/// Runs [computation] in the same event loop: the web has no isolates.
Future<R> runInBackground<R>(R Function() computation) => Future(computation);
