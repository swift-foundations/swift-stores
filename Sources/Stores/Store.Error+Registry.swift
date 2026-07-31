public import Store_Reduction_Primitives

extension Store.Error {
    /// The registry's refusal, restated in the runtime's vocabulary.
    init(_ error: Registry.Error) {
        switch error {
        case .stale:
            self = .notMounted

        case .rootOccupied:
            self = .rootAlreadyMounted

        case .nameOccupied(let name):
            self = .nameOccupied(name)
        }
    }
}
