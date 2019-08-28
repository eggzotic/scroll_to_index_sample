import 'package:flutter/material.dart';
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
      title: 'Scroll To Index Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ListenableProvider(
        builder: (context) => AutoScrollController(),
        child: StatelessHomePage(title: 'Scroll To Index Demo'),
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

  // generate a list of strings, to be used as "lines"
  List<String> _stringContents(int lines) => List.generate(lines, (index) => "This is line number $index");

  Widget _wrapScrollTag({
    int index,
    Widget child,
    @required AutoScrollController controller,
  }) =>
      AutoScrollTag(
        key: ValueKey(index),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[
          InkWell(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                '-13',
                style: TextStyle(color: Colors.white),
              ),
            ),
            onTap: () async {
              myModel.decCurrentRow(13);
              await controller.scrollToIndex(myModel.currentRow, preferPosition: AutoScrollPosition.begin);
            },
          ),
          InkWell(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                '+7',
                style: TextStyle(color: Colors.white),
              ),
            ),
            onTap: () async {
              myModel.incCurrentRow(7);
              await controller.scrollToIndex(myModel.currentRow, preferPosition: AutoScrollPosition.begin);
            },
          ),
        ],
      ),
      body: ListView(
        controller: controller,
        children: List.generate(myModel.maxRows, (index) => _getRow(index, controller: controller, context: context)).toList(),
      ),
    );
  }
}
