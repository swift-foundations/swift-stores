public import Store_Reduction_Primitives

extension Store {
    /// Namespace for the rendered form of a runtime's state.
    ///
    /// A test asserts against this rather than against `State`, and the reason is
    /// not convenience. Requiring `State: Equatable` puts a conformance on every
    /// feature's state for the benefit of tests, drags every stored value into that
    /// requirement with it, and still gives a failure message that says two large
    /// values differ without saying where. A view is derived, so it costs the state
    /// nothing; it is named field by field, so a failure says which field; and it is
    /// redactable, so the fields nobody is asserting on stop breaking assertions.
    public enum View {}
}
