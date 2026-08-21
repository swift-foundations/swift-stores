public import Store_Reduction_Primitives

extension Store.Event {

    public enum Disposition: Sendable {

        case ignored

        case consumed

        case transformed(any Sendable)
    }
}
