import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:ffi/ffi.dart' as ffi;
import 'package:win32/win32.dart';

String? getDefaultPrinter() {
  final sizePtr = calloc<Uint32>();
  // First call to get required buffer size
  GetDefaultPrinter(nullptr, sizePtr);
  final bufferSize = sizePtr.value;

  if (bufferSize == 0) {
    calloc.free(sizePtr);
    return null;
  }

  final bufferPtr = calloc<Uint16>(bufferSize);

  final result = GetDefaultPrinter(bufferPtr as Pointer<Utf16>, sizePtr);
  if (result == 0) {
    calloc.free(sizePtr);
    calloc.free(bufferPtr);
    return null;
  }
  final printerName = bufferPtr.cast<Utf16>().toDartString();

  calloc.free(sizePtr);
  calloc.free(bufferPtr);

  return printerName;
}
