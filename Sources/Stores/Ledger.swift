internal import Dictionary_Ordered_Primitives
internal import Dictionary_Primitive
internal import Hash_Primitives

/// An insertion-ordered table from a ticket to a value.
///
/// Ordered rather than plain, and the reason is a property rather than a taste:
/// the testing product reports what a runtime still has in flight, and that report
/// has to read the same on every run of the same test. Iteration order is
/// therefore an observable law here, which is exactly what selects the ordered
/// sibling over the plain one.
struct Ledger<Value: Sendable>: ~Copyable {
    /// A ticket identifying one row for as long as it is held.
    typealias Ticket = UInt64

    private var storage: Dictionary_Primitive.Dictionary<Ticket, Value>.Ordered

    init() {
        self.storage = Dictionary_Primitive.Dictionary<Ticket, Value>.Ordered()
    }
}

extension Ledger {
    /// Whether the table holds nothing.
    var isEmpty: Bool {
        storage.isEmpty
    }

    /// Whether `ticket` names a row.
    func holds(_ ticket: Ticket) -> Bool {
        storage.contains(key: ticket)
    }

    /// Adds a row, replacing any row already under `ticket`.
    mutating func record(_ value: consuming Value, as ticket: Ticket) {
        storage.insert(key: ticket, value: value)
    }

    /// Removes the row under `ticket` and returns its value.
    @discardableResult
    mutating func discard(_ ticket: Ticket) -> Value? {
        storage.removeValue(forKey: ticket)
    }

    /// The tickets held, oldest first.
    var tickets: [Ticket] {
        var result: [Ticket] = []
        storage.forEach { ticket, _ in result.append(ticket) }
        return result
    }

    /// Applies `body` to every row, oldest first.
    func forEach(_ body: (Ticket, Value) -> Void) {
        storage.forEach { ticket, value in body(ticket, value) }
    }

    /// Removes every row.
    mutating func discardAll() {
        storage.removeAll()
    }
}
