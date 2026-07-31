internal import Tree_Keyed_Primitives

extension Registry {
    /// The mounted nodes, addressed by their path of names from the root.
    ///
    /// Backed by the keyed tree primitive rather than a nested keyed map. The
    /// choice is not about convenience: the primitive already owns addressing by
    /// key path, child enumeration, subtree removal, and — decisively —
    /// generational positions, so a handle to a dismounted feature is caught by
    /// construction. A nested map would have to grow all four, and the fourth
    /// badly.
    struct Mounts<Node: Sendable> {
        typealias Storage = Tree<Node>.Keyed<String>

        private var storage: Storage

        init() {
            self.storage = Storage()
        }
    }
}

// MARK: - Structure

extension Registry.Mounts {
    /// The root node's handle, if a root is mounted.
    var root: Registry.Handle? {
        storage.root.map(Registry.Handle.init)
    }

    /// Whether nothing is mounted.
    var isEmpty: Bool {
        storage.isEmpty
    }

    /// Whether `handle` still names a mounted node.
    func holds(_ handle: Registry.Handle) -> Bool {
        storage.peek(at: handle.position) != nil
    }
}

// MARK: - Mounting

extension Registry.Mounts {
    /// Mounts `node` as the root.
    ///
    /// - Parameter node: The node to mount.
    /// - Returns: A handle to the mounted root.
    /// - Throws: ``Registry/Error/rootOccupied`` if a root is already mounted.
    mutating func mountRoot(_ node: Node) throws(Registry.Error) -> Registry.Handle {
        do throws(Storage.Error) {
            return Registry.Handle(try storage.insert(node, at: Storage.Insert.Position.root))
        } catch {
            throw Registry.Error(error)
        }
    }

    /// Mounts `node` under `parent` at `name`.
    ///
    /// - Parameters:
    ///   - node: The node to mount.
    ///   - name: The name addressing it among its siblings.
    ///   - parent: The node to mount it under.
    /// - Returns: A handle to the mounted node.
    /// - Throws: ``Registry/Error/stale`` if `parent` is no longer mounted, or
    ///   ``Registry/Error/nameOccupied(_:)`` if the name is taken.
    mutating func mount(
        _ node: Node,
        named name: String,
        under parent: Registry.Handle
    ) throws(Registry.Error) -> Registry.Handle {
        do throws(Storage.Error) {
            return Registry.Handle(try storage.insert(node, at: .child(of: parent.position, key: name)))
        } catch {
            throw Registry.Error(error)
        }
    }

    /// Dismounts the node at `handle` and everything under it.
    ///
    /// - Parameter handle: The node to dismount.
    /// - Throws: ``Registry/Error/stale`` if the handle no longer names a mounted node.
    mutating func dismount(_ handle: Registry.Handle) throws(Registry.Error) {
        guard holds(handle) else { throw .stale }
        do throws(__TreeError) {
            try storage.removeSubtree(at: handle.position)
        } catch {
            throw .stale
        }
    }
}

// MARK: - Access

extension Registry.Mounts {
    /// The node at `handle`, or `nil` if it is no longer mounted.
    func node(at handle: Registry.Handle) -> Node? {
        storage.peek(at: handle.position)
    }

    /// Applies `body` to the node at `handle` in place.
    ///
    /// The position is stable across the mutation — only the stored node changes —
    /// so handles minted beforehand keep resolving.
    ///
    /// - Returns: What `body` returned, or `nil` if the node is no longer mounted.
    @discardableResult
    mutating func withNode<R>(at handle: Registry.Handle, _ body: (inout Node) -> R) -> R? {
        storage.withElementMut(at: handle.position, body)
    }
}

// MARK: - Addressing

extension Registry.Mounts {
    /// The handle at `path`, counted from the root.
    func handle(at path: some Swift.Sequence<String>) -> Registry.Handle? {
        storage.position(at: path).map(Registry.Handle.init)
    }

    /// The path from the root to `handle`.
    func path(to handle: Registry.Handle) -> [String]? {
        storage.keyPath(to: handle.position)
    }

    /// The name addressing `handle` among its siblings, or `nil` for the root.
    func name(of handle: Registry.Handle) -> String? {
        storage.key(of: handle.position)
    }
}

// MARK: - Navigation

extension Registry.Mounts {
    /// The children of `handle`, in the order they were mounted.
    func children(of handle: Registry.Handle) -> [(name: String, handle: Registry.Handle)] {
        guard let children = storage.children(of: handle.position) else { return [] }
        return children.map { (name: $0.key, handle: Registry.Handle($0.position)) }
    }

    /// The ancestors of `handle`, nearest parent first, up to and including the root.
    ///
    /// This is the path an event walks as it bubbles.
    func ancestors(of handle: Registry.Handle) -> [Registry.Handle] {
        var result: [Registry.Handle] = []
        var current = handle.position
        while let parent = storage.parent(of: current) {
            result.append(Registry.Handle(parent))
            current = parent
        }
        return result
    }

    /// `handle` and everything under it, in breadth-first order.
    ///
    /// This is the set an upward aggregation gathers contributions from, and
    /// breadth-first order is what makes the gathered order reproducible.
    func subtree(from handle: Registry.Handle) -> [Registry.Handle] {
        var result: [Registry.Handle] = []
        var frontier: [Registry.Handle] = [handle]
        while !frontier.isEmpty {
            let current = frontier.removeFirst()
            result.append(current)
            frontier.append(contentsOf: children(of: current).map(\.handle))
        }
        return result
    }
}
