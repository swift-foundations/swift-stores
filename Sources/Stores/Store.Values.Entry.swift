public import Store_Reduction_Primitives

extension Store.Values {
    /// One supplied value together with the identity of the key naming it.
    ///
    /// The key type itself is the identity. Nothing is looked up by name and
    /// nothing is matched by reflection over the value — the only runtime fact
    /// recorded is which key type this entry answers to.
    struct Entry: Sendable {
        let identity: ObjectIdentifier

        let value: any Sendable

        init(identity: ObjectIdentifier, value: any Sendable) {
            self.identity = identity
            self.value = value
        }
    }
}
