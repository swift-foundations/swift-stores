public import Store_Reduction_Primitives

extension Store {
    /// Namespace for values a feature sends to whatever is above it.
    ///
    /// An event travels the other way from an action. An action is sent *to* a
    /// runtime and reduces its state; an event is raised *by* a feature and offered
    /// to each of its ancestors in turn, nearest first, until one consumes it. The
    /// feature that raised it names neither a recipient nor a route, which is what
    /// lets a feature be mounted anywhere without knowing what it was mounted under.
    ///
    /// An ancestor offered an event may ignore it and let it keep rising, consume it
    /// and stop it, or transform it into a different event that continues rising in
    /// the transformed form.
    ///
    /// ## Example
    ///
    /// ```swift
    /// struct Saved: Sendable { let id: Int }
    ///
    /// mount.on(Saved.self) { saved in
    ///     .transformed(Refresh(id: saved.id))
    /// }
    /// ```
    public enum Event {}
}
