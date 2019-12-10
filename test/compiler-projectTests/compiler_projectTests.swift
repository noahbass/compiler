import XCTest
@testable import compilerproject

final class compilerprojectTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual("Hello, World!", "Hello, World!")
    }
    
    func testPlusDFA() {
        let input = "+"
        let dfa = PlusDFA()
        var currentState: DFAState? = nil
        
        for character in input {
            currentState = dfa.nextMove(character: character)
        }
        
        XCTAssertTrue(currentState!.isFinalState)
    }
    
    func testMinusDFA() {
        let input = "-"
        let dfa = MinusDFA()
        var currentState: DFAState? = nil
        
        for character in input {
            currentState = dfa.nextMove(character: character)
        }
        
        XCTAssertTrue(currentState!.isFinalState)
    }
    
    func testAssignDFA() {
        let input = ":="
        let dfa = AssignDFA()
        var currentState: DFAState? = nil
        
        for character in input {
            currentState = dfa.nextMove(character: character)
        }
        
        XCTAssertTrue(currentState!.isFinalState)
    }
    
    func testEqualDFA() {
        let input = "=="
        let dfa = EqualDFA()
        var currentState: DFAState? = nil
        
        for character in input {
            currentState = dfa.nextMove(character: character)
        }
        
        XCTAssertTrue(currentState!.isFinalState)
    }
    
    func testIfDFA() {
        let input = "if"
        let dfa = IfDFA()
        var currentState: DFAState? = nil
        
        for character in input {
            currentState = dfa.nextMove(character: character)
        }
        
        XCTAssertTrue(currentState!.isFinalState)
    }
    
    func testWhileDFA() {
        let input = "while"
        let dfa = WhileDFA()
        var currentState: DFAState? = nil
        
        for character in input {
            currentState = dfa.nextMove(character: character)
        }
        
        XCTAssertTrue(currentState!.isFinalState)
    }
    
    func testForDFA() {
        let input = "for"
        let dfa = ForDFA()
        var currentState: DFAState? = nil
        
        for character in input {
            currentState = dfa.nextMove(character: character)
        }
        
        XCTAssertTrue(currentState!.isFinalState)
    }
    
    func testReturnDFA() {
        let input = "return"
        let dfa = ReturnDFA()
        var currentState: DFAState? = nil
        
        for character in input {
            currentState = dfa.nextMove(character: character)
        }
        
        XCTAssertNotNil(currentState)
        XCTAssertTrue(currentState!.isFinalState)
    }
    
    func testIdentifierDFA() {
        let input = "helloWorld123"
        let dfa = IdentifierDFA()
        var currentState: DFAState? = nil
        
        for character in input {
            currentState = dfa.nextMove(character: character)
        }
        
        XCTAssertNotNil(currentState)
        XCTAssertTrue(currentState!.isFinalState)
    }
    
    func testCommentDFA() {
        let input = "// this is ()only a % test =\t    123\n"
        let dfa = CommentDFA()
        var currentState: DFAState? = nil
        
        for character in input {
            currentState = dfa.nextMove(character: character)
        }
        
        XCTAssertNotNil(currentState)
        XCTAssertTrue(currentState!.isFinalState)
    }

    static var allTests = [
        ("testExample", testExample),
        ("testPlusDFA", testPlusDFA)
    ]
}
