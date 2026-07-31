public import Store_Reduction_Primitives

extension Store.Runtime {
    /// Mounts the root feature.
    ///
    /// - Parameter configure: Says what the feature offers the rest of the tree.
    /// - Returns: A handle to the mounted root.
    /// - Throws: ``Store/Error/rootAlreadyMounted`` if a root is already mounted.
    @discardableResult
    public func mountRoot(
        _ configure: (inout Store.Feature.Mount) -> Void = { _ in }
    ) throws(Store.Error) -> Store.Feature.Handle {
        var mount = Store.Feature.Mount()
        configure(&mount)
        do throws(Registry.Error) {
            return Store.Feature.Handle(try _features.mountRoot(mount))
        } catch {
            throw Store.Error(error)
        }
    }

    /// Mounts a feature under `parent` at `name`.
    ///
    /// - Parameters:
    ///   - name: The name addressing it among its siblings.
    ///   - parent: The feature to mount it under.
    ///   - configure: Says what the feature offers the rest of the tree.
    /// - Returns: A handle to the mounted feature.
    /// - Throws: ``Store/Error/notMounted`` if `parent` is gone, or
    ///   ``Store/Error/nameOccupied(_:)`` if the name is taken.
    @discardableResult
    public func mount(
        _ name: String,
        under parent: Store.Feature.Handle,
        _ configure: (inout Store.Feature.Mount) -> Void = { _ in }
    ) throws(Store.Error) -> Store.Feature.Handle {
        var mount = Store.Feature.Mount()
        configure(&mount)
        do throws(Registry.Error) {
            return Store.Feature.Handle(try _features.mount(mount, named: name, under: parent.registry))
        } catch {
            throw Store.Error(error)
        }
    }

    /// Dismounts the feature at `handle` and everything under it.
    ///
    /// Teardown runs deepest first, so a feature is never torn down while something
    /// beneath it is still mounted. Every handle into the removed subtree stops
    /// resolving at this point rather than resolving to whatever is mounted there
    /// next.
    ///
    /// - Parameter handle: The feature to dismount.
    /// - Throws: ``Store/Error/notMounted`` if the handle no longer names a feature.
    public func dismount(_ handle: Store.Feature.Handle) throws(Store.Error) {
        guard _features.holds(handle.registry) else { throw .notMounted }

        for descendant in _features.subtree(from: handle.registry).reversed() {
            guard let mount = _features.node(at: descendant) else { continue }
            for body in mount.teardown.reversed() {
                body()
            }
        }

        do throws(Registry.Error) {
            try _features.dismount(handle.registry)
        } catch {
            throw Store.Error(error)
        }
    }

    /// Whether `handle` still names a mounted feature.
    ///
    /// - Parameter handle: The handle to test.
    public func isMounted(_ handle: Store.Feature.Handle) -> Bool {
        _features.holds(handle.registry)
    }
}

// MARK: - Addressing

extension Store.Runtime {
    /// The root feature, if one is mounted.
    public var root: Store.Feature.Handle? {
        _features.root.map(Store.Feature.Handle.init)
    }

    /// The feature at `path`, counted from the root.
    ///
    /// - Parameter path: The names from the root down.
    public func feature(at path: [String]) -> Store.Feature.Handle? {
        _features.handle(at: path).map(Store.Feature.Handle.init)
    }

    /// The path from the root to `handle`.
    ///
    /// - Parameter handle: The feature to locate.
    public func path(to handle: Store.Feature.Handle) -> [String]? {
        _features.path(to: handle.registry)
    }

    /// The features mounted directly under `handle`, in mount order.
    ///
    /// - Parameter handle: The parent feature.
    public func children(
        of handle: Store.Feature.Handle
    ) -> [(name: String, handle: Store.Feature.Handle)] {
        _features.children(of: handle.registry).map {
            (name: $0.name, handle: Store.Feature.Handle($0.handle))
        }
    }
}
