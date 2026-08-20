public import Clocks
public import Stores

extension Store.Test {
    /// A store that requires every step to state its outcome.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let clock = Clock.Test()
    /// let store = Store.Test.Runtime(
    ///     state: Counter(),
    ///     update: Counter.update,
    ///     clock: clock,
    ///     projection: Counter.view
    /// )
    ///
    /// try store.send(.increment, becoming: .init(fields: [.init("count", "1")]))
    /// await store.advance(by: .seconds(1))
    /// try await store.finish()
    /// ```
    public final class Runtime<State: Sendable, Action: Sendable>: @unchecked Sendable {
        /// The store under test.
        public let store: Store.Runtime<State, Action>

        /// The clock the store's work schedules against.
        public let clock: Clock.Test

        /// Fields withheld from every assertion this runtime makes.
        public let redaction: Store.Redaction

        /// Creates a test runtime.
        ///
        /// - Parameters:
        ///   - state: The initial state.
        ///   - update: The reduction advancing the state.
        ///   - clock: The clock work schedules against.
        ///   - scope: Dependency overrides in force for everything the store runs.
        ///   - redacting: Fields to withhold from every assertion.
        ///   - projection: Renders the state for assertion.
        ///   - isolation: The isolation to run on. Defaults to the caller's.
        public init(
            state: State,
            update: Store.Update<State, Action, Store.Work<Action>>,
            clock: Clock.Test = Clock.Test(),
            scope: Store.Scope = .inherited,
            redacting redaction: Store.Redaction = .nothing,
            projection: @escaping @Sendable (State) -> Store.View.Node = { _ in .empty },
            // REASON: `isolated (any Actor)?` is the language's only spelling for an isolated-actor
            // REASON: parameter — there is no generic form — and it performs an executor hop rather
            // REASON: than dynamic dispatch.
            // swiftlint:disable:this no_any_protocol_existential
            isolation: isolated (any Actor)? = #isolation
        ) {
            self.clock = clock
            self.redaction = redaction
            self.store = Store.Runtime(
                state: state,
                update: update,
                scope: scope,
                projection: projection,
                isolation: isolation
            )
        }
    }
}

// MARK: - Asserting

extension Store.Test.Runtime {
    /// The store's view, with this runtime's redaction applied.
    public var view: Store.View.Node {
        store.view(redacting: redaction)
    }

    /// Sends `action` and requires the resulting view to be exactly `expected`.
    ///
    /// The comparison is over the whole view. A field that changed and was not
    /// stated fails here rather than surviving to confuse a later step.
    ///
    /// - Parameters:
    ///   - action: The action to send.
    ///   - expected: The view the store must have afterwards.
    /// - Throws: ``Store/Test/Failure/unexpectedView(expected:actual:)``.
    public func send(
        _ action: Action,
        becoming expected: Store.View.Node
    ) throws(Store.Test.Failure) {
        store.send(action)
        try require(expected)
    }

    /// Requires the store's current view to be exactly `expected`.
    ///
    /// - Parameter expected: The view the store must have.
    /// - Throws: ``Store/Test/Failure/unexpectedView(expected:actual:)``.
    public func require(_ expected: Store.View.Node) throws(Store.Test.Failure) {
        let redacted = expected.redacted(by: redaction)
        let actual = view
        guard actual == redacted else {
            throw .unexpectedView(expected: redacted, actual: actual)
        }
    }
}

// MARK: - Time and settling

extension Store.Test.Runtime {
    /// Advances the clock and lets whatever it released run.
    ///
    /// - Parameters:
    ///   - duration: How far to advance.
    ///   - isolation: The isolation to return to. Defaults to the caller's.
    public func advance(
        by duration: Duration,
        // REASON: `isolated (any Actor)?` is the language's only spelling for an isolated-actor
        // REASON: parameter — there is no generic form — and it performs an executor hop rather
        // REASON: than dynamic dispatch.
        // swiftlint:disable:this no_any_protocol_existential
        isolation: isolated (any Actor)? = #isolation
    ) async {
        clock.advance(by: duration)
        await settle(isolation: isolation)
    }

    /// Lets work that is already running reach its next resting point.
    ///
    /// - Parameters:
    ///   - turns: How many scheduling turns to allow before giving up.
    ///   - isolation: The isolation to return to. Defaults to the caller's.
    public func settle(
        turns: Int = 1_000,
        // REASON: `isolated (any Actor)?` is the language's only spelling for an isolated-actor
        // REASON: parameter — there is no generic form — and it performs an executor hop rather
        // REASON: than dynamic dispatch.
        // swiftlint:disable:this no_any_protocol_existential
        isolation: isolated (any Actor)? = #isolation
    ) async {
        for _ in 0..<turns where !store.isSettled {
            await Task.yield()
        }
    }

    /// Requires that nothing is left running.
    ///
    /// - Parameters:
    ///   - turns: How many scheduling turns to allow before giving up.
    ///   - isolation: The isolation to return to. Defaults to the caller's.
    /// - Throws: ``Store/Test/Failure/unfinishedWork(_:)`` if work is still in flight.
    public func finish(
        turns: Int = 1_000,
        // REASON: `isolated (any Actor)?` is the language's only spelling for an isolated-actor
        // REASON: parameter — there is no generic form — and it performs an executor hop rather
        // REASON: than dynamic dispatch.
        // swiftlint:disable:this no_any_protocol_existential
        isolation: isolated (any Actor)? = #isolation
    ) async throws(Store.Test.Failure) {
        await settle(turns: turns, isolation: isolation)
        guard store.isSettled else {
            throw .unfinishedWork(store.inFlight)
        }
    }
}
