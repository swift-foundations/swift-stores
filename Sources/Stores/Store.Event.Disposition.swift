public import Store_Reduction_Primitives

extension Store.Event {
    /// What an ancestor did with an event offered to it.
    public enum Disposition: Sendable {
        /// The ancestor did not recognise the event; it keeps rising unchanged.
        case ignored

        /// The ancestor handled the event; it stops here.
        case consumed

        // REASON: the box for key-addressed values and bubbling events. Heterogeneous storage has
        // REASON: no generic form; the concrete type is recovered by a checked cast at a single
        // REASON: typed boundary, and the public surface stays generic over the key or event type.
        /// The ancestor replaced the event; the replacement keeps rising from here.
        case transformed(any Sendable)  // swiftlint:disable:this no_any_protocol_existential
    }
}
