//
// Created by Niil Öhlin on 2018-12-06.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation

protocol StateMachine {
    associatedtype State
    associatedtype Transition
    var initialState: State { get }
    var allTransitions: [Transition] { get }
    func isValidTransitions(_ transitions: [Transition]) -> Bool
    // execute
}
