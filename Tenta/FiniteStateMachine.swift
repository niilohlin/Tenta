//
// Created by Niil Öhlin on 2018-12-10.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation
import XCTest

public protocol StateMachine {
    associatedtype State
    associatedtype Command

    static var initialState: State { get }

    static var command: Generator<Command> { get }

    static func precondition(_: State, _: Command) -> Bool
    static func postcondition(_: State, _: Command) -> Bool

    static func nextState(_: State, _: Command) -> State
}

extension StateMachine {
    static func precondition(_: State, _: Command) -> Bool {
        return true
    }

    static func postcondition(_: State, _: Command) -> Bool {
        return true
    }

    static func commands(initial: State = Self.initialState) -> Generator<[Command]> {
        return Generator<[Command]>.withSize { size in
            Self.commands(size: size, state: initial, count: 1)
        }
    }

    private static func commands(size: UInt, state: State, count: UInt) -> Generator<[Command]> {
        return Generator<[Command]>.chooseGeneratorFrom([
            (1, Generator(value: [])),
            (Int(size), Self.command.filter { Self.precondition(state, $0) }.flatMap { cmd -> Generator<[Command]> in
                let next = Self.nextState(state, cmd)
                return commands(size: max(size - 1, 0), state: next, count: count + 1).map {
                    [cmd] + $0
                }
            })
        ])
    }
}

public extension XCTestCase {
    func runStateMachine<StateMachineType: StateMachine>(of type: StateMachineType.Type) {
        runTest(generator: type.commands()) { (commands: [StateMachineType.Command]) in
            var state = StateMachineType.initialState
            for command in commands {
                state = type.nextState(state, command)
                if !type.postcondition(state, command) {
                    return false
                }
            }
            return true
        }
    }
}
