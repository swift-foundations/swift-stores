internal import Effects
public import Store_Reduction_Primitives

extension Store.Runtime {
    /// Advances ``state`` by `action`, then performs whatever the reduction asked for.
    ///
    /// Sending is not reentrant. An action sent from inside a reduction — which is
    /// what an effect's ``Store/Effect/send(_:)`` amounts to — is buffered and
    /// reduced after the one in progress, in the order it arrived.
    ///
    /// - Parameter action: The action to apply.
    public func send(_ action: Action) {
        _pending.post(action)
        guard !_reducing else { return }

        _reducing = true
        defer { _reducing = false }

        while let next = _pending.next() {
            let effect = scope.run { self.update.effect(for: next, in: &self.state) }
            begin(effect)
        }
    }
}

// MARK: - Interpreting effects

extension Store.Runtime {
    /// Starts whatever `effect` asked for.
    ///
    /// A bare `send` is folded straight into the buffer rather than started as work:
    /// it needs nothing performed, and routing it through a task would make an
    /// otherwise synchronous reduction observably asynchronous.
    func begin(_ effect: Store.Effect<Action, Store.Work<Action>>) {
        switch effect {
        case .none:
            return

        case .send(let action):
            _pending.post(action)

        case .run, .merge, .sequence:
            start(effect)
        }
    }

    /// Puts `effect` in flight and records it so it can be reported and stopped.
    private func start(_ effect: Store.Effect<Action, Store.Work<Action>>) {
        let ticket = mintTicket()
        let send = sender()
        let cancellation = Self.cancellation(of: effect)

        let task = Task { [weak self] in
            await Self.execute(effect, send: send)
            guard let self else { return }
            await retire(ticket, isolation: isolation)
        }

        _inFlight.record(.init(cancellation: cancellation, task: task), as: ticket)
    }

    /// Performs `effect`, honouring what each combinator promised: `merge` places
    /// its children side by side, `sequence` runs them one after another.
    private static func execute(
        _ effect: Store.Effect<Action, Store.Work<Action>>,
        send: Store.Send<Action>
    ) async {
        switch effect {
        case .none:
            return

        case .send(let action):
            await send(action)

        case .run(let work):
            let body = work.body
            await Effect.perform(Store.Job { await body(send) })

        case .merge(let effects):
            await withTaskGroup(of: Void.self) { group in
                for effect in effects {
                    group.addTask { await Self.execute(effect, send: send) }
                }
            }

        case .sequence(let effects):
            for effect in effects {
                await Self.execute(effect, send: send)
            }
        }
    }

    /// The name a whole effect can be stopped under, when it has exactly one.
    private static func cancellation(
        of effect: Store.Effect<Action, Store.Work<Action>>
    ) -> Store.Cancellation.ID? {
        guard case .run(let work) = effect else { return nil }
        return work.cancellation
    }
}

// MARK: - Feeding actions back

extension Store.Runtime {
    /// A way for running work to feed actions back into this runtime.
    func sender() -> Store.Send<Action> {
        Store.Send { [weak self] action in
            guard let self else { return }
            await accept(action, isolation: isolation)
        }
    }

    // REASON: `isolated (any Actor)?` is the language's only spelling for an isolated-actor
    // REASON: parameter — there is no generic form — and it performs an executor hop rather
    // REASON: than dynamic dispatch.
    /// Receives `action` back on this runtime's own isolation.
    ///
    /// The isolated parameter is what performs the hop: work may run anywhere, and
    /// this is where it comes home before touching state.
    private func accept(_ action: Action, isolation: isolated (any Actor)?) async {  // swiftlint:disable:this no_any_protocol_existential
        send(action)
    }

    // REASON: `isolated (any Actor)?` is the language's only spelling for an isolated-actor
    // REASON: parameter — there is no generic form — and it performs an executor hop rather
    // REASON: than dynamic dispatch.
    /// Stops recording the work under `ticket`.
    private func retire(_ ticket: UInt64, isolation: isolated (any Actor)?) async {  // swiftlint:disable:this no_any_protocol_existential
        _inFlight.discard(ticket)
    }

    private func mintTicket() -> UInt64 {
        _nextTicket += 1
        return _nextTicket
    }
}

// MARK: - Stopping work

extension Store.Runtime {
    /// Whether any work is still in flight.
    public var isSettled: Bool {
        _inFlight.isEmpty && _pending.isEmpty
    }

    /// The names of the work currently in flight, oldest first.
    public var inFlight: [Store.Cancellation.ID] {
        var result: [Store.Cancellation.ID] = []
        _inFlight.forEach { _, record in
            if let cancellation = record.cancellation { result.append(cancellation) }
        }
        return result
    }

    /// Stops every unit of work running under `id`.
    ///
    /// - Parameter id: The name the work was started under.
    public func cancel(_ id: Store.Cancellation.ID) {
        var doomed: [UInt64] = []
        _inFlight.forEach { ticket, record in
            if record.cancellation == id { doomed.append(ticket) }
        }
        for ticket in doomed {
            _inFlight.discard(ticket)?.task.cancel()
        }
    }

    /// Stops every unit of work this runtime has in flight.
    public func cancelAll() {
        for ticket in _inFlight.tickets {
            _inFlight.discard(ticket)?.task.cancel()
        }
    }
}
