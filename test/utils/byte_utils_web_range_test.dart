import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:test/test.dart';
import 'package:tom_kpasslib/src/crypto/hmac_block_transform.dart';
import 'package:tom_kpasslib/src/utils/byte_utils.dart';

/// 64-bit values as KDBX files hold them, read and written as two 32-bit
/// halves so the web gets the same bytes as the VM: every value up to 2^53
/// (memory sizes, iteration and round counts, block indexes, times).
void main() {
  const values = [
    0,
    1,
    0xffffffff,
    0x100000000,
    64 * 1024 * 1024,
    0x123456789abcd,
    9007199254740991, // 2^53 - 1
  ];

  test('BW-1: unsigned values up to 2^53 survive a write and a read', () {
    for (final value in values) {
      final writer = BytesWriter()..writeUint64(value);
      expect(writer.bytes, hasLength(8));
      expect(BytesReader(writer.bytes).readUint64(), value, reason: '$value');
    }
  });

  test('BW-2: signed values between -2^53 and 2^53 survive a write and a read',
      () {
    for (final value in [...values, ...values.map((v) => -v)]) {
      final writer = BytesWriter()..writeInt64(value);
      expect(BytesReader(writer.bytes).readInt64(), value, reason: '$value');
    }
  });

  test('BW-3: the bytes are little-endian, negatives in two\'s complement', () {
    expect(hex.encode((BytesWriter()..writeUint64(0x0102030405)).bytes),
        '0504030201000000');
    expect(
        hex.encode((BytesWriter()..writeInt64(-2)).bytes), 'feffffffffffffff');
    expect(BytesReader(hex.decode('feffffffffffffff')).readInt64(), -2);
  });

  test('BW-4: the header HMAC key is the key of block index 2^64 - 1', () {
    final key = List.generate(64, (i) => i);
    expect(HmacBlockTransform.getHeaderHmacKey(key: key),
        sha512.convert([...List.filled(8, 0xff), ...key]).bytes);
    // -1 is written as eight 0xFF bytes too, on the VM and on the web.
    expect(HmacBlockTransform.getHeaderHmacKey(key: key),
        HmacBlockTransform.getHmacKey(key: key, index: -1));
  });
}
