import XCTest
@testable import compilerproject

final class compilerprojectTests: XCTestCase {
    let testFolderPath = URL(fileURLWithPath: #file).pathComponents
        .prefix(while: { $0 != "Tests" }).dropLast().joined(separator: "/").dropFirst() // Path for tests directory
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual("Hello, World!", "Hello, World!")
    }
    
    func testSimpleTokenStream1() {
        let filePath = String(testFolderPath + "/scanner-test-input-1.txt")
        let scanner = FAScanner(fileName: filePath)
        
        // Ensure scanner outputs the correct token types and values in the correct order
        let expectedTokens = [
            Token(type: .t_semicolon, lexeme: ";"),
            Token(type: .t_assign, lexeme: ":="),
            Token(type: .t_comma, lexeme: ","),
            Token(type: .t_identifier, lexeme: "5")
        ]
        
        var realTokens: [Token] = []
        var token = scanner.getToken()
        while token.type != .t_end_of_file {
            realTokens += [token]
            token = scanner.getToken()
        }
        
        // Assert each token is what is expected
        XCTAssertEqual(expectedTokens.count, realTokens.count)
        
        for i in 0...(realTokens.count - 1) {
            XCTAssertEqual(expectedTokens[i].type, realTokens[i].type)
            XCTAssertEqual(expectedTokens[i].lexeme, realTokens[i].lexeme)
        }
    }
    
    func testSimpleTokenStream2() {
        let filePath = String(testFolderPath + "/scanner-test-input-2.txt")
        let scanner = FAScanner(fileName: filePath)
        
        // Ensure scanner outputs the correct token types and values in the correct order
        let expectedTokens = [
            Token(type: .t_identifier, lexeme: "b"),
            Token(type: .t_assign, lexeme: ":="),
            Token(type: .t_identifier, lexeme: "3"),
            Token(type: .t_semicolon, lexeme: ";"),
            Token(type: .t_identifier, lexeme: "y"),
            Token(type: .t_assign, lexeme: ":="),
            Token(type: .t_identifier, lexeme: "b"),
            Token(type: .t_semicolon, lexeme: ";"),
            Token(type: .t_identifier, lexeme: "a"),
            Token(type: .t_assign, lexeme: ":="),
            Token(type: .t_identifier, lexeme: "3"),
            Token(type: .t_semicolon, lexeme: ";"),
            Token(type: .t_identifier, lexeme: "a"),
            Token(type: .t_assign, lexeme: ":="),
            Token(type: .t_identifier, lexeme: "f"),
            Token(type: .t_left_paren, lexeme: "("),
            Token(type: .t_identifier, lexeme: "3"),
            Token(type: .t_right_paren, lexeme: ")"),
            Token(type: .t_semicolon, lexeme: ";")
        ]
        
        var realTokens: [Token] = []
        var token = scanner.getToken()
        while token.type != .t_end_of_file {
            realTokens += [token]
            token = scanner.getToken()
        }
        
        // Assert each token is what is expected
        XCTAssertEqual(expectedTokens.count, realTokens.count)
        
        for i in 0...(realTokens.count - 1) {
            XCTAssertEqual(expectedTokens[i].type, realTokens[i].type)
            XCTAssertEqual(expectedTokens[i].lexeme, realTokens[i].lexeme)
        }
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

    func testVariableDFA() {
        let input = "variable"
        let dfa = VariableDFA()
        var currentState: DFAState? = nil
        
        for character in input {
            currentState = dfa.nextMove(character: character)
        }
        
        XCTAssertTrue(currentState!.isFinalState)
    }
    
    func testIntegerDFA() {
        let input = "integer"
        let dfa = IntegerDFA()
        var currentState: DFAState? = nil
        
        for character in input {
            currentState = dfa.nextMove(character: character)
        }
        
        XCTAssertTrue(currentState!.isFinalState)
    }
    
    func testBoolDFA() {
        let input = "bool"
        let dfa = BoolDFA()
        var currentState: DFAState? = nil
        
        for character in input {
            currentState = dfa.nextMove(character: character)
        }
        
        XCTAssertTrue(currentState!.isFinalState)
    }
    
    func testGlobalDFA() {
        let input = "global"
        let dfa = GlobalDFA()
        var currentState: DFAState? = nil
        
        for character in input {
            currentState = dfa.nextMove(character: character)
        }
        
        XCTAssertTrue(currentState!.isFinalState)
    }
    
    func testBeginDFA() {
        let input = "begin"
        let dfa = BeginDFA()
        var currentState: DFAState? = nil
        
        for character in input {
            currentState = dfa.nextMove(character: character)
        }
        
        XCTAssertTrue(currentState!.isFinalState)
    }
    
    func testEndDFA() {
        let input = "end"
        let dfa = EndDFA()
        var currentState: DFAState? = nil
        
        for character in input {
            currentState = dfa.nextMove(character: character)
        }
        
        XCTAssertTrue(currentState!.isFinalState)
    }
    
    func testProgramDFA() {
        let input = "program"
        let dfa = ProgramDFA()
        var currentState: DFAState? = nil
        
        for character in input {
            currentState = dfa.nextMove(character: character)
        }
        
        XCTAssertTrue(currentState!.isFinalState)
        
        let badInput = "progamm"
        dfa.reset()
        currentState = nil
        
        for character in badInput {
            currentState = dfa.nextMove(character: character)
        }
        
        XCTAssertTrue(currentState == nil)
    }
    
    func testEndProgramDFA1() {
        let input = "end program."
        let dfa = EndProgramDFA()
        var currentState: DFAState? = nil
        
        for character in input {
            currentState = dfa.nextMove(character: character)
        }
        
        XCTAssertTrue(currentState!.isFinalState)
    }
    
    func testEndProgramDFA2() {
        let input = "end program ."
        let dfa = EndProgramDFA()
        var currentState: DFAState? = nil
        
        for character in input {
            currentState = dfa.nextMove(character: character)
        }
        
        XCTAssertTrue(currentState!.isFinalState)
    }

    func testIsDFA() {
        let input = "is"
        let dfa = IsDFA()
        var currentState: DFAState? = nil
        
        for character in input {
            currentState = dfa.nextMove(character: character)
        }
        
        XCTAssertTrue(currentState!.isFinalState)
    }
    
    func testProcedureDFA() {
        let input = "procedure"
        let dfa = ProcedureDFA()
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
    
    func testElseDFA() {
        let input = "else"
        let dfa = ElseDFA()
        var currentState: DFAState? = nil
        
        for character in input {
            currentState = dfa.nextMove(character: character)
        }
        
        XCTAssertTrue(currentState!.isFinalState)
    }
    
    func testThenDFA() {
        let input = "then"
        let dfa = ThenDFA()
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
