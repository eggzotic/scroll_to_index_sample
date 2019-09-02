//
// dummy data-source
import 'dart:math';

import 'package:flutter/widgets.dart';

class MyDataSource with ChangeNotifier {
  final int inintialDataSize;
  MyDataSource({
    @required this.inintialDataSize,
  }) {
    _myData = List.generate(inintialDataSize, (i) => i);
  }
  List<int> _myData;
  List<int> get data => _myData.map((i) => i).toList();
  int get dataCount => _myData.length;
  //
  bool removeValue(int value) {
    final result = _myData.remove(value);
    notifyListeners();
    return result;
  }

  void insertValue(int value, {int atIndex}) {
    // bounds corrections - forcing it to be in-range
    final indexToInsert = max(min(atIndex ?? _myData.length, _myData.length), 0);
    _myData.insert(indexToInsert, value);
    notifyListeners();
  }
}
