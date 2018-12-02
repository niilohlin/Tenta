//
// Created by Niil Öhlin on 2018-10-09.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation
@testable import Tenta
import XCTest

struct ComplexTest: Generatable {
    var firstName: String
    var lastName: String
    var age: Int
    var email: String
    var address: String
    var zipCode: String
    var sex: String

    static var generator: Generator<ComplexTest> {
        return Generator<ComplexTest> { size, rng in
            let firstName = String.generator.generateWithoutShrinking(size, &rng)
            let lastName = String.generator.generateWithoutShrinking(size, &rng)
            let age = Int.generator.generateWithoutShrinking(size, &rng)
            let email = String.generator.generateWithoutShrinking(size, &rng)
            let address = String.generator.generateWithoutShrinking(size, &rng)
            let zipCode = String.generator.generateWithoutShrinking(size, &rng)
            let sex = String.generator.generateWithoutShrinking(size, &rng)
            return RoseTree<ComplexTest>(root: {
                ComplexTest(
                        firstName: firstName,
                        lastName: lastName,
                        age: age,
                        email: email,
                        address: address,
                        zipCode: zipCode,
                        sex: sex
                )
            })
        }
    }
}

class GeneratorTests: XCTestCase {

    func testRunTest() {
        assert(generator: Generator<Int>.int, shrinksTo: 10, predicate: { (int: Int) in
            int < 10
        })
    }

    func testRunMoreComplicatedIntTest() {
        assert(generator: Generator<Int>.int, shrinksTo: 26, predicate: { int in
            int < 21 || int % 2 == 1
        })
    }

    func testRunArray() {
        let intGenerator: Generator<Int> = Generator<Int>.int
        assert(
                generator: Generator<Int>.array(elementGenerator: intGenerator),
                shrinksTo: [],
                isEqual: { arr, _ in arr.count == 20 },
                predicate: { array in array.count < 20 }
        )
    }

    func testFilterGenerator() {
        let positiveEvenGenerator = Generator<Int>.int.filter { int in
            (int > 0 && int % 2 == 0)
        }
        runTest(gen: positiveEvenGenerator) { positiveEven in
            XCTAssert(positiveEven > 0)
            XCTAssert(positiveEven % 2 == 0)
            return positiveEven > 0 && positiveEven % 2 == 0
        }
    }

    func testRunTestWithDefaultGenerator() {
        runTest { (_: Int) in
            true
        }
    }

    struct Point: Equatable {
        var x: Int
        var y: Int
    }

    func testCombine() {
        let pointGenerator = Int.generator.combine(with: Int.generator) { x, y in
            Point(x: x, y: y)
        }

        assert(generator: pointGenerator, shrinksTo: Point(x: 0, y: 20), predicate: { (point: Point) in
            point.y < 20
        })
    }

    func testInternallyShrinkingArray() {
        // This is why we do not shrink the elements in the array. The shrink tree _really_ explodes.
        let arrayOfGeneratorsGenerator = Int.generator.map {
            [Generator<Int>](repeating: Int.generator, count: abs($0))
        }

        let arrayGeneratorWithInternalIntShrinks = Generator<[Int]> { size, rng in
            let treeOfGenerators = arrayOfGeneratorsGenerator.generate(size, &rng)
            let treeOfInts = treeOfGenerators.flatMap { (generators: [Generator<Int>]) -> RoseTree<[Int]> in
                let forest: [RoseTree<Int>] = generators.map { (generator: Generator<Int>) in
                    generator.generate(size, &rng)
                }
                return RoseTree<[Int]>.combine(forest: forest)
            }
            return treeOfInts
        }
        assert(
            generator: arrayGeneratorWithInternalIntShrinks,
            shrinksTo: [2, 2, 2, 0],
            predicate: { (integers: [Int]) in integers.count < 3 }
        )
    }

    func testShrinkDouble() {
        assert(generator: Generator<Double>.double, shrinksTo: 5, isEqual: { abs($0 - $1) < 0.01 }, predicate: {
            $0 < 5
        })
    }

    func testGenerateFromSequence() {
        let letters = "abcdefghijklmnopqrstuvwxyz"
        let letterGenerator = Generator<Character>.element(from: letters)
        assert(generator: letterGenerator, shrinksTo: Character("l"), predicate: { character in
            !"lmnopqrstuvwxyz".contains(character)
        })
    }

    func testGenerateCharacter() {
        runTest { (char: Character) in
            !String(char).isEmpty
        }
    }

