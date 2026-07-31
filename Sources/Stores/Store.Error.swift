public import Store_Reduction_Primitives

extension Store {
    /// A lifecycle operation the runtime refused.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// The handle names a feature that is not mounted, or is no longer mounted.
        case notMounted

        /// A root feature is already mounted.
        case rootAlreadyMounted

        /// The parent already has a child feature under that name.
        case nameOccupied(String)
    }
}
