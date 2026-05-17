class MeshBleUuids {
  static const uartService = '6E400001-B5A3-F393-E0A9-E50E24DCCA9E';
  static const uartRx = '6E400002-B5A3-F393-E0A9-E50E24DCCA9E';
  static const uartTx = '6E400003-B5A3-F393-E0A9-E50E24DCCA9E';
}

class MeshSerialFraming {
  static const txStart = 0x3c;
  static const rxStart = 0x3e;
  static const maxPayloadLength = 300;
  static const defaultBaudRate = 115200;
}

class MeshErrorCodes {
  static const messages = <int, String>{
    1: 'ERR_CODE_UNSUPPORTED_CMD',
    2: 'ERR_CODE_NOT_FOUND',
    3: 'ERR_CODE_TABLE_FULL',
    4: 'ERR_CODE_BAD_STATE',
    5: 'ERR_CODE_FILE_IO_ERROR',
    6: 'ERR_CODE_ILLEGAL_ARG',
  };
}
