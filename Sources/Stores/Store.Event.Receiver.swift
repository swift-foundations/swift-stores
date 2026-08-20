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
        // REASON: the box for key-addressed values and bubbling events. Heterogeneous storage has
        // REASON: no generic form; the concrete type is recovered by a checked cast at a single
        // REASON: typed boundary, and the public surface stays generic over the key or event type.
        // swiftlint:disable:this no_any_protocol_existential
        let accept: @Sendable (any Sendable) -> Store.Event.Disposition

        // REASON: the box for key-addressed values and bubbling events. Heterogeneous storage has
        // REASON: no generic form; the concrete type is recovered by a checked cast at a single
        // REASON: typed boundary, and the public surface stays generic over the key or event type.
        // swiftlint:disable:this no_any_protocol_existential
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
