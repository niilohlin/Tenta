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
            return RoseTree<ComplexTest>(root:
                ComplexTest(
                        firstName: firstName,
                        lastName: lastName,
                        age: age,
                        email: email,
                        address: address,
                        zipCode: zipCode,
                        sex: sex
                )
            )
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
        runTest(generator: positiveEvenGenerator) { positiveEven in
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

    func testGenerateElement_withSize() {
        let generator = Generator<Character>.element(from: 0..<100)
        var rng = SeededRandomNumberGenerator(seed: 100)
        let value = generator.generate(100, &rng).root()
        XCTAssertNotEqual(value, 0, "Element should respect size")
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
            let firstName = String.generate(using: &constructor)
            let lastName = String.generate(using: &constructor)
            let age = Int.generate(using: &constructor)
            let email = String.generate(using: &constructor)
            let address = String.generate(using: &constructor)
            let zipCode = String.generate(using: &constructor)
            let sex = String.generate(using: &constructor)
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

        runTest(generator: generator) { (_: ComplexTest) in
            true
        }
    }

    func testOneOfGenerator() {
        let int = Int.generate()
        XCTAssertEqual(int, int)
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
        runTest(generator: nonEmpty) { (integers: [Int]) in
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
        runTest(generator: Generator<String>.alphaNumeric) { (string: String) in
            string.allSatisfy("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890".contains)
        }
    }

    func testDefaultGeneratorTransform() {
        let intAndString = Int.generator.combine(with: String.generator)
        runTest(generator: intAndString) { int, string in
            (String(describing: int) + string).count >= string.count
        }

    }

    func testFlatMap_shrinks() {
        let stringGen = Int.generator.flatMap { int -> Generator<String> in
            String.generator.map { string in
                String(describing: int) + string
            }
        }

        assert(generator: stringGen, shrinksTo: "-1", predicate: { (string: String) in
            !string.starts(with: "-")
        })
    }

    // Should work when fixed proper shrinking.
    func disabled_testFlatMap_otherWay_shrinks() {
        let stringGen = Int.generator.flatMap { int -> Generator<String> in
            Generator<String>.alphaNumeric.map { string in
                String(describing: int) + string
            }
        }

        assert(generator: stringGen, shrinksTo: "0a", predicate: { (string: String) in
            !string.contains(Character("a"))
        })
    }

    func assert<T: Equatable>(
            generator: Generator<T>,
            shrinksTo minimumFailing: T,
            predicate: @escaping (T) throws -> Bool,
            file: StaticString = #file,
            line: UInt = #line) {
        assert(
                generator: generator,
                shrinksTo: minimumFailing,
                isEqual: (==),
                predicate: predicate,
                file: file,
                line: line
        )
    }

    func assert<T>(
            generator: Generator<T>,
            shrinksTo minimumFailing: T,
            isEqual: (T, T) -> Bool,
            predicate: @escaping (T) throws -> Bool,
            file: StaticString = #file,
            line: UInt = #line) {
        let property = Property(generator: generator, seed: seed, numberOfTests: numberOfTests, predicate: predicate)
        guard let value = property.checkProperty() else {
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
