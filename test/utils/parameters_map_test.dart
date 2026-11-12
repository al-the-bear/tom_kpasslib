import 'package:convert/convert.dart';
import 'package:tom_kpasslib/tom_kpasslib.dart';
import 'package:tom_kpasslib/src/utils/parameters_map.dart';
import 'package:test/test.dart';

void main() {
  group('ParametersMap unit tests', () {
    // The dictionary with full 64-bit values is parameters_map_64bit_test.dart
    // (VM only: dart2js cannot represent them).
    test('reads and writes 64-bit values up to 2^53', () {
      final params = ParametersMap()
        ..addAll([
          ('UInt64', ParameterType.uInt64, 9007199254740991),
          ('Int64', ParameterType.int64, -9007199254740991),
          ('Memory', ParameterType.uInt64, 64 * 1024 * 1024),
        ]);
      final again = ParametersMap.fromBytes(params.bytes);
      expect(again.get('UInt64'), 9007199254740991);
      expect(again.get('Int64'), -9007199254740991);
      expect(again.get('Memory'), 64 * 1024 * 1024);
      expect(again.bytes, params.bytes);
    });

    test('returns undefined for not found value', () {
      final params = ParametersMap();
      expect(params.get('val'), null);
    });

    test('allows to add key twice', () {
      final params = ParametersMap()
        ..addAll([
          ('UInt32', ParameterType.uInt32, 42),
          ('UInt32', ParameterType.uInt32, 43),
        ]);
      expect(params.get('UInt32'), 43);
    });

    test('throws error for empty version', () {
      expect(
          () => ParametersMap.fromBytes(hex.decode('0000')),
          throwsA(predicate((e) =>
              e is UnsupportedValueError &&
              e.message.contains('kdf version'))));
    });

    test('throws error for larger version', () {
      expect(
          () => ParametersMap.fromBytes(hex.decode('0002')),
          throwsA(predicate((e) =>
              e is UnsupportedValueError &&
              e.message.contains('kdf version'))));
    });

    test('throws error for bad value type', () {
      expect(
          () => ParametersMap.fromBytes(hex.decode('0001ff01000000dd10000000')),
          throwsA(predicate((e) =>
              e is UnsupportedValueError &&
              e.message.contains('bad value type'))));
    });

    test('reads empty dictionary', () {
      ParametersMap.fromBytes(hex.decode('000100'));
    });

    test('throws error for bad key length', () {
      expect(
          () => ParametersMap.fromBytes(hex.decode('00010400000000dd10000000')),
          throwsA(predicate((e) =>
              e is FileCorruptedError &&
              e.message.contains('bad key length'))));
    });

    test('throws error for bad value length', () {
      expect(
          () => ParametersMap.fromBytes(hex.decode('0001040100000000ffffffff')),
          throwsA(predicate((e) =>
              e is FileCorruptedError &&
              e.message.contains('bad value length'))));
    });

    test('throws error for bad uint32 value', () {
      expect(
          () =>
              ParametersMap.fromBytes(hex.decode('00010401000000000500000000')),
          throwsA(predicate((e) =>
              e is FileCorruptedError &&
              e.message.contains('bad value length'))));
    });

    test('throws error for bad uint64 value', () {
      expect(
          () =>
              ParametersMap.fromBytes(hex.decode('00010501000000000500000000')),
          throwsA(predicate((e) =>
              e is FileCorruptedError &&
              e.message.contains('bad value length'))));
    });

    test('throws error for bad bool value', () {
      expect(
          () =>
              ParametersMap.fromBytes(hex.decode('00010801000000000500000000')),
          throwsA(predicate((e) =>
              e is FileCorruptedError &&
              e.message.contains('bad value length'))));
    });

    test('throws error for bad int32 value', () {
      expect(
          () =>
              ParametersMap.fromBytes(hex.decode('00010c01000000000500000000')),
          throwsA(predicate((e) =>
              e is FileCorruptedError &&
              e.message.contains('bad value length'))));
    });

    test('throws error for bad int64 value', () {
      expect(
          () =>
              ParametersMap.fromBytes(hex.decode('00010d01000000000500000000')),
          throwsA(predicate((e) =>
              e is FileCorruptedError &&
              e.message.contains('bad value length'))));
    });

    test('throws error for bad int32 on set', () {
      expect(
          () => ParametersMap().add(
                key: 'val',
                type: ParameterType.int32,
                value: 'str',
              ),
          throwsA(predicate((e) =>
              e is UnsupportedValueError &&
              e.message.contains('invalid parameter type'))));
    });

    test('throws error for bad int64 on set', () {
      expect(
          () => ParametersMap().add(
                key: 'val',
                type: ParameterType.int64,
                value: 'str',
              ),
          throwsA(predicate((e) =>
              e is UnsupportedValueError &&
              e.message.contains('invalid parameter type'))));
    });

    test('throws error for bad bool on set', () {
      expect(
          () => ParametersMap().add(
                key: 'val',
                type: ParameterType.bool,
                value: 'true',
              ),
          throwsA(predicate((e) =>
              e is UnsupportedValueError &&
              e.message.contains('invalid parameter type'))));

      expect(
          () => ParametersMap().add(
                key: 'val',
                type: ParameterType.bool,
                value: 1,
              ),
          throwsA(predicate((e) =>
              e is UnsupportedValueError &&
              e.message.contains('invalid parameter type'))));
    });

    test('throws error for bad uint32 on set', () {
      expect(
          () => ParametersMap().add(
                key: 'val',
                type: ParameterType.uInt32,
                value: 'str',
              ),
          throwsA(predicate((e) =>
              e is UnsupportedValueError &&
              e.message.contains('invalid parameter type'))));
    });

    test('throws error for bad uint64 on set', () {
      expect(
          () => ParametersMap().add(
                key: 'val',
                type: ParameterType.uInt64,
                value: 'str',
              ),
          throwsA(predicate((e) =>
              e is UnsupportedValueError &&
              e.message.contains('invalid parameter type'))));
    });

    test('throws error for bad string on set', () {
      expect(
          () => ParametersMap().add(
                key: 'val',
                type: ParameterType.string,
                value: 123,
              ),
          throwsA(predicate((e) =>
              e is UnsupportedValueError &&
              e.message.contains('invalid parameter type'))));
    });

    test('throws error for bad bytes', () {
      expect(
          () => ParametersMap().add(
                key: 'val',
                type: ParameterType.bytes,
                value: '000',
              ),
          throwsA(predicate((e) =>
              e is UnsupportedValueError &&
              e.message.contains('invalid parameter type'))));

      expect(
          () => ParametersMap().add(
                key: 'val',
                type: ParameterType.bytes,
                value: 123,
              ),
          throwsA(predicate((e) =>
              e is UnsupportedValueError &&
              e.message.contains('invalid parameter type'))));
    });
  });
}
