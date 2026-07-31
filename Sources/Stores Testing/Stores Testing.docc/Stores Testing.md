# ``Stores_Testing``

Asserting exhaustively against a running store.

## Overview

Exhaustive here means two enforced things. Every step states the whole view the store must have afterwards, so a change nobody asserted fails rather than passes quietly. And finishing asserts that no work is still in flight, so an effect nobody accounted for cannot outlive the test that started it.

What is asserted is the derived view rather than the state. Requiring `Equatable` state puts a conformance on every feature for the benefit of tests, drags every stored value into it, and still reports only that two large values differ. A view is derived, named field by field, and redactable — which is where the fields that legitimately vary run to run are dealt with, once.

## Topics

### Testing a store

- ``Store/Test``
- ``Store/Test/Runtime``
- ``Store/Test/Failure``
