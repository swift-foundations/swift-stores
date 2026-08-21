public import Store_Reduction_Primitives

extension Store {

    public enum Error: Swift.Error, Sendable, Equatable {

        case notMounted

        case rootAlreadyMounted

        case nameOccupied(String)
    }
}
