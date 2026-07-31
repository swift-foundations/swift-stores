public import Store_Reduction_Primitives

extension Store {
    /// Namespace for the features a runtime mounts.
    ///
    /// A feature is a named position in a runtime's tree. It is mounted
    /// explicitly and dismounted explicitly — there is no reflection over state to
    /// discover it, and no lifetime inferred from whether some optional happens to
    /// be non-`nil`. That is the whole point of the vocabulary: the moment a
    /// feature appears and the moment it goes away are both call sites you can put
    /// a breakpoint on.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let root = try runtime.mountRoot()
    /// let detail = try runtime.mount("detail", under: root)
    /// try runtime.dismount(detail)
    /// ```
    public enum Feature {}
}
