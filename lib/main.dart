import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
//
import 'scroll_index_controller.dart';

//
// Richard Shepherd, 2019
//
// Sample app to demonstrate the function of scroll_to_index package
// - includes variable-height rows
// - StatelessWidgets only
// - is aware of the current scroll position (by item-index!) even after manual scrolling
// this approach is good for up to maybe ~500 items
//   - may not scale up into the 1000's and beyond
//   - but still this covers a lot of potential app-reqs
//

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scroll To Row Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Provider(
        builder: (context) => ScrollIndexController(itemCount: 300),
        child: StatelessHomePage(title: 'Scroll To Row'),
      ),
    );
  }
}

class StatelessHomePage extends StatelessWidget {
  //
  final String title;
  StatelessHomePage({Key key, this.title = ''}) : super(key: key);
  //
  Widget _getRow(
    int index, {
    @required AutoScrollController controller,
    @required BuildContext context,
  }) {
    return _wrapScrollTag(
      controller: controller,
      index: index,
      child: Card(
        color: Colors.blue[100],
        child: ListTile(
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'This is row $index',
                style: Theme.of(context).textTheme.title,
              ),
              ..._linesOfText(index % 38).map((string) => Text(string)).toList(),
            ],
          ),
        ),
      ),
    );
  }

  // generate a list of strings, to be used as "lines", to give us varying sizes for the rows
  List<String> _linesOfText(int lines) => List.generate(lines, (index) => "This is line number $index");

  Widget _wrapScrollTag({
    int index,
    Widget child,
    @required AutoScrollController controller,
  }) =>
      AutoScrollTag(
        // use GlobalKey, for later access to its currentContext and RenderObject to
        //  locate it on the screen in the ListView coords
        key: GlobalKey(),
        controller: controller,
        index: index,
        child: child,
      );
  //
  @override
  Widget build(BuildContext context) {
    final indexController = Provider.of<ScrollIndexController>(context);
    //
    // create these items ahead of time so we can
    // 1. pass these to the ListView as children and
    // 2. scan to find which item is now at the top after scrolling
    //
    final List<Widget> items = List.generate(
      indexController.itemCount,
      (index) => _getRow(
        index,
        controller: indexController.controller,
        context: context,
      ),
    );
    //
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[
          //
          // some buttons to perform scroll back/forward by some arbitrary number of items
          //  remember to scroll up/down with you finger also to validate that subsequent
          //  use of these buttons takes into account the currently visible items
          InkWell(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('-7', style: TextStyle(color: Colors.white)),
            ),
            onTap: () => indexController.scrollBackBy(items: 7),
          ),
          InkWell(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('-1', style: TextStyle(color: Colors.white)),
            ),
            onTap: () => indexController.scrollBackBy(items: 1),
          ),
          InkWell(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('+1', style: TextStyle(color: Colors.white)),
            ),
            onTap: () => indexController.scrollForwardBy(items: 1),
          ),
          InkWell(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('+9', style: TextStyle(color: Colors.white)),
            ),
            onTap: () => indexController.scrollForwardBy(items: 9),
          ),
        ],
      ),
      body: NotificationListener(
        child: ListView(
          controller: indexController.controller,
          children: items,
        ),
        onNotification: (ScrollNotification notification) {
          if (!(notification is ScrollEndNotification)) return false;
          //
          final firstVisibleIndex = items.indexWhere((item) => indexController.itemIsVisible(item: item));
          indexController.setCurrent(index: firstVisibleIndex, scroll: false);
          // false --> keep passing the notification up the tree, in case you
          //   have other widgets wanting to respond to this
          return false;
        },
      ),
    );
  }
}
