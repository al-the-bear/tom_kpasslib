/// The engine's default Argon2 on this platform: the pure-Dart one on the VM,
/// pointycastle's on the web (see `argon2_pointycastle.dart`).
library;

export 'argon2_platform_web.dart'
    if (dart.library.io) 'argon2_platform_vm.dart';
