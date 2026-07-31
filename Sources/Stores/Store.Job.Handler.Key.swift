public import Effects
public import Store_Reduction_Primitives

extension Store.Job.Handler {
    /// The context key supplying the handler that performs a runtime's work.
    public struct Key: Dependency.Key {}
}

extension Store.Job.Handler.Key {
    public typealias Value = Store.Job.Handler

    public static var liveValue: Store.Job.Handler { .inline }

    public static var testValue: Store.Job.Handler { .inline }
}
