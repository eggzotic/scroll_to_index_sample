import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
//
import 'indexed_scroll_controller.dart';
import 'my_data_source.dart';

//
class HorizontalListView extends StatelessWidget {
  //
  HorizontalListView({
    Key key,
  }) : super(key: key);
  //
  final _alphabet = 'abcdefghijklmnopqrstuvwxyz';
  String _lineOfText(int width) {
    return _alphabet.substring(0, width * 2);
  }

  //
  Widget _horizontalListRowContent(int index, {TextStyle textStyle}) {
    return Card(
      color: Colors.blue[300],
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              index.toString(),
              style: textStyle,
            ),
          ),
          Text(
            _lineOfText(5 + index % 7),
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('HorizontalListView re-build');
    final indexedController = Provider.of<IndexedScrollController>(context);
    final myDataSource = Provider.of<MyDataSource>(context);
    //
    // the Widget form of your data
    final listItems = myDataSource.data.map((data) {
      return Dismissible(
        key: ValueKey('Column $data'),
        child: _horizontalListRowContent(
          data,
          textStyle: Theme.of(context).textTheme.title.copyWith(color: Colors.white),
        ),
        onDismissed: (direction) {
          myDataSource.removeValue(data);
        },
        direction: DismissDirection.down,
        background: Container(
          color: Colors.red,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
          ),
          alignment: Alignment.topCenter,
        ),      );
    }).toList();
    //
    // pass it to your IndexedScrollController
    indexedController.setItems(listItems);
    //
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            RaisedButton(
              child: Padding(padding: const EdgeInsets.all(8.0), child: Text('Start')),
              onPressed: () => indexedController.scrollToBeginning(),
            ),
            RaisedButton(
              child: Padding(padding: const EdgeInsets.all(8.0), child: Text('-9')),
              onPressed: () => indexedController.scrollBackBy(items: 9),
            ),
            RaisedButton(
              child: Padding(padding: const EdgeInsets.all(8.0), child: Text('+6')),
              onPressed: () => indexedController.scrollForwardBy(items: 6),
            ),
            RaisedButton(
              child: Padding(padding: const EdgeInsets.all(8.0), child: Text('End')),
              onPressed: () => indexedController.scrollToEnd(),
            ),
          ],
        ),
        Expanded(
          child: ListView(
            scrollDirection: Axis.horizontal,
            // use the IndexedScrollController to provide the ScrollController and items
            controller: indexedController.controller,
            children: indexedController.items,
          ),
        ),
      ],
    );
  }
}
