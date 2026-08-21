public import Store_Reduction_Primitives

extension Store.Values {

    struct Entry: Sendable {
        let identity: ObjectIdentifier

        let value: any Sendable
    }
}
