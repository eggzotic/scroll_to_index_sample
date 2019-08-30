import 'package:flutter/widgets.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

//
// Richard Shepherd, 2019
//
// Provide item-index-tracking & control for a ListView
//  using AutoScrollController for the scroll-control part
//
class ScrollIndexController {
  //
  ScrollIndexController({
    @required this.itemCount,
    this.preferredPosition = AutoScrollPosition.begin,
    this.initialIndex = 0,
  }) {
    setCurrent(index: initialIndex);
  }
  //
  final int initialIndex;
  final int itemCount;
  AutoScrollPosition preferredPosition;
  //
  final int _minIndex = 0;
  //
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;
  //
  final _controller = AutoScrollController();
  //
  // this getter is required e.g. to pass the controller into ListView constructor
  AutoScrollController get controller => _controller;

  //
  // scroll = false -> when setting the value after a manual (user's finger-based) scroll
  // scroll = true (default) -> when you want the scrollToIndex to fire
  //
  void setCurrent({@required int index, bool scroll = true}) {
    _currentIndex = index;
    // out-of-bounds corrections
    if (_currentIndex > itemCount) _currentIndex = itemCount - 1;
    if (_currentIndex < _minIndex) _currentIndex = _minIndex;
    print('DEBUG: currentIndex = $_currentIndex');
    if (!scroll) return;
    _controller.scrollToIndex(_currentIndex, preferPosition: preferredPosition);
  }

  void scrollForwardBy({@required int items}) => setCurrent(index: _currentIndex + items);

  void scrollBackBy({@required int items}) => setCurrent(index: _currentIndex - items);

  //
  bool itemIsVisible({
    @required Widget item,
    // padding e.g. if we use a Card which adds some *visual* space between
    //  consecutive items even though the Cards are adjacent
    double padding = 4.0,
  }) {
    final container = _controller.position.context.notificationContext.findRenderObject() as RenderBox;
    if (container == null) return false;
    //
    final vertical = _controller.position.axis == Axis.vertical;
    final containerEnd = vertical ? container.size.height : container.size.width;
    final itemBox = (item.key as GlobalKey).currentContext?.findRenderObject() as RenderBox;
    if (itemBox == null) return false;
    final itemPosition = itemBox.localToGlobal(Offset(0, 0), ancestor: container);
    final itemBegin = (vertical ? itemPosition.dy : itemPosition.dx) + padding;
    final itemEnd = (vertical ? (itemPosition.dy + itemBox.size.height) : (itemPosition.dx + itemBox.size.width)) - padding;
    //
    // what determines whether the item is on the screen?
    // Either:
    //  1. the beginning of the item is between the top & bottom of the container, or
    //  2. the end of the item is between the top & bottom of the container, or
    //  3. the beginning of the item is before the beginning of the container *and*
    //      the end of the item is after the end of the container
    //      this last case covers the case where the item is larger than the screen-width/height
    //
    return (itemBegin >= 0 && itemBegin < containerEnd) ||
        (itemEnd >= 0 && itemEnd <= containerEnd) ||
        (itemBegin < 0 && itemEnd >= containerEnd);
  }
}
