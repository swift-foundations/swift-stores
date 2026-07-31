internal import Tree_Keyed_Primitives

extension Registry.Error {
    /// The tree's refusal, restated in this package's vocabulary.
    init(_ error: __TreeKeyedError<String>) {
        switch error {
        case .invalidPosition:
            self = .stale
        case .rootOccupied:
            self = .rootOccupied
        case .keyOccupied(let key):
            self = .nameOccupied(key)
        case .cannotRemoveNonLeaf:
            self = .stale
        }
    }
}
