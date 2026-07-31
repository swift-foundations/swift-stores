internal import Deque_Primitives
internal import Queue_Primitive

/// A first-in, first-out buffer of values waiting their turn.
///
/// Sends that arrive while a send is already being processed are buffered here
/// rather than reentered, which is what keeps one action's reduction from
/// observing a half-applied later one. Values go in at the back and come out at
/// the front and are never indexed, mutated in place, or reordered — the
/// double-ended queue is the family whose access pattern that is, and the only
/// one.
struct Mailbox<Element: Sendable>: ~Copyable {
    private var storage: Queue<Element>.DoubleEnded

    init() {
        self.storage = Queue<Element>.DoubleEnded()
    }
}

extension Mailbox {
    /// Whether nothing is waiting.
    var isEmpty: Bool {
        storage.isEmpty
    }

    /// Adds `element` at the back.
    mutating func post(_ element: consuming Element) {
        storage.push(element, to: .back)
    }

    /// Removes and returns the element at the front, or `nil` when empty.
    mutating func next() -> Element? {
        storage.pop(from: .front)
    }
}
