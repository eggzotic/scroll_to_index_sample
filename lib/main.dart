import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
//
import 'my_model.dart';

//
// Richard Shepherd, 2019
//
// Sample app to demonstrate the function of scroll_to_index package
// - includes variable-height rows
// - StatelessWidgets only
//

void main() => runApp(
      ChangeNotifierProvider(
        builder: (context) => MyModel(),
        child: MyApp(),
      ),
    );

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scroll To Row Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ListenableProvider(
        builder: (context) => AutoScrollController(),
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
              ..._stringContents(index % 5).map((string) => Text(string)).toList(),
            ],
          ),
        ),
      ),
    );
  }

  // generate a list of strings, to be used as "lines", to give us varying sizes for the rows
  List<String> _stringContents(int lines) => List.generate(lines, (index) => "This is line number $index");

  Widget _wrapScrollTag({
    int index,
    Widget child,
    @required AutoScrollController controller,
  }) =>
      AutoScrollTag(
        // use GlobalKey so we can later access the currentContext and the RenderObject to locate it on the screen
        key: GlobalKey(),
        controller: controller,
        index: index,
        child: child,
        highlightColor: Colors.black.withOpacity(0.1),
      );
  //
  @override
  Widget build(BuildContext context) {
    final myModel = Provider.of<MyModel>(context);
    final controller = Provider.of<AutoScrollController>(context);
    //
    // create the ListView children ahead of time since we need to access these
    //  both as the ListView children and when scanning to find which item is now at the top afte scrolling
    //
    final List<Widget> rowItems = List.generate(
      myModel.maxRows,
      (index) => _getRow(index, controller: controller, context: context),
    );
    //
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[
          InkWell(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text('-13', style: TextStyle(color: Colors.white)),
            ),
            onTap: () async {
              myModel.decCurrentRow(13);
              await controller.scrollToIndex(myModel.currentRow, preferPosition: AutoScrollPosition.begin);
            },
          ),
          InkWell(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text('+27', style: TextStyle(color: Colors.white)),
            ),
            onTap: () async {
              myModel.incCurrentRow(27);
              await controller.scrollToIndex(myModel.currentRow, preferPosition: AutoScrollPosition.begin);
            },
          ),
        ],
      ),
      body: NotificationListener(
        child: ListView(
          controller: controller,
          children: rowItems,
        ),
        onNotification: (ScrollNotification notification) {
          if (notification is ScrollEndNotification) {
            final listViewBox = notification.context?.findRenderObject() as RenderBox;
            final listViewBot = listViewBox.size.height;

            // padding for cases like where we use a Card which adds some visual whitespace between consecutive Cards
            //  even though the RenderBox of each is adjacent according to the coordinates from localToGlobal
            final double padding = 4.0;
            //
            for (int index = 0; index < rowItems.length; index++) {
              final itemBox = (rowItems[index].key as GlobalKey).currentContext?.findRenderObject() as RenderBox;
              if (itemBox != null) {
                final itemPosition = itemBox.localToGlobal(Offset(0, 0), ancestor: listViewBox);
                final itemTop = itemPosition.dy + padding;
                final itemBot = itemPosition.dy + itemBox.size.height - padding;
                if ((itemTop >= 0 && itemTop < listViewBot) || (itemBot >= 0 && itemBot <= listViewBot)) {
                  myModel.setCurrentRow(index, notify: false);
                  break;
                }
              }
            }
          }
          return false; // false --> keep passing the notification up the tree
        },
      ),
      // cannot do ListView.builder - must use plain ListView(...) with explicit children,
      //  for the controller.scrollToIndex to work
      //
      // body: ListView.builder(
      //   itemCount: myModel.maxRows,
      //   itemBuilder: (context, index) {
      //     return _getRow(index, controller: controller, context: context);
      //   },
      // ),
    );
  }
}
