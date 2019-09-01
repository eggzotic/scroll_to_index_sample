# scroll_to_index_sample

A new Flutter project.

## Getting Started

Demonstrate IndexedScrollController, which leverages the scroll_to_index package from the Quire team - located at https://pub.dev/packages/scroll_to_index
- copes with variable-height-rows (vertical) / variable-width-columns (horizontal)
- can be used with StatelessWidgets only, if you prefer (as I do).

To use IndexedScrollController:

- create an IndexedScrollController, e.g. in the builder of a Provider (as-in this example app)
  - optionally include "currentIndexCallBack" to allow the value of the currently "1st-visible-on-screen" item to be passed up the tree
- create your data-source iterable
- create your List<Widget> items from your data-source
- pass these items into IndexedScrollController.setItems
  - where they will be "wrapped" with AutoScrollTag
- create your ListView, with:
  - controller: indexedController.controller,
  - children: indexedController.items,

Scrolling can be performed:
- programmatically via these methods of IndexedScrollController:
  - scrollToBeginning()
  - scrollToEnd()
  - scrollForwardBy(...)
  - scrollBackBy(...)
  - scrollToIndex(...)
- manually via the user's finger, and the model will always track the currently visible-at-the-beginning row
  - so "scroll back/forward by X rows" works any time


Richard Shepherd
2019
