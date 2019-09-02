import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
//
import 'indexed_scroll_controller.dart';
import 'my_data_source.dart';

//
class VerticalListView extends StatelessWidget {
  //
  VerticalListView({
    Key key,
  }) : super(key: key);
  //
  // sample row-widget producer
  Widget _verticalListRowContent(
    int data, {
    TextStyle textStyle,
  }) {
    return Card(
      color: Colors.blue[100],
      child: ListTile(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'This is row $data',
              style: textStyle,
            ),
            // 38: an arbitrary large-enough number to produce some large rows (taller than a full-screen)
            ..._linesOfText(data % 38).map((string) => Text(string)).toList(),
          ],
        ),
      ),
    );
  }

  // generate a list of strings, to be used as "lines", to give us varying sizes for the rows
  List<String> _linesOfText(int lines) => List.generate(lines, (index) => "This is line number $index");
  //
  @override
  Widget build(BuildContext context) {
    print('VerticalListView re-build');
    final indexedController = Provider.of<IndexedScrollController>(context);
    final myDataSource = Provider.of<MyDataSource>(context);
    //
    // the Widget representation of your data
    final listItems = myDataSource.data.map((data) {
      return Dismissible(
        key: ValueKey('Row $data'),
        child: _verticalListRowContent(
          data,
          textStyle: Theme.of(context).textTheme.title,
        ),
        onDismissed: (direction) {
          myDataSource.removeValue(data);
        },
        direction: DismissDirection.endToStart,
        background: Container(
          color: Colors.red,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
          ),
          alignment: Alignment.centerRight,
        ),
      );
    }).toList();
    //
    // pass your Widget Items to the IndexedScrollController
    indexedController.setItems(listItems);
    //
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            RaisedButton(
              child: Padding(padding: const EdgeInsets.all(8.0), child: Text('Top')),
              onPressed: () => indexedController.scrollToBeginning(),
            ),
            RaisedButton(
              child: Padding(padding: const EdgeInsets.all(8.0), child: Text('-7')),
              onPressed: () => indexedController.scrollBackBy(items: 7),
            ),
            RaisedButton(
              child: Padding(padding: const EdgeInsets.all(8.0), child: Text('+3')),
              onPressed: () => indexedController.scrollForwardBy(items: 3),
            ),
            RaisedButton(
              child: Padding(padding: const EdgeInsets.all(8.0), child: Text('Bottom')),
              onPressed: () => indexedController.scrollToEnd(),
            ),
          ],
        ),
        Expanded(
          child: ListView(
            scrollDirection: Axis.vertical,
            // use the IndexedScrollController to provide the ScrollController and items
            controller: indexedController.controller,
            children: indexedController.items,
          ),
        ),
      ],
    );
  }
}
