/// Runs CPU-bound work off the calling isolate where the platform has
/// isolates (`Isolate.run`), and in the same event loop on the web, which has
/// none.
library;

export 'background_web.dart' if (dart.library.isolate) 'background_vm.dart';
