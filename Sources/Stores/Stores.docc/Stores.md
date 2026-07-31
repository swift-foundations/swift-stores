# ``Stores``

An isolation-generic store runtime: state advanced by actions, an explicit feature lifecycle, typed communication between features, and per-subtree runtimes.

## Overview

This package interprets the reduction algebra. The algebra says what an update is and what it may ask for; nothing there runs, schedules, or synchronizes anything. ``Store/Runtime`` is what turns those values into a live store.

Three decisions shape everything else.

**Isolation is inherited, not asserted.** A runtime captures the isolation it was created on and hops back to it whenever running work feeds an action back. Main-actor isolation is therefore what you get by creating one on the main actor, not a property this type hard-codes — and a runtime inside an actor is isolated to that actor on exactly the same terms.

**The feature lifecycle is explicit.** Features are mounted and dismounted at call sites. Nothing is discovered by reflecting over state, and nothing's lifetime is inferred from whether an optional happens to be non-`nil`. The cost of that honesty is that a handle can outlive what it names, so ``Store/Feature/Handle`` is generational: held past a dismount it resolves to nothing rather than to whatever took the position next.

**Execution is composed, not owned.** A runtime owns when work starts and stops, because that follows the lifecycle it owns. How a body is performed belongs to the effect owner and is reached through ``Store/Job``, so changing execution is a handler swap.

## Topics

### The runtime

- ``Store/Runtime``
- ``Store/Scope``

### Features

- ``Store/Feature``
- ``Store/Feature/Handle``
- ``Store/Feature/Mount``

### Communication

- ``Store/Values``
- ``Store/Event``
- ``Store/Event/Disposition``

### Work

- ``Store/Work``
- ``Store/Job``
- ``Store/Send``
- ``Store/Cancellation``

### Views

- ``Store/View``
- ``Store/View/Node``
- ``Store/View/Field``
- ``Store/Redaction``
