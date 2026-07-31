public import Stores

extension Store.Test {
    /// An expectation the store did not meet.
    public enum Failure: Swift.Error, Sendable, Equatable, CustomStringConvertible {
        /// The view after the step was not the one the step stated.
        case unexpectedView(expected: Store.View.Node, actual: Store.View.Node)

        /// Work was still in flight when the test finished.
        case unfinishedWork([Store.Cancellation.ID])

        /// The store did not settle within the allowed number of turns.
        case neverSettled

        public var description: String {
            switch self {
            case .unexpectedView(let expected, let actual):
                return """
                    the view after this step is not the one the step stated.
                    expected: \(Store.Test.render(expected))
                    actual:   \(Store.Test.render(actual))
                    """
            case .unfinishedWork(let names):
                let listed = names.map(\.name).joined(separator: ", ")
                return "work was still in flight when the test finished: \(listed)"
            case .neverSettled:
                return "the store never settled: work kept starting more work"
            }
        }
    }
}

extension Store.Test {
    /// Renders a view node as one line per field, deepest path first.
    static func render(_ node: Store.View.Node) -> String {
        var lines: [String] = []
        render(node, path: node.name.isEmpty ? [] : [node.name], into: &lines)
        return "\n" + lines.joined(separator: "\n")
    }

    private static func render(_ node: Store.View.Node, path: [String], into lines: inout [String]) {
        let prefix = path.isEmpty ? "" : path.joined(separator: ".") + "."
        for field in node.fields {
            lines.append("  \(prefix)\(field.name) = \(field.value)")
        }
        for child in node.children {
            render(child, path: path + [child.name], into: &lines)
        }
    }
}
