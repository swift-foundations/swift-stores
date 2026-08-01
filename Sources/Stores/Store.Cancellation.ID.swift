public import Store_Reduction_Primitives

extension Store.Cancellation {
    /// A name identifying work so that it can be stopped, or so that starting it
    /// again replaces what was already running.
    ///
    /// The identity is an author-chosen name rather than a type or an opaque
    /// token, and that is a deliberate trade. A test that fails because work is
    /// still in flight has to say *which* work, and a name is the only identity
    /// that survives into that message legibly.
    ///
    /// ## Example
    ///
    /// ```swift
    /// .run(Store.Work(cancellation: "search") { send in
    ///     await send(.results(try await search(query)))
    /// })
    /// ```
    public struct ID: Hashable, Sendable, ExpressibleByStringLiteral, CustomStringConvertible {
        /// The name.
        public let name: String

        /// Creates an identity from a name.
        ///
        /// - Parameter name: The name identifying the work.
        public init(_ name: String) {
            self.name = name
        }

        public init(stringLiteral value: String) {
            self.init(value)
        }
    }
}

extension Store.Cancellation.ID {
    public var description: String {
        name
    }
}
