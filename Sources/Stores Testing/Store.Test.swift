public import Stores

extension Store {
    /// Namespace for asserting exhaustively against a running store.
    ///
    /// Exhaustive means two things here, and both are enforced rather than
    /// encouraged. Every send states the view the store must have afterwards — the
    /// whole view, not a field of it — so a change nobody asserted is a failure
    /// rather than a silence. And finishing asserts that no work is still in flight,
    /// so an effect nobody accounted for cannot quietly outlive the test that
    /// started it.
    ///
    /// What is asserted is the derived view, not the state. That is what keeps
    /// `Equatable` off every feature's state, keeps failures naming the field that
    /// differed, and gives redaction somewhere to apply — the fields that
    /// legitimately vary run to run are withheld once, at the test runtime, instead
    /// of being worked around at each assertion.
    public enum Test {}
}
