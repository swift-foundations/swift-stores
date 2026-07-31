public import Store_Reduction_Primitives

extension Store.Work {
    /// One unit of work the runtime currently has in flight.
    struct Record: Sendable {
        let cancellation: Store.Cancellation.ID?
        let task: Task<Void, Never>
    }
}
