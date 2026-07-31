internal import Tree_Keyed_Primitives

extension Registry {
    /// A reference to one mounted node that stops being valid when the node is
    /// dismounted.
    ///
    /// The handle carries the arena slot together with the generation the slot had
    /// when the handle was minted. A handle retained past its node's dismount does
    /// not resolve to whatever later reused the slot — it resolves to nothing. That
    /// is the property the whole feature tree was chosen for: with an explicit
    /// mount and dismount API, a stale handle is the characteristic bug, and a
    /// plain keyed map answers a stale lookup indistinguishably from a live one.
    struct Handle: Hashable, Sendable {
        /// The generational position in the underlying arena.
        let position: __TreePosition

        init(_ position: __TreePosition) {
            self.position = position
        }
    }
}
