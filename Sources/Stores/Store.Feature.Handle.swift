public import Store_Reduction_Primitives

extension Store.Feature {
    /// A reference to a mounted feature that stops resolving once it is dismounted.
    ///
    /// A handle is not a name. Two features may be mounted under the same name at
    /// the same path at different times, and a handle to the first does not
    /// resolve to the second — it resolves to nothing. Holding a handle across a
    /// dismount is the characteristic mistake an explicit lifecycle makes possible,
    /// so it is the one this type is built to catch rather than to tolerate.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let detail = try runtime.mount("detail", under: root)
    /// try runtime.dismount(detail)
    /// runtime.isMounted(detail)  // false — not "true, some other feature"
    /// ```
    public struct Handle: Hashable, Sendable {
        let registry: Registry.Handle

        init(_ registry: Registry.Handle) {
            self.registry = registry
        }
    }
}
