extension Registry {
    /// A structural mount or dismount that the tree refused.
    enum Error: Swift.Error, Sendable, Equatable {
        /// The handle names a node that is no longer mounted.
        case stale

        /// A root is already mounted.
        case rootOccupied

        /// The parent already has a child under that name.
        case nameOccupied(String)
    }
}
