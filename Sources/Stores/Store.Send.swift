public import Store_Reduction_Primitives

extension Store {
    /// The way running work feeds actions back into the runtime that started it.
    ///
    /// Work does not return a result to the reduction that asked for it — that
    /// reduction returned before the work began. What work produces re-enters as
    /// actions, which is also what makes the whole exchange replayable: everything
    /// that ever changed the state went through ``Store/Runtime/send(_:)``.
    ///
    /// Delivery hops back to the isolation the runtime was created on, so an effect
    /// body may run anywhere and still not race the reduction.
    ///
    /// ## Example
    ///
    /// ```swift
    /// .run(Store.Work { send in
    ///     await send(.loaded(try await load()))
    /// })
    /// ```
    public struct Send<Action: Sendable>: Sendable {
        let deliver: @Sendable (Action) async -> Void

        init(deliver: @escaping @Sendable (Action) async -> Void) {
            self.deliver = deliver
        }
    }
}

extension Store.Send {
    /// Feeds `action` back into the runtime.
    ///
    /// - Parameter action: The action to send.
    public func callAsFunction(_ action: Action) async {
        await deliver(action)
    }
}
