import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//
import 'horizontal_list_view.dart';
import 'vertical_list_view.dart';
import 'indexed_scroll_controller.dart';

//
// Richard Shepherd, 2019
//
// Sample app to demonstrate the function of IndexedScrollController, which
//  leverages scroll_to_index package
// - includes variable-height rows
// - StatelessWidgets only
// - is aware of the current scroll position (by item-index!) even after manual scrolling
// this approach is good for up to maybe ~500 items (depending on item-widget size)
//   - may not scale up into the 1000's and beyond
//   - but still, that covers a lot of potential app-reqs
//

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Indexed Scroll Controller',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChangeNotifierProvider(
        builder: (context) => CurrentIndices(),
        child: HomePage(title: 'Indexed Scroll Controller'),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final String title;
  //
  HomePage({Key key, this.title = ''}) : super(key: key);
  //
  @override
  Widget build(BuildContext context) {
    final currentIndices = Provider.of<CurrentIndices>(context, listen: false);
    // print('HomePage re-build');
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Consumer<CurrentIndices>(
            builder: (_, scrollIndex, __) => Text(
              (scrollIndex.horizontal?.toString() ?? '0'),
              style: Theme.of(context).textTheme.title.copyWith(color: Colors.white),
            ),
          ),
        ),
        title: Text(title),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Consumer<CurrentIndices>(
              builder: (_, scrollIndex, __) =>
                  Text((scrollIndex.vertical.toString() ?? '0'), style: Theme.of(context).textTheme.title),
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: ChangeNotifierProvider(
              builder: (context) => IndexedScrollController(
                  currentIndexCallBack: currentIndices.setHorizontal,
                  ),
              child: HorizontalListView(
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: ChangeNotifierProvider(
              builder: (context) => IndexedScrollController(
                  currentIndexCallBack: currentIndices.setVertical,
                  ),
              child: VerticalListView(),
            ),
          ),
        ],
      ),
    );
  }
}

// helper class to hold some scroll-state received from the IndexedScrollController
class CurrentIndices with ChangeNotifier {
  //
  int _horizontal;
  int get horizontal => _horizontal ?? 0;
  //
  int _vertical;
  int get vertical => _vertical ?? 0;
  //
  void setHorizontal(int value) {
    _horizontal = value;
    notifyListeners();
  }

  void setVertical(int value) {
    _vertical = value;
    notifyListeners();
  }
}
