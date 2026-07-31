public import Store_Reduction_Primitives

extension Store.View {
    /// One named value in a rendered state view.
    public struct Field: Sendable, Hashable {
        /// The field's name.
        public let name: String

        /// The field's rendered value, or the withholding marker if redacted.
        public let value: String

        /// Creates a field.
        ///
        /// - Parameters:
        ///   - name: The field's name.
        ///   - value: The field's rendered value.
        public init(_ name: String, _ value: String) {
            self.name = name
            self.value = value
        }
    }
}

extension Store.View.Field {
    /// The value a withheld field renders as.
    public static let withheld: String = "<withheld>"

    /// This field with its value withheld.
    public var redacted: Self {
        .init(name, Self.withheld)
    }
}
