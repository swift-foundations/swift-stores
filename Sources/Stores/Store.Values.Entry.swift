public import Store_Reduction_Primitives

extension Store.Values {
    /// One supplied value together with the identity of the key naming it.
    ///
    /// The key type itself is the identity. Nothing is looked up by name and
    /// nothing is matched by reflection over the value — the only runtime fact
    /// recorded is which key type this entry answers to.
    struct Entry: Sendable {
        let identity: ObjectIdentifier

        // REASON: the box for key-addressed values and bubbling events. Heterogeneous storage has
        // REASON: no generic form; the concrete type is recovered by a checked cast at a single
        // REASON: typed boundary, and the public surface stays generic over the key or event type.
        let value: any Sendable  // swiftlint:disable:this no_any_protocol_existential
    }
}
