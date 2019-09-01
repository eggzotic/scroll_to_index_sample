import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
//
import 'indexed_scroll_controller.dart';

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
    final indexedController = Provider.of<IndexedScrollController>(context);
    //
    indexedController.setItems(
      List.generate(
        100,
        (index) => _horizontalListRowContent(
          index,
          textStyle: Theme.of(context).textTheme.title.copyWith(color: Colors.white),
        ),
      ),
    );
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
              child: Padding(padding: const EdgeInsets.all(8.0), child: Text('-7')),
              onPressed: () => indexedController.scrollBackBy(items: 7),
            ),
            RaisedButton(
              child: Padding(padding: const EdgeInsets.all(8.0), child: Text('+3')),
              onPressed: () => indexedController.scrollForwardBy(items: 3),
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
            controller: indexedController.controller,
            children: indexedController.items,
          ),
        ),
      ],
    );
  }
}
