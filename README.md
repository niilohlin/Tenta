![build status](https://travis-ci.com/niilohlin/Tenta.svg?branch=master)

# Tenta
Tenta is a property based testing framework for Swift, in development.
Tenta is Swedish slang for "Test" typically in a University setting.

## Examples

```swift
    // Assert that the reverse of any array keeps its length.
    let intGenerator: Generator<Int> = Generator<Int>.int()
    runTest { (array: [Int]) in
        array.count == array.reversed().count
    }

```

## Design goals/philosophy

Tenta should be:

* Easy to understand.
* Easy to read.
* Provide sensible defaults.
* Have clear documentation driven by examples.
* Avoid unnecessary generalizations.
* Avoid the "M"-word (no Monads or Functors).
* Avoid custom operators
* Integrate well with XCTest.
