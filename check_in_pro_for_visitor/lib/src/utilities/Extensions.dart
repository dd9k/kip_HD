import 'package:flutter/material.dart';

extension StringX on String {
  // Viết hoa chữ cái đầu
  String capitalize() {
    if (length > 0) {
      return '${this[0].toUpperCase()}${substring(1)}';
    }

    return this;
  }

  // Parse string sang double (trả về default value thay vì throw lỗi)
  double parseDouble([double defaultValue = 0.0]) {
    return double.tryParse(replaceAll(RegExp(r'[^0-9\.]'), '')) ?? defaultValue;
  }

  String hideSomeString({@required int startIndex, @required int number}) {
    var hideSimple = "";
    for (int i = 0; i < number; i++) {
      hideSimple += "*";
    }
    return this.replaceRange(startIndex, number + startIndex, hideSimple);
  }

  bool isStringNullOrEmpty() {
    return this == null || this.isEmpty;
  }
}

extension intX on int {
  bool toBool() {
    return (this == 0) ? false : true;
  }
}