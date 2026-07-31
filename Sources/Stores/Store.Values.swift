public import Store_Reduction_Primitives

extension Store {
    /// Values a feature offers, addressed by the key that names each one.
    ///
    /// A key is a type, so what is stored here is checked at compile time at every
    /// call site that reads or writes it, and matched at runtime only by the key
    /// type's identity — no strings, no reflection over the value.
    ///
    /// Entries are held in the order they were supplied and read back in that
    /// order. A feature supplies a handful of values, not a table of them, which is
    /// why this is a flat ordered sequence rather than a keyed map: there is no
    /// lookup cost worth a hash for, and insertion order is the only iteration
    /// order anyone can predict.
    ///
    /// ## Example
    ///
    /// ```swift
    /// enum Theme: Store.Key.Protocol {
    ///     static var initial: Palette { .system }
    /// }
    ///
    /// var values = Store.Values()
    /// values.set(Theme.self, to: .dark)
    /// values.value(for: Theme.self)  // .dark
    /// ```
    public struct Values: Sendable {
        var entries: [Store.Values.Entry]

        /// Creates an empty set of values.
        public init() {
            self.entries = []
        }
    }
}

// MARK: - Access

extension Store.Values {
    /// Whether nothing has been supplied.
    public var isEmpty: Bool {
        entries.isEmpty
    }

    /// The value supplied for `key`, or `nil` if none was.
    ///
    /// - Parameter key: The key naming the value.
    public func value<K: Store.Key.`Protocol`>(for key: K.Type) -> K.Value? {
        let identity = ObjectIdentifier(key)
        for entry in entries where entry.identity == identity {
            return entry.value as? K.Value
        }
        return nil
    }

    /// Supplies `value` for `key`, replacing any value already supplied for it.
    ///
    /// - Parameters:
    ///   - key: The key naming the value.
    ///   - value: The value to supply.
    public mutating func set<K: Store.Key.`Protocol`>(_ key: K.Type, to value: K.Value) {
        let identity = ObjectIdentifier(key)
        let entry = Store.Values.Entry(identity: identity, value: value)
        for index in entries.indices where entries[index].identity == identity {
            entries[index] = entry
            return
        }
        entries.append(entry)
    }

    /// Withdraws whatever was supplied for `key`.
    ///
    /// - Parameter key: The key naming the value.
    public mutating func clear<K: Store.Key.`Protocol`>(_ key: K.Type) {
        let identity = ObjectIdentifier(key)
        entries.removeAll { $0.identity == identity }
    }
}
