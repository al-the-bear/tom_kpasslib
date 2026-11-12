/// The optional native engine (`native/kreepto-rust`) for the tests: loaded
/// where `dart:ffi` exists and the library was built, `null` otherwise (and
/// always on the web).
library;

export 'native_engine_web.dart' if (dart.library.ffi) 'native_engine_io.dart';
