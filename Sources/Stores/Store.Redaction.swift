public import Store_Reduction_Primitives

extension Store {
    /// Which fields a state view withholds.
    ///
    /// A test asserts against a rendered view rather than against the state itself,
    /// and some of what a state holds is not worth asserting on — a timestamp, a
    /// generated identifier, a value that legitimately differs run to run. Naming
    /// those once and withholding them everywhere they appear keeps the assertion
    /// about what the test is actually testing, and keeps it from failing for a
    /// reason nobody cares about.
    ///
    /// Withholding replaces the value and keeps the field, so a field that
    /// disappears entirely still fails the assertion. That distinction is the point:
    /// "this changed in a way I do not care about" and "this is gone" are different
    /// facts and a redaction that conflated them would hide the second.
    ///
    /// ## Example
    ///
    /// ```swift
    /// runtime.view(redacting: .withholding("requestID", "loadedAt"))
    /// ```
    public struct Redaction: Sendable, Equatable {
        /// The field names withheld wherever they appear.
        public let fields: Swift.Set<String>

        /// Creates a redaction withholding the given field names.
        ///
        /// - Parameter fields: The field names to withhold.
        public init(fields: Swift.Set<String>) {
            self.fields = fields
        }
    }
}

extension Store.Redaction {
    /// A redaction that withholds nothing.
    public static var nothing: Self {
        .init(fields: [])
    }

    /// A redaction withholding the named fields.
    ///
    /// - Parameter fields: The field names to withhold.
    public static func withholding(_ fields: String...) -> Self {
        .init(fields: Swift.Set(fields))
    }

    /// Whether `field` is withheld.
    ///
    /// - Parameter field: The field name to test.
    public func withholds(_ field: String) -> Bool {
        fields.contains(field)
    }
}
