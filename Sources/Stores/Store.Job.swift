public import Effects
public import Store_Reduction_Primitives

extension Store {
    /// The request through which a runtime asks for a body of work to be performed.
    ///
    /// This is the seam to the effect owner, and it is the reason this package
    /// contains no execution policy of its own. A runtime decides *when* work starts
    /// and stops, because that follows the feature lifecycle it owns; it does not
    /// decide *how* a body is performed, because that is a capability the effect
    /// owner already has and this package would only be reimplementing.
    ///
    /// The consequence is the one worth having: a test does not need a different
    /// runtime, only a different handler.
    ///
    /// ## Example
    ///
    /// ```swift
    /// await Effect.Context.with { handlers in
    ///     handlers[Store.Job.Handler.Key.self] = .immediate
    /// } operation: {
    ///     // every unit of work this runtime starts now runs inline
    /// }
    /// ```
    public struct Job: Effects.Effect.`Protocol`, EffectWithHandler, Sendable {
        /// The body to perform.
        public let body: @Sendable () async -> Void

        /// Creates a request to perform `body`.
        ///
        /// - Parameter body: The work to perform.
        public init(_ body: @escaping @Sendable () async -> Void) {
            self.body = body
        }
    }
}

extension Store.Job {
    public typealias Value = Void
    public typealias Failure = Never
    public typealias HandlerKey = Store.Job.Handler.Key
}
