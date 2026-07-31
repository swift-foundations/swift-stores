public import Store_Reduction_Primitives
public import Effects

extension Store.Job {
    /// Performs the bodies a runtime asks for.
    public struct Handler: Effect.Handler.`Protocol`, Sendable {
        let run: @Sendable (@escaping @Sendable () async -> Void) async -> Void

        /// Creates a handler.
        ///
        /// - Parameter run: Performs one body.
        public init(_ run: @escaping @Sendable (@escaping @Sendable () async -> Void) async -> Void) {
            self.run = run
        }
    }
}

extension Store.Job.Handler {
    public typealias Handled = Store.Job

    public func handle(
        _ effect: borrowing Store.Job,
        continuation: consuming Effect.Continuation.One<Void, Never>
    ) async {
        let body = effect.body
        await run(body)
        await continuation.resume()
    }
}

extension Store.Job.Handler {
    /// Performs each body as it arrives, awaiting it before returning.
    public static var inline: Self {
        .init { body in await body() }
    }
}
