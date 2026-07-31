/// Bookkeeping for the features a runtime currently has mounted.
///
/// This namespace is deliberately outside the ``Store`` namespace and imports no
/// module that publishes a `Store` of its own. The keyed-tree primitive re-exports
/// the physical element-store substrate's `Store` namespace, and the reduction
/// algebra publishes another; keeping the two apart file by file is the
/// disambiguation the coexistence ruling anticipated, and it costs nothing here
/// because this bookkeeping is generic over its node and needs neither namespace.
enum Registry {}
