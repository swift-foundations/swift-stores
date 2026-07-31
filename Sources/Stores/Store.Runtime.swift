public import Store_Reduction_Primitives
internal import Observations

extension Store {
    /// A live store: state, the reduction that advances it, the features mounted
    /// under it, and the work it has in flight.
    ///
    /// ## Isolation
    ///
    /// A runtime is not `@MainActor`, and that is the substance of the design rather
    /// than an omission. It captures the isolation it was created on and hops back
    /// to exactly that isolation whenever running work feeds an action back, so a
    /// runtime created on the main actor is main-actor-isolated, one created inside
    /// an actor is isolated to that actor, and neither is a special case of the
    /// other. Nothing here assumes a user interface exists.
    ///
    /// ## Reentrancy
    ///
    /// ``send(_:)`` never reenters. An action sent while a reduction is already
    /// running is buffered and reduced after it, so no reduction ever observes state
    /// that a later action has half-applied.
    ///
    /// ## Example
    ///
    /// ```swift
    /// @MainActor
    /// func makeRuntime() -> Store.Runtime<Screen, Screen.Action> {
    ///     Store.Runtime(state: Screen(), update: Screen.update)  // main-actor isolated
    /// }
    /// ```
    ///
    /// ## Design Attribution
    ///
    /// An independent implementation in the Elm lineage. State advanced by actions
    /// descends from Elm and Redux; effects returned from a reduction as data, and a
    /// test store that asserts step by step, are prior art visible in the
    /// MIT-licensed swift-composable-architecture and its public 2.0 beta. No code
    /// or API surface from any of those is reproduced here.
    @Observable
    public final class Runtime<State: Sendable, Action: Sendable>: @unchecked Sendable {
        /// The current state.
        ///
        /// Advanced only by ``send(_:)``. Reading it inside
        /// `withObservationTracking(_:onChange:)` registers interest in the next
        /// change.
        public var state: State

        /// The reduction this runtime advances ``state`` by.
        public let update: Store.Update<State, Action, Store.Work<Action>>

        /// The dependency overrides in force for everything this runtime runs.
        public let scope: Store.Scope

        /// The isolation this runtime was created on and returns to.
        public let isolation: (any Actor)?

        /// Renders ``state`` for assertions.
        let projection: @Sendable (State) -> Store.View.Node

        // The properties below are deliberately underscore-prefixed: the
        // observation macro tracks stored `var`s, and these are bookkeeping whose
        // change is not something anyone observes. The prefix is what keeps them
        // out of the tracked set.

        var _features: Registry.Mounts<Store.Feature.Mount>
        var _pending: Mailbox<Action>
        var _inFlight: Ledger<Store.Work<Action>.Record>
        var _nextTicket: UInt64
        var _reducing: Bool

        /// Creates a runtime.
        ///
        /// - Parameters:
        ///   - state: The initial state.
        ///   - update: The reduction advancing the state.
        ///   - scope: Dependency overrides in force for everything this runtime runs.
        ///   - projection: Renders the state for assertions.
        ///   - isolation: The isolation to run on. Defaults to the caller's, which is
        ///     what makes a main-actor caller's runtime main-actor isolated without
        ///     this type mentioning the main actor.
        public init(
            state: State,
            update: Store.Update<State, Action, Store.Work<Action>>,
            scope: Store.Scope = .inherited,
            projection: @escaping @Sendable (State) -> Store.View.Node = { _ in .empty },
            isolation: isolated (any Actor)? = #isolation
        ) {
            self.state = state
            self.update = update
            self.scope = scope
            self.projection = projection
            self.isolation = isolation
            self._features = Registry.Mounts()
            self._pending = Mailbox()
            self._inFlight = Ledger()
            self._nextTicket = 0
            self._reducing = false
        }
    }
}
