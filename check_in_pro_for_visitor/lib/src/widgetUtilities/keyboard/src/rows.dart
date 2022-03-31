part of virtual_keyboard;
const List<List> _keyRows = [
  // Row 1
  const [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '0',
  ],
  // Row 2
  const [
    'q',
    'w',
    'e',
    'r',
    't',
    'y',
    'u',
    'i',
    'o',
    'p',
  ],
  // Row 3
  const [
    'a',
    's',
    'd',
    'f',
    'g',
    'h',
    'j',
    'k',
    'l',
  ],
  // Row 4
  const [
    'z',
    'x',
    'c',
    'v',
    'b',
    'n',
    'm',
  ],
];

/// Keys for Virtual Keyboard's rows.
const List<List> _keyRowsNumeric = [
  // Row 1
  const [
    '1',
    '2',
    '3',
  ],
  // Row 1
  const [
    '4',
    '5',
    '6',
  ],
  // Row 1
  const [
    '7',
    '8',
    '9',
  ],
  // Row 1
  const [
    '0',
  ],
];

List<VirtualKeyboardKey> _getKeyboardRowKeysNumeric(rowNum) {
  return List.generate(_keyRowsNumeric[rowNum].length, (int keyNum) {
    String key = _keyRowsNumeric[rowNum][keyNum];
    return VirtualKeyboardKey(
      text: key.toUpperCase(),
      capsText: key.toUpperCase(),
      keyType: VirtualKeyboardKeyType.String,
    );
  });
}

List<VirtualKeyboardKey> _getKeyboardRowKeys(rowNum) {
  return List.generate(_keyRows[rowNum].length, (int keyNum) {
    String key = _keyRows[rowNum][keyNum];
    return VirtualKeyboardKey(
      text: key.toUpperCase(),
      capsText: key.toUpperCase(),
      keyType: VirtualKeyboardKeyType.String,
    );
  });
}
List<List<VirtualKeyboardKey>> _getKeyboardRows() {
  return List.generate(_keyRows.length, (int rowNum) {
    List<VirtualKeyboardKey> rowKeys = [];
    switch (rowNum) {
      case 1:
        rowKeys = _getKeyboardRowKeys(rowNum);
        rowKeys.add(
          VirtualKeyboardKey(
              keyType: VirtualKeyboardKeyType.Action,
              action: VirtualKeyboardKeyAction.Backspace),
        );
        break;
      case 2:
        rowKeys = _getKeyboardRowKeys(rowNum);
        rowKeys.add(
          VirtualKeyboardKey(
              keyType: VirtualKeyboardKeyType.Action,
              action: VirtualKeyboardKeyAction.Return,
              text: '\n',
              capsText: '\n'),
        );
        break;
      case 3:
        rowKeys.addAll(_getKeyboardRowKeys(rowNum));
        rowKeys.add(
          VirtualKeyboardKey(
              keyType: VirtualKeyboardKeyType.Action,
              action: VirtualKeyboardKeyAction.Shift),
        );
        break;
      default:
        rowKeys = _getKeyboardRowKeys(rowNum);
    }

    return rowKeys;
  });
}

List<List<VirtualKeyboardKey>> _getKeyboardRowsNumeric() {
  return List.generate(_keyRowsNumeric.length, (int rowNum) {
    List<VirtualKeyboardKey> rowKeys = [];
    switch (rowNum) {
      case 3:
        rowKeys.add(
          VirtualKeyboardKey(
              text: 'ABC',
              capsText: 'ABC',
              keyType: VirtualKeyboardKeyType.Action,
              action: VirtualKeyboardKeyAction.Shift),
        );
        rowKeys.addAll(_getKeyboardRowKeysNumeric(rowNum));
        rowKeys.add(
          VirtualKeyboardKey(
              keyType: VirtualKeyboardKeyType.Action,
              action: VirtualKeyboardKeyAction.Backspace),
        );
        break;
      default:
        rowKeys = _getKeyboardRowKeysNumeric(rowNum);
    }
    return rowKeys;
  });
}