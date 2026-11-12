@TestOn('vm')
library;

import 'package:convert/convert.dart';
import 'package:tom_kpasslib/src/utils/parameters_map.dart';
import 'package:test/test.dart';

/// The upstream dictionary tests: their 64-bit values use all 64 bits, which
/// only the VM represents (the web tests are in parameters_map_test.dart).
void main() {
  group('ParametersMap unit tests (full 64-bit values)', () {
    const data =
        '00010808000000426f6f6c5472756501000000010809000000426f6f6c46616c'
        '73650100000000040600000055496e743332040000002a000000050600000055'
        '496e74363408000000ffffeeeeddddcccc0c05000000496e74333204000000d6'
        'ffffff0d05000000496e74363408000000444433332222111118060000005374'
        '72696e670b000000537472696e6756616c756542090000004279746541727261'
        '7907000000000102030405ff00';
    test('reads and writes dictionary', () {
      final params = ParametersMap.fromBytes(hex.decode(data));
      expect(params.get('BoolTrue'), true);
      expect(params.get('BoolFalse'), false);
      expect(params.get('UInt32'), 42);
      expect(params.get('UInt64'), 0xccccddddeeeeffff);
      expect(params.get('Int32'), -42);
      expect(params.get('Int64'), 0x1111222233334444);
      expect(params.get('String'), 'StringValue');
      expect(
          hex.encode(params.get('ByteArray') as List<int>), '000102030405ff');
      expect(hex.encode(params.bytes), data);
    });

    test('writes dictionary', () {
      final params = ParametersMap()
        ..addAll([
          ('BoolTrue', ParameterType.bool, true),
          ('BoolFalse', ParameterType.bool, false),
          ('UInt32', ParameterType.uInt32, 42),
          ('UInt64', ParameterType.uInt64, 0xccccddddeeeeffff),
          ('Int32', ParameterType.int32, -42),
          ('Int64', ParameterType.int64, 0x1111222233334444),
          ('String', ParameterType.string, 'StringValue'),
          ('ByteArray', ParameterType.bytes, hex.decode('000102030405ff')),
        ]);
      expect(hex.encode(params.bytes), data);
    });
  });
}
