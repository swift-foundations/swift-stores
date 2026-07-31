public import Store_Reduction_Primitives

extension Store.View {
    /// One feature's rendered state, together with the features under it.
    ///
    /// Fields and children are held in the order the projection produced them, and
    /// that order is part of what is asserted. An ordering that varied run to run
    /// would make every assertion flaky for a reason unrelated to the behaviour
    /// under test, which is why this is a sequence rather than a keyed map.
    public struct Node: Sendable, Hashable {
        /// The name of the feature this node renders.
        public let name: String

        /// The rendered fields, in the order the projection produced them.
        public let fields: [Store.View.Field]

        /// The rendered features under this one, in mount order.
        public let children: [Store.View.Node]

        /// Creates a node.
        ///
        /// - Parameters:
        ///   - name: The name of the feature this node renders.
        ///   - fields: The rendered fields.
        ///   - children: The rendered features under this one.
        public init(
            name: String = "",
            fields: [Store.View.Field] = [],
            children: [Store.View.Node] = []
        ) {
            self.name = name
            self.fields = fields
            self.children = children
        }
    }
}

extension Store.View.Node {
    /// A node rendering nothing.
    public static var empty: Self {
        .init()
    }

    /// This node with `redaction` applied throughout.
    ///
    /// - Parameter redaction: The fields to withhold.
    /// - Returns: The same shape, with withheld field values replaced.
    public func redacted(by redaction: Store.Redaction) -> Self {
        .init(
            name: name,
            fields: fields.map { redaction.withholds($0.name) ? $0.redacted : $0 },
            children: children.map { $0.redacted(by: redaction) }
        )
    }
}
