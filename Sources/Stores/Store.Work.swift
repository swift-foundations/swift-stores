public import Store_Reduction_Primitives

extension Store {
    /// One unit of work a reduction asked for.
    ///
    /// This is the leaf the reduction algebra left abstract. The algebra owns *what
    /// was asked for and how requests combine*; this type says what a request is
    /// here, and it deliberately does not say how one is performed. Performing is
    /// the effect owner's, reached through ``Store/Job``, so swapping how work runs
    /// is a handler swap and touches nothing in a feature.
    ///
    /// ## Example
    ///
    /// ```swift
    /// return .run(
    ///     Store.Work(cancellation: "search") { send in
    ///         await send(.results(await search(query)))
    ///     }
    /// )
    /// ```
    public struct Work<Action: Sendable>: Sendable {
        /// The name under which this work can be stopped, if it has one.
        public let cancellation: Store.Cancellation.ID?

        /// What the work does, given a way to feed actions back.
        public let body: @Sendable (Store.Send<Action>) async -> Void

        /// Creates a unit of work.
        ///
        /// - Parameters:
        ///   - cancellation: A name under which the work can be stopped.
        ///   - body: What the work does.
        public init(
            cancellation: Store.Cancellation.ID? = nil,
            _ body: @escaping @Sendable (Store.Send<Action>) async -> Void
        ) {
            self.cancellation = cancellation
            self.body = body
        }
    }
}
