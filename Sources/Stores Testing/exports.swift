// exports.swift
// Re-export the runtime being tested. A test writes against both surfaces in the
// same file, so importing one and not the other is never what anyone wants.

@_exported public import Stores
