public import Store_Reduction_Primitives

extension Store.Runtime {
    /// This runtime's state rendered for assertion, with everything mounted under it.
    ///
    /// A feature that holds no state of its own renders nothing and its descendants
    /// render in its place, so the shape of the view follows where state actually
    /// lives rather than every position in the tree.
    ///
    /// - Parameter redaction: Fields to withhold wherever they appear.
    public func view(redacting redaction: Store.Redaction = .nothing) -> Store.View.Node {
        let own = projection(state)
        let mounted = _features.root.map { spawned(under: $0) } ?? []

        return Store.View.Node(
            name: own.name,
            fields: own.fields,
            children: own.children + mounted
        )
        .redacted(by: redaction)
    }

    /// The rendered features under `handle`, in mount order.
    private func spawned(under handle: Registry.Handle) -> [Store.View.Node] {
        var result: [Store.View.Node] = []

        for child in _features.children(of: handle) {
            let descendants = spawned(under: child.handle)

            guard
                let mount = _features.node(at: child.handle),
                let render = mount.render
            else {
                result.append(contentsOf: descendants)
                continue
            }

            let rendered = render()
            result.append(
                Store.View.Node(
                    name: child.name,
                    fields: rendered.fields,
                    children: rendered.children + descendants
                )
            )
        }

        return result
    }
}
