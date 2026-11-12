import 'dart:typed_data';

/// 2^32, for 64-bit values handled as two 32-bit halves.
const _twoPow32 = 0x100000000;

/// A reader of bytes sequence.
class BytesReader {
  final ByteData _data;
  int _offset = 0;

  /// Constructs a [BytesReader] from the [bytes] list.
  BytesReader(List<int> bytes)
      : _data = Uint8List.fromList(bytes).buffer.asByteData();

  /// Reads an unsigned 64-bit integer.
  ///
  /// Read as two 32-bit halves, since dart2js has no 64-bit accessors: exact
  /// on the VM, and on the web for values up to 2^53.
  int readUint64() {
    final low = _data.getUint32(_offset, Endian.little);
    final high = _data.getUint32(_offset + 4, Endian.little);
    _offset += 8;
    return high * _twoPow32 + low;
  }

  /// Reads an signed 64-bit integer.
  ///
  /// Read as two 32-bit halves, like [readUint64]: exact on the VM, and on the
  /// web for values between -2^53 and 2^53.
  int readInt64() {
    final low = _data.getUint32(_offset, Endian.little);
    final high = _data.getInt32(_offset + 4, Endian.little);
    _offset += 8;
    return high * _twoPow32 + low;
  }

  /// Reads an unsigned 32-bit integer.
  int readUint32() {
    final result = _data.getUint32(_offset, Endian.little);
    _offset += Uint32List.bytesPerElement;
    return result;
  }

  /// Reads an signed 32-bit integer.
  int readInt32() {
    final result = _data.getInt32(_offset, Endian.little);
    _offset += Int32List.bytesPerElement;
    return result;
  }

  /// Reads an unsigned 16-bit integer.
  int readUint16() {
    final result = _data.getUint16(_offset, Endian.little);
    _offset += Uint16List.bytesPerElement;
    return result;
  }

  /// Reads an unsigned 8-bit integer.
  int readUint8() {
    final result = _data.getUint8(_offset);
    _offset += Uint8List.bytesPerElement;
    return result;
  }

  /// Reads bytes sequence with [length].
  Uint8List readBytes(int length) {
    if (_offset + length >= _data.lengthInBytes) {
      return readBytesToEnd();
    }

    final result = _data.buffer.asUint8List(_offset, length);
    _offset += length;
    return result;
  }

  /// Reads remaining amount of bytes.
  Uint8List readBytesToEnd() {
    final result = _data.buffer.asUint8List(_offset);
    _offset = _data.lengthInBytes;
    return result;
  }

  /// The bytes were already read.
  List<int> get past => _data.buffer.asUint8List(0, _offset);

  /// The remaining length of bytes.
  int get bytesLeft => _data.lengthInBytes - _offset;
}

/// A writer to a sequence of bytes.
class BytesWriter {
  final _builder = BytesBuilder();

  /// Writes unsigned 64-bit integer.
  ///
  /// Written as two 32-bit halves, since dart2js has no 64-bit accessors:
  /// exact on the VM, and on the web for values up to 2^53.
  writeUint64(int value) => _write64(value);

  /// Writes signed 64-bit integer, in two's complement like [writeUint64].
  writeInt64(int value) => _write64(value);

  void _write64(int value) {
    final low = value % _twoPow32;
    final high = ((value - low) ~/ _twoPow32) % _twoPow32;
    final data = ByteData(8)
      ..setUint32(0, low, Endian.little)
      ..setUint32(4, high, Endian.little);
    _builder.add(data.buffer.asUint8List());
  }

  /// Writes unsigned 32-bit integer.
  writeUint32(int value) {
    final data = ByteData(Uint32List.bytesPerElement)
      ..setUint32(0, value, Endian.little);
    _builder.add(data.buffer.asUint8List());
  }

  /// Writes signed 32-bit integer.
  writeInt32(int value) {
    final data = ByteData(Int32List.bytesPerElement)
      ..setInt32(0, value, Endian.little);
    _builder.add(data.buffer.asUint8List());
  }

  /// Writes unsigned 16-bit integer.
  writeUint16(int value) {
    final data = ByteData(Uint16List.bytesPerElement)
      ..setUint16(0, value, Endian.little);
    _builder.add(data.buffer.asUint8List());
  }

  /// Writes unsigned 8-bit integer.
  writeUint8(int value) => _builder.add([value]);

  /// Writes list of the [bytes].
  writeBytes(List<int> bytes) => _builder.add(bytes);

  ///The result bytes sequence.
  Uint8List get bytes => _builder.toBytes(); //TODO: return without copy
}
