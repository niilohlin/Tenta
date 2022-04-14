import Tenta
import XCTest

///: Lets start with some generators and generator combinators.

extension AnyGenerator {
    func sample() -> ValueToTest {
        var constructor = Constructor(size: 10)
        return generateUsing(&constructor)
    }
}

// Some default generators.

Int.generator.sample()

Character.generator.sample()

[Int].generator.sample()

Generator<String>.evil().generateMany().sample()

// Create a custom type.
struct Person {
    let name: String
    let age: Int
}

// Conform it to Generatable by creating a default generator.
extension Person: Generatable {
    public static var generator: AnyGenerator<Person> {
        return String.generator.combine(with: Int.generator) { name, age in
            return Person(name: name, age: age)
        }
    }
}

print("\(Person.generator.sample())")

///: Let's say we have an email-verifier. A common regex for this is:
extension String {
    var isValidEmail: Bool {
        let regex = try! NSRegularExpression(pattern: "^[^@^\\s]+@[a-zA-Z0-9._-]+\\.[a-zA-Z]+$", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
}

///: And we have some tests for this
class EmailRegexTests: XCTestCase {
    func testValidEmail() {
        XCTAssert("test@gmail.com".isValidEmail)
    }

    func testInValidEmail() {
        XCTAssertFalse("test@test@gmail.com".isValidEmail)
    }
}
EmailRegexTests.defaultTestSuite.run()

///: let's try to generate these test with tenta instead.

class GeneratedEmailTests: XCTestCase {

    override func setUp() {
        super.setUp()
        self.numberOfTests = 10
        self.seed = 3047253
    }

    // Let's start with creating a generator for valid emails.
    var validEmailGenerator: AnyGenerator<String> {
        // Generates strings like "a", "aa.b", "aaa.bbb.ccc"
        let localPart = AnyGenerator<String>
            .alphaNumeric // generates containing only alphanumeric strings. e.g "", "aaa", "bb254cONE"
            .nonEmpty()   // remove the empty strings.
            .generateManyNonEmpty() // generates a non empty list of those strings e.g. ["aa", "bb", "c"]
            .map { (strings: [String]) -> String in
            strings.joined(separator: ".")
        }

        // Same rules apply for the domain.
        let domain = localPart

        // Generate Either "se", "com", "io"
        let topLevelDomain: AnyGenerator<String> = AnyGenerator<[String]>.element(from: ["se", "com", "io"])

        return AnyGenerator<String>.combine(localPart, domain, topLevelDomain) { (local, domain, tld) -> String in
            local + "@" + domain + "." + tld
        }
    }

    func testValidEmail() {
        testProperty(generator: validEmailGenerator) { email in
            print("email: \(email) is \(email.isValidEmail ? "valid" : "invalid")")
            return email.isValidEmail
        }
    }

    // Ok That seems to work fine. Let's test som invalid emails.
    func testInvalidEmail() {
        testProperty { (email: String) in
            print("email: \(email) is \(email.isValidEmail ? "valid" : "invalid")")
            return !email.isValidEmail
        }
    }
}

GeneratedEmailTests.defaultTestSuite.run()
