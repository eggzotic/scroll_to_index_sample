# scroll_to_index_sample

A new Flutter project.

## Getting Started

Demonstrate the scroll_to_index package from the Quire team - located at https://pub.dev/packages/scroll_to_index
- includes variable-height rows
- StatelessWidgets only
- scrolling can be performed:
  - programmatically via AutoScrollController.scrollToIndex
  - manually via the user's finger, and the model will be updated with the currently visible-at-the-top row
    - so "scroll back/forward by X rows" works any time"
    - however the geometry reported by ScrollEndNotification.context is not always accurate and can result in inaccuracy by +/- 1 index.
    - Presumably this is some kind of timing/async issue, where the notification may be firing before the scroll is really finished?
- this is wrapped up in the ScrollIndexController model - which includes an "itemIsVisible" method to determine whether a given list item is on-screen

Richard Shepherd
2019
