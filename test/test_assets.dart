/// The test files of a directory by name: read with `dart:io` on the VM, and in
/// the browser by a hybrid isolate on the VM side (`test_assets_hybrid.dart`).
library;

export 'test_assets_web.dart' if (dart.library.io) 'test_assets_io.dart';
