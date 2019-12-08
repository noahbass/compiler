import XCTest
@testable import compilerproject

final class compilerprojectTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual("Hello, World!", "Hello, World!")
    }
    
    func testFunc() {
        let dfa = EqualDFA()
        
        let input = "=="
        
//        for character in input {
            let c = Character("=")
            let state = dfa.nextMove(character: c)
            
            print(state)
//        }
        
        XCTAssertEqual("foo", "foo")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
