public import Store_Reduction_Primitives

extension Store.Event {
    /// What an ancestor did with an event offered to it.
    public enum Disposition: Sendable {
        /// The ancestor did not recognise the event; it keeps rising unchanged.
        case ignored

        /// The ancestor handled the event; it stops here.
        case consumed

        /// The ancestor replaced the event; the replacement keeps rising from here.
        case transformed(any Sendable)
    }
}
