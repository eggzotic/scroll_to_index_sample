import 'package:flutter/widgets.dart';

//
// Sample data-model to manage a counter that might be used as an index to a ListView
//
class MyModel with ChangeNotifier {
  final int maxRows = 100;
  final int minRows = 0;
  //
  int _currentRow = 0;
  int get currentRow => _currentRow;
  //
  void setCurrentRow(int newValue) {
    _currentRow = newValue;
    if (_currentRow > maxRows) _currentRow = maxRows - 1;
    if (_currentRow < minRows) _currentRow = minRows;
    notifyListeners();
    print('currentRow = $_currentRow');
  }

  void incCurrentRow(int inc) {
    setCurrentRow(_currentRow + inc);
  }

  void decCurrentRow(int dec) {
    setCurrentRow(_currentRow - dec);
  }
}