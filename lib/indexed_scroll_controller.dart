import 'package:flutter/widgets.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

//
// Richard Shepherd, 2019
//
// Provide item-index-tracking & control for a ListView
//  using AutoScrollController for the scroll-control part
//
class IndexedScrollController {
  //
  IndexedScrollController({
    List<Widget> items,
    this.preferredPosition = AutoScrollPosition.begin,
    this.initialIndex = 0,
    this.statusCallBack,
  }) {
    if (items != null) _setCurrent(index: initialIndex);
    _wrappedItems = items?.map((item) => _wrapScrollTag(child: item, index: items.indexOf(item)))?.toList();
    //
    // add a listener that will essentially check whether a ScrollPosition is attached and, if so,
    //  do a one-time add-listener on the isScrollingNotifier property
    //
    _controller.addListener(() {
      if (!_controller.hasClients) return;
      // ensure this addListener is run only once
      if (_positionListenerSet) return;
      //
      // the purpose of this listener is to detect when scrolling ends
      //  it's an alternative to using a NotificationListener on the ListView widget
      //  it allows all this motion detection to be hidden away from the user's UI code
      //
      _controller.position.isScrollingNotifier.addListener(() {
        if (_controller.position.isScrollingNotifier.value) return;
        // so scrolling has just stopped - time to update the 1st-on-screen index
        findFirstOnScreenIndex();
      });
      _positionListenerSet = true;
    });
  }

  bool _positionListenerSet = false;
  //
  // this callback allows the value of _currentIndex to be propagated up the tree, even higher than
  //  where this IndexedScrollController may have been instantiated
  //
  final void Function({@required int currentIndex}) statusCallBack;

  //
  List<Widget> _wrappedItems;
  List<Widget> get items => _wrappedItems;
  //
  final int initialIndex;
  int get itemCount => _wrappedItems?.length ?? 0;
  AutoScrollPosition preferredPosition;
  //
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;
  //
  final _controller = AutoScrollController();
  //
  // this getter is required e.g. to pass the controller into ListView constructor
  AutoScrollController get controller => _controller;

  // wrap up the items with AutoScrollTag
  Widget _wrapScrollTag({
    @required int index,
    @required Widget child,
  }) =>
      AutoScrollTag(
        key: GlobalKey(),
        controller: _controller,
        index: index,
        child: child,
      );

  void setItems(List<Widget> items) {
    _wrappedItems = items.map((item) => _wrapScrollTag(child: item, index: items.indexOf(item))).toList();
  }

  //
  // scroll = false -> when setting the value after a manual (user's finger-based) scroll
  // scroll = true (default) -> when you want the scrollToIndex to fire
  //
  void _setCurrent({@required int index, bool scroll = true}) {
    // avoid unnecessary updates
    if (index == _currentIndex) return;
    _currentIndex = index;
    // out-of-range corrections
    if (_currentIndex > itemCount) _currentIndex = itemCount - 1;
    if (_currentIndex < 0) _currentIndex = 0;
    // print('_currentIndex = ' + _currentIndex.toString());
    if (statusCallBack != null) statusCallBack(currentIndex: _currentIndex);
    if (!scroll) return;
    _controller.scrollToIndex(_currentIndex, preferPosition: preferredPosition);
  }

  void scrollToBeginning() => _setCurrent(index: 0);
  void scrollToEnd() => _setCurrent(index: items.length - 1);

  void scrollForwardBy({@required int items}) => _setCurrent(index: _currentIndex + items);

  void scrollBackBy({@required int items}) => _setCurrent(index: _currentIndex - items);

  void scrollToIndex({@required int index}) => _setCurrent(index: index);

  //
  void findFirstOnScreenIndex() {
    final firstVisibleIndex = _wrappedItems.indexWhere((item) => itemIsVisible(item: item));
    _setCurrent(index: firstVisibleIndex, scroll: false);
  }

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
    // Criteria for "the item is on-screen"
    // Either:
    //  1. the beginning of the item is between the beginning & end of the container, or
    //  2. the end of the item is between the beginning & end of the container, or
    //  3. the beginning of the item is before the beginning of the container *and*
    //      the end of the item is after the end of the container
    //      this last case covers the case where the item is larger than the screen-width/height
    //
    return (itemBegin >= 0 && itemBegin < containerEnd) ||
        (itemEnd >= 0 && itemEnd <= containerEnd) ||
        (itemBegin < 0 && itemEnd >= containerEnd);
  }
}
