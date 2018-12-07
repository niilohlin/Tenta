//
// Created by Niil Öhlin on 2018-12-06.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation

struct FiniteStateMachine<Model, Transition> {
    let initializeModel: () -> Model
    let transitions: Generator<Transition>
    let precondition: (Model, Transition) -> Bool
    let postcondition: (Model, Transition) -> Bool
    let runTransition: (Model, Transition) -> Model

    init(
            initializeModel: @escaping () -> Model,
            transitions: Generator<Transition>,
            precondition: @escaping (Model, Transition) -> Bool = { _, _ in true },
            postcondition: @escaping (Model, Transition) -> Bool = { _, _ in true },
            runTransition: @escaping (Model, Transition) -> Model
    ) {
        self.initializeModel = initializeModel
        self.transitions = transitions
        self.precondition = precondition
        self.postcondition = postcondition
        self.runTransition = runTransition
    }

    func transition(for model: Model) -> Generator<Transition> {
        return transitions.filter { self.precondition(model, $0) }
    }

    func generateTransitions() -> Generator<[Transition]> {
        fatalError("not implemented yet")
//        let initialModel = initializeModel()
//        let modelGenerator = transition(for: initialModel).map { transition -> Model in
//            self.runTransition(initialModel, transition)
//        }
//
//        let newModel = runTransition(initialModel, transition(for: initialModel))
//        if newModel.

    }

    func property() {
    }
}
