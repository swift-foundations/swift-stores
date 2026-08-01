public import Algebra_Monoid_Primitives
public import Store_Reduction_Primitives

// MARK: - Downward

extension Store.Runtime {
    /// The value in force for `key` at `handle`.
    ///
    /// Resolution walks outward from the feature itself through its ancestors and
    /// stops at the first that supplied one; with none supplied anywhere, the key's
    /// own initial value is the answer. A feature therefore reads a value without
    /// knowing which ancestor supplied it, or whether any did.
    ///
    /// A downward command needs nothing else — a command is a value whose type is a
    /// function, and the key's initial value doubles as the neutral behaviour, which
    /// is what lets a feature run before anything supplies the real one.
    ///
    /// - Parameters:
    ///   - key: The key naming the value.
    ///   - handle: The feature reading it.
    public func value<K: Store.Key.`Protocol`>(
        _ key: K.Type,
        at handle: Store.Feature.Handle
    ) -> K.Value {
        if let mount = _features.node(at: handle.registry), let value = mount.values.value(for: key) {
            return value
        }
        for ancestor in _features.ancestors(of: handle.registry) {
            if let mount = _features.node(at: ancestor), let value = mount.values.value(for: key) {
                return value
            }
        }
        return K.initial
    }

    /// Supplies `value` under `key` from `handle` downward, replacing any value it
    /// already supplied.
    ///
    /// - Parameters:
    ///   - key: The key naming the value.
    ///   - value: The value to supply.
    ///   - handle: The feature supplying it.
    /// - Throws: ``Store/Error/notMounted`` if the handle no longer names a feature.
    public func supply<K: Store.Key.`Protocol`>(
        _ key: K.Type,
        _ value: K.Value,
        at handle: Store.Feature.Handle
    ) throws(Store.Error) {
        let applied = _features.update(at: handle.registry) { mount in
            mount.values.set(key, to: value)
        }
        guard applied != nil else { throw .notMounted }
    }
}

// MARK: - Upward

extension Store.Runtime {
    /// Everything contributed to `key` by `handle` and the features under it,
    /// combined under the key's own monoid.
    ///
    /// Contributions are gathered breadth-first, so the order they combine in is the
    /// same on every run. The monoid is what makes that order not matter to the
    /// answer — and supplying a monoid rather than a bare combining function is also
    /// what makes the no-contributors case well defined instead of a special case.
    ///
    /// - Parameters:
    ///   - key: The aggregate key naming the contributions.
    ///   - handle: The feature to gather from, inclusive.
    public func aggregate<K: Store.Key.Aggregate>(
        _ key: K.Type,
        from handle: Store.Feature.Handle
    ) -> K.Value {
        let monoid: Algebra.Monoid<K.Value> = K.aggregation
        var result = monoid.identity
        for member in _features.subtree(from: handle.registry) {
            guard
                let mount = _features.node(at: member),
                let contribution = mount.contributions.value(for: key)
            else { continue }
            result = monoid.combining(result, contribution)
        }
        return result
    }

    /// Offers `event` to each ancestor of `handle` in turn, nearest first.
    ///
    /// An ancestor may ignore the event and let it keep rising, consume it and stop
    /// it, or transform it — after which the replacement is what the remaining
    /// ancestors are offered. The feature raising the event names no recipient,
    /// which is what lets it be mounted anywhere.
    ///
    /// - Parameters:
    ///   - event: The event to raise.
    ///   - handle: The feature raising it.
    /// - Returns: Whether some ancestor consumed it.
    @discardableResult
    public func raise<E: Sendable>(_ event: E, from handle: Store.Feature.Handle) -> Bool {
        // REASON: the box for key-addressed values and bubbling events. Heterogeneous storage has
        // REASON: no generic form; the concrete type is recovered by a checked cast at a single
        // REASON: typed boundary, and the public surface stays generic over the key or event type.
        var current: any Sendable = event  // swiftlint:disable:this no_any_protocol_existential

        for ancestor in _features.ancestors(of: handle.registry) {
            guard let mount = _features.node(at: ancestor) else { continue }
            for receiver in mount.receivers {
                switch receiver.accept(current) {
                case .ignored:
                    continue

                case .consumed:
                    return true

                case .transformed(let replacement):
                    current = replacement
                }
            }
        }

        return false
    }
}
