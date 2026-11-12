import 'test_assets.dart';

/// The test files of `assets/test/`, read on the VM directly and in the
/// browser through a hybrid isolate (`test_assets.dart`).
class TestResources {
  static var demoKey = <int>[];
  static var demoKdbx = <int>[];
  static var demoXml = <int>[];
  static var demoIcon = <int>[];
  static var cyrillicKdbx = <int>[];
  static var binKeyKey = <int>[];
  static var binKeyKdbx = <int>[];
  static var emptyPass = <int>[];
  static var emptyPassWithKeyFileKey = <int>[];
  static var emptyPassWithKeyFile = <int>[];
  static var noPassWithKeyFileKey = <int>[];
  static var noPassWithKeyFile = <int>[];
  static var key32Key = <int>[];
  static var key32 = <int>[];
  static var key64Key = <int>[];
  static var key64 = <int>[];
  static var keyWithBomKey = <int>[];
  static var keyWithBom = <int>[];
  static var keyV2Key = <int>[];
  static var keyV2 = <int>[];
  static var argon2 = <int>[];
  static var argon2id = <int>[];
  static var aesChaCha = <int>[];
  static var aesKdfKdbx4 = <int>[];
  static var argon2ChaCha = <int>[];
  static var yubikey3 = <int>[];
  static var yubikey4 = <int>[];
  static var emptyUuidXml = <int>[];
  static var kdbx41 = <int>[];
  static var mergeKdbx = <int>[];

  static init() async {
    final assets = await loadTestAssets();
    demoKey = assets['demo.key']!;
    demoKdbx = assets['demo.kdbx']!;
    demoXml = assets['demo.xml']!;
    demoIcon = assets['demoIcon.png']!;
    cyrillicKdbx = assets['cyrillic.kdbx']!;
    binKeyKey = assets['binKey.key']!;
    binKeyKdbx = assets['binKey.kdbx']!;
    emptyPass = assets['emptyPass.kdbx']!;
    emptyPassWithKeyFileKey = assets['emptyPassWithKeyFile.key']!;
    emptyPassWithKeyFile = assets['emptyPassWithKeyFile.kdbx']!;
    noPassWithKeyFileKey = assets['noPassWithKeyFile.key']!;
    noPassWithKeyFile = assets['noPassWithKeyFile.kdbx']!;
    key32Key = assets['key32.key']!;
    key32 = assets['key32.kdbx']!;
    key64Key = assets['key64.key']!;
    key64 = assets['key64.kdbx']!;
    keyWithBomKey = assets['keyWithBom.key']!;
    keyWithBom = assets['keyWithBom.kdbx']!;
    keyV2Key = assets['keyV2.keyx']!;
    keyV2 = assets['keyV2.kdbx']!;
    argon2 = assets['argon2.kdbx']!;
    argon2id = assets['argon2id.kdbx']!;
    aesChaCha = assets['aesChaCha.kdbx']!;
    aesKdfKdbx4 = assets['aesKdfKdbx4.kdbx']!;
    argon2ChaCha = assets['argon2ChaCha.kdbx']!;
    yubikey3 = assets['yubikey3.kdbx']!;
    yubikey4 = assets['yubikey4.kdbx']!;
    emptyUuidXml = assets['emptyUuid.xml']!;
    kdbx41 = assets['kdbx4.1.kdbx']!;
    mergeKdbx = assets['merge.kdbx']!;
  }
}
