// exports.swift
// Re-export the reduction algebra this runtime interprets.
//
// The algebra is not an implementation detail: a consumer writes `Store.Update`
// and `Store.Effect` values and hands them here, so it belongs in this module's
// public surface. Nothing else is re-exported. In particular the keyed-tree
// primitive is an internal import throughout, because it re-exports a second,
// unrelated `Store` namespace and re-exporting it here would hand every consumer
// that ambiguity.

@_exported public import Store_Reduction_Primitives
