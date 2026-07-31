public import Store_Reduction_Primitives

extension Store.Event {
    /// One feature's willingness to be offered events of a particular type.
    ///
    /// A receiver is a witness holding a closure rather than a conformance, so a
    /// feature registers as many as it likes and the runtime stores them all
    /// uniformly. ``Store/Event/Disposition/ignored`` is what a receiver returns
    /// for an event whose type it does not recognise, which is what lets receivers
    /// for unrelated event types sit side by side.
    struct Receiver: Sendable {
        let accept: @Sendable (any Sendable) -> Store.Event.Disposition

        init(accept: @escaping @Sendable (any Sendable) -> Store.Event.Disposition) {
            self.accept = accept
        }
    }
}

extension Store.Event.Receiver {
    /// A receiver that recognises exactly `type` and offers it to `handle`.
    ///
    /// - Parameters:
    ///   - type: The event type this receiver recognises.
    ///   - handle: Decides what happens to a recognised event.
    static func of<E: Sendable>(
        _ type: E.Type,
        _ handle: @escaping @Sendable (E) -> Store.Event.Disposition
    ) -> Self {
        .init { event in
            guard let event = event as? E else { return .ignored }
            return handle(event)
        }
    }
}
