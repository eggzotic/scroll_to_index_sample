import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
//
import 'indexed_scroll_controller.dart';

//
class VerticalListView extends StatelessWidget {
  //
  VerticalListView({
    Key key,
  }) : super(key: key);
  //
  Widget _verticalListRowContent(int index, {TextStyle textStyle}) {
    return Card(
      color: Colors.blue[100],
      child: ListTile(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'This is row $index',
              style: textStyle,
            ),
            ..._linesOfText(index % 38).map((string) => Text(string)).toList(),
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
    final indexedController = Provider.of<IndexedScrollController>(context);
    //
    indexedController.setItems(
      List.generate(
        100,
        (index) => _verticalListRowContent(
          index,
          textStyle: Theme.of(context).textTheme.title,
        ),
      ),
    );
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
            controller: indexedController.controller,
            children: indexedController.items,
          ),
        ),
      ],
    );
  }
}
