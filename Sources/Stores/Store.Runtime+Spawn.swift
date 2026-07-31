public import Store_Reduction_Primitives

extension Store.Runtime {
    /// Mounts a feature under `parent` that runs its own state on its own runtime.
    ///
    /// A spawned subtree opts out of the parent's action routing. Its actions are
    /// reduced by its own reduction against its own state and never travel through
    /// the parent, so sending to it costs what sending to any runtime costs — it
    /// does not grow with how deep in the tree it happens to sit, or with how much
    /// state the parent holds.
    ///
    /// What the parent keeps is the lifecycle. Dismounting the parent feature stops
    /// the child's work and takes the child's position with it, so an independent
    /// runtime is still not an orphan.
    ///
    /// The two runtimes talk the way any two features do: values and commands travel
    /// down, events bubble up, contributions aggregate upward. Neither one's action
    /// type appears in the other.
    ///
    /// - Parameters:
    ///   - name: The name addressing the feature among its siblings.
    ///   - parent: The feature to mount it under.
    ///   - state: The child's initial state.
    ///   - update: The child's reduction.
    ///   - scope: Dependency overrides for the child. Defaults to this runtime's.
    ///   - projection: Renders the child's state for assertions.
    ///   - configure: Says what the child feature offers the rest of the tree.
    ///   - isolation: The isolation the child runs on. Defaults to the caller's.
    /// - Returns: The child's runtime.
    /// - Throws: ``Store/Error/notMounted`` if `parent` is gone, or
    ///   ``Store/Error/nameOccupied(_:)`` if the name is taken.
    @discardableResult
    public func spawn<ChildState: Sendable, ChildAction: Sendable>(
        _ name: String,
        under parent: Store.Feature.Handle,
        state: ChildState,
        update: Store.Update<ChildState, ChildAction, Store.Work<ChildAction>>,
        scope: Store.Scope? = nil,
        projection: @escaping @Sendable (ChildState) -> Store.View.Node = { _ in .empty },
        _ configure: (inout Store.Feature.Mount) -> Void = { _ in },
        isolation: isolated (any Actor)? = #isolation
    ) throws(Store.Error) -> Store.Runtime<ChildState, ChildAction> {
        let child = Store.Runtime<ChildState, ChildAction>(
            state: state,
            update: update,
            scope: scope ?? self.scope,
            projection: projection,
            isolation: isolation
        )

        do {
            try mount(name, under: parent) { mount in
                configure(&mount)
                mount.renders { child.view() }
                mount.onDismount { child.cancelAll() }
            }
        } catch {
            throw error
        }

        return child
    }
}
