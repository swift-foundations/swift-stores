public import Store_Reduction_Primitives

extension Store.Feature {
    /// What a runtime records about one mounted feature.
    ///
    /// Everything here is what the feature offers to the rest of the tree: the
    /// values it makes available downward, what it contributes to aggregations
    /// gathered upward, the events it is willing to be offered as they bubble
    /// through it, and what to run when it goes away.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let detail = try runtime.mount("detail", under: root) { mount in
    ///     mount.supply(Theme.self, .dark)
    ///     mount.contribute(Warnings.self, [.unsaved])
    ///     mount.on(Saved.self) { _ in .consumed }
    ///     mount.onDismount { subscription.cancel() }
    /// }
    /// ```
    public struct Mount: Sendable {
        /// Values this feature makes available to everything under it.
        var values: Store.Values

        /// What this feature contributes to aggregations gathered from above.
        var contributions: Store.Values

        /// Handlers for events bubbling up through this feature.
        var receivers: [Store.Event.Receiver]

        /// Run, in reverse registration order, when this feature is dismounted.
        var teardown: [@Sendable () -> Void]

        /// Renders this feature's own state, when it has state of its own.
        ///
        /// A feature that is only a position in the tree renders nothing and its
        /// descendants render in its place. A spawned subtree sets this to its own
        /// runtime's view, which is what makes an assertion at the root see the
        /// whole tree rather than only the state the root happens to hold.
        var render: (@Sendable () -> Store.View.Node)?

        /// Creates a mount that offers nothing.
        public init() {
            self.values = Store.Values()
            self.contributions = Store.Values()
            self.receivers = []
            self.teardown = []
            self.render = nil
        }
    }
}

// MARK: - Offering

extension Store.Feature.Mount {
    /// Makes `value` available under `key` to everything mounted under this feature.
    ///
    /// - Parameters:
    ///   - key: The key naming the value.
    ///   - value: The value to make available.
    public mutating func supply<K: Store.Key.`Protocol`>(_ key: K.Type, _ value: K.Value) {
        values.set(key, to: value)
    }

    /// Contributes `value` to the aggregation named by `key`.
    ///
    /// - Parameters:
    ///   - key: The aggregate key naming the contribution.
    ///   - value: This feature's contribution.
    public mutating func contribute<K: Store.Key.Aggregate>(_ key: K.Type, _ value: K.Value) {
        contributions.set(key, to: value)
    }

    /// Offers this feature events of type `type` as they bubble through it.
    ///
    /// - Parameters:
    ///   - type: The event type to be offered.
    ///   - handle: Decides what happens to an offered event.
    public mutating func on<E: Sendable>(
        _ type: E.Type,
        _ handle: @escaping @Sendable (E) -> Store.Event.Disposition
    ) {
        receivers.append(.of(type, handle))
    }

    /// Runs `body` when this feature is dismounted.
    ///
    /// - Parameter body: The work to run at dismount.
    public mutating func onDismount(_ body: @escaping @Sendable () -> Void) {
        teardown.append(body)
    }

    /// Renders this feature's own state with `body` when a view is taken.
    ///
    /// - Parameter body: Produces this feature's rendered state.
    public mutating func renders(_ body: @escaping @Sendable () -> Store.View.Node) {
        render = body
    }
}
