public import Store_Reduction_Primitives
public import Dependencies

extension Store {
    /// The dependency scope a runtime's reductions and effect bodies run inside.
    ///
    /// A feature reaches its dependencies the ordinary way, with `@Dependency`. What
    /// a runtime adds is a single place to override them for everything it runs, so
    /// a test fixes a clock or a client once at the runtime rather than at every
    /// call site underneath it.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let runtime = Store.Runtime(
    ///     state: State(),
    ///     update: feature,
    ///     scope: Store.Scope { values in
    ///         values.clock = Clock.`Any`(clock)
    ///     }
    /// )
    /// ```
    public struct Scope: Sendable {
        let apply: @Sendable (inout Dependency.Values) -> Void

        /// Creates a scope that applies `apply` to the values in force.
        ///
        /// - Parameter apply: Overrides the values for everything the runtime runs.
        public init(_ apply: @escaping @Sendable (inout Dependency.Values) -> Void) {
            self.apply = apply
        }
    }
}

extension Store.Scope {
    /// A scope that overrides nothing, leaving the values in force as they are.
    public static var inherited: Self {
        .init { _ in }
    }
}

extension Store.Scope {
    /// Runs `operation` with this scope's overrides in force.
    ///
    /// - Parameter operation: The work to run inside the scope.
    /// - Returns: What `operation` returned.
    /// - Throws: Whatever `operation` throws.
    func run<T, E: Swift.Error>(_ operation: () throws(E) -> T) throws(E) -> T {
        try withDependencies(apply, operation: operation)
    }

    /// Runs `operation` with this scope's overrides in force.
    ///
    /// - Parameter operation: The work to run inside the scope.
    /// - Returns: What `operation` returned.
    /// - Throws: Whatever `operation` throws.
    func run<T, E: Swift.Error>(
        _ operation: nonisolated(nonsending) () async throws(E) -> T
    ) async throws(E) -> T {
        try await withDependencies(apply, operation: operation)
    }
}