    func testGenerateStrings() {
        runTest { (_: String) in
            true
        }
    }

    func testShrinkStrings() {
        assert(generator: String.generator, shrinksTo: "a", predicate: { (string: String) in
            !string.contains(Character("a"))
        })
    }

    func testComplexTest() {
        runTest { (_: ComplexTest) in
            true //!complex.firstName.contains(Character("a"))
        }
    }

    func testBool() {
        assert(generator: Bool.generator, shrinksTo: false, predicate: { (bool: Bool) in
            bool
        })
    }

    func testOptional() {
        assert(generator: Int?.generator, shrinksTo: 4, predicate: { (int: Int?) -> Bool in
            int.map { $0 != 4 } ?? true
        })
    }

    func testSimpleGenerator() {
        let generator = Generator.simple { constructor -> ComplexTest in
            let firstName = String.generator.generate(using: &constructor)
            let lastName = String.generator.generate(using: &constructor)
            let age = Int.generator.generate(using: &constructor)
            let email = String.generator.generate(using: &constructor)
            let address = String.generator.generate(using: &constructor)
            let zipCode = String.generator.generate(using: &constructor)
            let sex = String.generator.generate(using: &constructor)
            return ComplexTest(
                    firstName: firstName,
                    lastName: lastName,
                    age: age,
                    email: email,
                    address: address,
                    zipCode: zipCode,
                    sex: sex
            )
        }

        runTest(gen: generator) { (_: ComplexTest) in
            true
        }
    }

    func testGenerateSet() {
        assert(generator: Set<Int>.generator, shrinksTo: Set([5]), predicate: { set in
            !set.contains(5)
        })
    }

    struct DummyError: Error {
    }
    func testFunctionThatThrows() {
        assert(generator: Int.generator, shrinksTo: 5, predicate: { (int: Int) in
            if int == 5 {
                throw DummyError()
            }
            return true
        })
    }

    func testGenerateNonEmpty() {
        let nonEmpty = Int.generator.generateMany().nonEmpty()
        runTest(gen: nonEmpty) { (integers: [Int]) in
            !integers.isEmpty
        }
    }

    func testGenerateArity2() {
        runTest { (int: Int, string: String) in
            !(String(describing: int) + string).isEmpty
        }
    }

    func testGenerateManyNonEmpty() {
        assert(generator: Int.generator.generateManyNonEmpty(), shrinksTo: [5], predicate: { (integers: [Int]) in
            XCTAssert(!integers.isEmpty)
            return !integers.contains(5)
        })
    }

    func testGenerateAlphaNumeric() {
        runTest(gen: Generator<String>.alphaNumeric) { (string: String) in
            string.allSatisfy("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890".contains)
        }
    }

    func testDefaultGeneratorTransform() {
        let intAndString = Int.generator.combine(with: String.generator)
        runTest(gen: intAndString) { int, string in
            (String(describing: int) + string).count >= string.count
        }

    }

    func assert<T: Equatable>(
            generator: Generator<T>,
            shrinksTo minimumFailing: T,
            predicate: @escaping (T) throws -> Bool,
            file: StaticString = #file,
            line: UInt = #line) {
        assert(generator: generator, shrinksTo: minimumFailing, isEqual: (==), predicate: predicate)
    }

    func assert<T>(
            generator: Generator<T>,
            shrinksTo minimumFailing: T,
            isEqual: (T, T) -> Bool,
            predicate: @escaping (T) throws -> Bool,
            file: StaticString = #file,
            line: UInt = #line) {
        guard let value = generator.runAndReturnShrink(with: predicate) else {
            XCTFail("Generator did not fail", file: file, line: line)
            return
        }
        XCTAssert(
                isEqual(value, minimumFailing),
                "Generator did not shrink to \(minimumFailing), but \(value)",
                file: file,
                line: line
        )
    }
}

extension Generator {
    func runAndReturnShrink(with predicate: @escaping (ValueToTest) throws -> Bool) -> ValueToTest? {
        var rng = SeededRandomNumberGenerator(seed: 100)

        func runPredicate(_ value: ValueToTest) -> Bool {
            do {
                return try predicate(value)
            } catch {
                return false
            }
        }

        for size in 0..<UInt(100) {
            let rose = generate(size, &rng)
            if !runPredicate(rose.root()) {
                return rose.shrink(predicate: runPredicate)
            }
        }
        return nil
    }
}
