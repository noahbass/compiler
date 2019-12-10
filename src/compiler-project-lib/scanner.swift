import Foundation

/**
 * Token types mapped to ascii values for single-character and multiple-character tokens
 */
enum TokenType {
    // general types
    case t_identifier
    
    // operators
    case t_plus
    case t_minus
    case t_divide
    case t_multiply
    
    // reserved words
    case t_semicolon // ;
    case t_comma // ,
    case t_left_curly_brace // {
    case t_right_curly_brace // }
    case t_left_bracket // <
    case t_right_bracket // >
    case t_left_paren // (
    case t_right_paren // )
    case t_assign // =
    case t_equal // ==
    case t_if
    case t_while
    case t_for
    case t_return
    
    // other useful tokens
    case t_end // marks the end of file
    case t_unknown // unrecognized token
    
    // ignore any useless characters (comments, whitespace, newlines, etc.)
    case t_ignore
}


struct Token {
    let type: TokenType // the 'part of speech' of the token
    let lexeme: String // the 'value' of the token (one or more characters than form a word is called a lexeme)
    let row: Int = 0 // TODO: where the token was encountered
    let column: Int = 0 // TODO: where the token was encountered
}

/**
 * A move in finite automata
 * Describes where to move when a character is read.
 */
struct Move {
    let character: Character
    let newState: DFAState
}

/**
 * A state in finite automata
 */
class DFAState {
    let id: Int
    var transitions: [Character: DFAState] // a hash map of characters to read and the corresponding state to move to
    let isFinalState: Bool
    
    init(id: Int, possibleMoves: [Character: DFAState] = [:], isFinalState: Bool = false) {
        self.id = id
        self.transitions = possibleMoves
        self.isFinalState = isFinalState
    }

    init(id: Int, isFinalState: Bool) {
        self.id = id
        self.transitions = [:]
        self.isFinalState = isFinalState
    }
    
    func addMove(character: Character, toState: DFAState) -> Void {
        transitions[character] = toState
    }
    
    /**
     * Get the next move in the DFA from this state given an input character.
     * Returns nil if there is no possible move for the given input.
     */
    func getMove(character: Character) -> DFAState? {
        // Lookup character in the hash map
        guard let newState = transitions[character] else {
            // No valid move found with the given character
            return nil
        }
        
        return newState
    }
}


/**
 * Representation of a Deterministic Finite Automata consisting of various states,
 * one of which is the start state, and at least one of which are final states.
 *
 * The hash map representation of the state diagram is more efficient than a
 * matrix representation: the matrix needs O(n^2) space while the hash map
 * needs just O(n) space. Lookups for possible moves are constant in both:
 * A lookup in a matrix for the next state is O(1), and in a hash map, the
 * lookup for the next state is also O(1) because the representation of
 * possible states from a state is also a hash map.
 */
class DFA {
    // A hash map of state id to state details: Each FAState includes what moves
    // are possible based on which character is read. Because we're looking
//    private var representation: [Int: DFAState] = [:]
    private var currentState: DFAState // begins at the start state
    private let startState: DFAState
    private let tokenType: TokenType // type of token that this DFA accepts
    
    init(startState: DFAState, tokenType: TokenType) {
        /*for state in states {
            let stateId = state.id
            representation[stateId] = state
        }*/
        
        // Always start at the start state
        //representation[startState.id] = startState
        self.startState = startState
        currentState = startState
        
        self.tokenType = tokenType
    }
    
    /**
     * Setup the DFA to begin reading a new input
     */
    func reset() -> Void {
        currentState = startState
    }
    
    /**
     * Checks if the current state of the DFA is a final state.
     */
    func isAcceptingState() -> Bool {
        return currentState.isFinalState
    }
    
    func getTokenType() -> TokenType {
        return tokenType
    }
    
    /**
     * Given a character, move to the next state if there is a valid state to move to.
     * The new state could be a final state (the caller can check with .isFinalState).
     */
    func nextMove(character: Character) -> DFAState? {
        guard let nextState = currentState.getMove(character: character) else {
            // No valid state to make a move to
            return nil
        }
        
        // Make move
        currentState = nextState
        
        // Return new state (it may be the final state - the caller can check with .isFinalState)
        return currentState
    }
}


class RightBracketDFA: DFA {
    init() {
        let qf = DFAState(id: 2, isFinalState: true)
        let q0 = DFAState(id: 1, possibleMoves: [">": qf], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_right_bracket)
    }
}

class LeftBracketDFA: DFA {
    init() {
        let qf = DFAState(id: 2, isFinalState: true)
        let q0 = DFAState(id: 1, possibleMoves: ["<": qf], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_left_bracket)
    }
}

class RightCurlyBraceDFA: DFA {
    init() {
        let qf = DFAState(id: 2, isFinalState: true)
        let q0 = DFAState(id: 1, possibleMoves: ["}": qf], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_right_curly_brace)
    }
}

class LeftCurlyBraceDFA: DFA {
    init() {
        let qf = DFAState(id: 2, isFinalState: true)
        let q0 = DFAState(id: 1, possibleMoves: ["{": qf], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_left_curly_brace)
    }
}

class RightParenDFA: DFA {
    init() {
        let qf = DFAState(id: 2, isFinalState: true)
        let q0 = DFAState(id: 1, possibleMoves: [")": qf], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_right_paren)
    }
}

class LeftParenDFA: DFA {
    init() {
        let qf = DFAState(id: 2, isFinalState: true)
        let q0 = DFAState(id: 1, possibleMoves: ["(": qf], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_left_paren)
    }
}

class CommaDFA: DFA {
    init() {
        let qf = DFAState(id: 2, isFinalState: true)
        let q0 = DFAState(id: 1, possibleMoves: [",": qf], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_comma)
    }
}

class SemicolonDFA: DFA {
    init() {
        let qf = DFAState(id: 2, isFinalState: true)
        let q0 = DFAState(id: 1, possibleMoves: [";": qf], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_semicolon)
    }
}

class WhitespaceDFA: DFA {
    init() {
        // accepts 1 or many whitespace characters
        let q0 = DFAState(id: 0, possibleMoves: [:], isFinalState: true)
        q0.addMove(character: " ", toState: q0)
        super.init(startState: q0, tokenType: .t_ignore)
    }
}

class NewlineDFA: DFA {
    init() {
        // accepts 1 or many "\n" (newline) characters
        let q0 = DFAState(id: 0, possibleMoves: [:], isFinalState: true)
        q0.addMove(character: "\n", toState: q0)
        super.init(startState: q0, tokenType: .t_ignore)
    }
}

class CommentDFA: DFA {
    // TODO: check if this DFA when a comment is at the end of a file with no "\n" character, just EOF
    init() {
        // accept a double slash (//), any characters after the slash, then a newline character
        let qf = DFAState(id: 3, isFinalState: true)
        
        // all ascii characters after the "//" should be read, stop when we get to a newline character
        let q2 = DFAState(id: 2, possibleMoves: [:], isFinalState: false)
        
        // add all possible self-looping moves from q2 to q2 (all possible ascii values)
        for n in 0...255 {
            let character = Character(UnicodeScalar(UInt32(n))!) // convert ascii code to character
            q2.addMove(character: character, toState: q2)
        }
        
        // modification to q2: "\n" should move to final state
        q2.addMove(character: "\n", toState: qf)
        
        let q1 = DFAState(id: 1, possibleMoves: ["/": q2], isFinalState: false)
        let q0 = DFAState(id: 0, possibleMoves: ["/": q1], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_ignore)
    }
}

class PlusDFA: DFA {
    init() {
        // this dfa has only two states: the start state and final accepting state
        let qf = DFAState(id: 2, isFinalState: true)
        let q0 = DFAState(id: 1, possibleMoves: ["+": qf], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_plus)
    }
}

class MinusDFA: DFA {
    init() {
        let qf = DFAState(id: 2, isFinalState: true)
        let q0 = DFAState(id: 1, possibleMoves: ["-": qf], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_minus)
    }
}

class MultiplyDFA: DFA {
    init() {
        let qf = DFAState(id: 2, isFinalState: true)
        let q0 = DFAState(id: 1, possibleMoves: ["*": qf], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_multiply)
    }
}

class DivideDFA: DFA {
    init() {
        let qf = DFAState(id: 2, isFinalState: true)
        let q0 = DFAState(id: 1, possibleMoves: ["/": qf], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_divide)
    }
}

class AssignDFA: DFA {
    init() {
        let qf = DFAState(id: 2, isFinalState: true)
        let q0 = DFAState(id: 1, possibleMoves: ["=": qf], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_assign)
    }
}

class EqualDFA: DFA {
    init() {
        let qf = DFAState(id: 3, isFinalState: true)
        let q1 = DFAState(id: 2, possibleMoves: ["=": qf], isFinalState: false)
        let q0 = DFAState(id: 1, possibleMoves: ["=": q1], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_equal)
    }
}

class IfDFA: DFA {
    init() {
        let q2 = DFAState(id: 3, isFinalState: true)
        let q1 = DFAState(id: 2, possibleMoves: ["f": q2], isFinalState: false)
        let q0 = DFAState(id: 1, possibleMoves: ["i": q1], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_if)
    }
}

class WhileDFA: DFA {
    init() {
        let q5 = DFAState(id: 6, isFinalState: true)
        let q4 = DFAState(id: 5, possibleMoves: ["e": q5], isFinalState: false)
        let q3 = DFAState(id: 4, possibleMoves: ["l": q4], isFinalState: false)
        let q2 = DFAState(id: 3, possibleMoves: ["i": q3], isFinalState: false)
        let q1 = DFAState(id: 2, possibleMoves: ["h": q2], isFinalState: false)
        let q0 = DFAState(id: 1, possibleMoves: ["w": q1], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_while)
    }
}

class ForDFA: DFA {
    init() {
        let qf = DFAState(id: 4, isFinalState: true)
        let q2 = DFAState(id: 3, possibleMoves: ["r": qf], isFinalState: false)
        let q1 = DFAState(id: 2, possibleMoves: ["o": q2], isFinalState: false)
        let q0 = DFAState(id: 1, possibleMoves: ["f": q1], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_for)
    }
}

class ReturnDFA: DFA {
    init() {
        let qf = DFAState(id: 6, isFinalState: true)
        let q5 = DFAState(id: 5, possibleMoves: ["n": qf], isFinalState: false)
        let q4 = DFAState(id: 5, possibleMoves: ["r": q5], isFinalState: false)
        let q3 = DFAState(id: 4, possibleMoves: ["u": q4], isFinalState: false)
        let q2 = DFAState(id: 3, possibleMoves: ["t": q3], isFinalState: false)
        let q1 = DFAState(id: 2, possibleMoves: ["e": q2], isFinalState: false)
        let q0 = DFAState(id: 1, possibleMoves: ["r": q1], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_return)
    }
}

class IdentifierDFA: DFA {
    init() {
        // This DFA has a single accepting state that accepts any number of
        // characters 0-9, a-z, and A-Z in any order.
        let q0 = DFAState(id: 0, possibleMoves: [:], isFinalState: true) // start state
        
        // accept any number of digits 0-9 (every state is a final state)
        for n in 0...9 {
            let character = Character(String(n))
            
            // Add self-looping transitions from q0 to q0
            q0.addMove(character: character, toState: q0)
        }
        
        // accept any number of strings a-z
        let aCharacterScalar = "a".unicodeScalars
        let aCode = aCharacterScalar[aCharacterScalar.startIndex].value

        for n in 0...25 {
            let character = Character(String(UnicodeScalar(aCode + UInt32(n))!))
            // Add self-looping transitions from q0 to q0
            q0.addMove(character: character, toState: q0)
        }
        
        // accept any number of strings A-Z
        let ACharacterScalar = "A".unicodeScalars
        let ACode = ACharacterScalar[ACharacterScalar.startIndex].value
        
        for n in 0...25 {
            let character = Character(UnicodeScalar(ACode + UInt32(n))!)
            // Add self-looping transitions from q0 to q0
            q0.addMove(character: character, toState: q0)
        }
        
        super.init(startState: q0, tokenType: .t_identifier)
    }
}


/**
 * Performs lexical analysis (scanning) on a given file
 *
 * This scanner uses a finite state machine to read symbols. The scanner
 * uses the state machine to recognize tokens.
 *
 * Finite state machine needs: all possible states the machine can be in (finite), the initial state, a set of accepting states, and a set of transitions.
 *
 * Each token type has a corresponding DFA. All DFAs are explored in parallel, one move per
 * character in the character stream. If moves
 *
 * DFAs are represented by a hash map of all states and each state contains a
 * hash map of valid moves. The value of each cell says
 * what the next state should be (where to move). The DFA starts at state 0 and ends
 * when it reaches a final state. Final states are marked with a flag.
 */
class Scanner {
    var fileHandler: FileHandle
    var filePointer: UInt64 = 0 // where the file we currently are

    init(fileName: String) {
        // At this point, the file confirmed to be existing from Compiler.run
        // Safely open a file stream
        self.fileHandler = FileHandle(forReadingAtPath: fileName)!
        
        // Setup all DFAs to explore in parallel (using dovetailing - aka move one step at a time in each DFA until one accepts or all reject).
        
        // This compiler has a lookahead of 1, so when feeding characters into a DFA, we stop feeding when we reach a character that cannot acted upon by that DFA, then backtrack to the last valid state (if nececssary in implementation detail). If that last valid state is a final state, then the DFA accepts. If not, then the DFA rejects.
        
        // If a DFA accepts, stop all DFAs (dovetailed) and return the token. Then, continue reading.
        // It's possible that multiple DFAs accept, in that case, accept the 'longest' DFA (longest token) - for example, the divide character and a code comment.
        
        // If all DFAs reject, then the token is an unknown token. Mark it as unknown and continue reading.
        
        
        // Stop and accept when the string is fully read and in final state.
        // Stop and reject (mark as unknown token t_unknown) when the string is fully read and NOT in a final state.
        
        /*var result = self.getCharacter()
        while result != nil {
            print(result!)
            result = self.getCharacter()
        }*/
    }

    /**
     * Get the next token
     */
    func getToken() -> Token {
        // Get next character
        guard let character = self.getCharacter() else {
            // Character was nil, meaning we've reached the end of the file
            return Token(type: .t_end, lexeme: "")
        }
        
        Compiler.currentColumn += 1
        
        if character == "\n" {
            // Increment line count and reset column count
            Compiler.currentLine += 1
            Compiler.currentColumn = 1
        }
        
        // Explore all DFAs in 'parallel' (dovetailing)
        // TODO: modify this to use multi-threading in Swift if possible (to actually explore in parallel)
        print(character)

        return Token(type: .t_identifier, lexeme: "foobar")
    }

    /**
     * Returns a single character (the next character to be read in the input file).
     *
     * Returns nil if there are no more characters to read
     */
    func getCharacter() -> Character? {
        // read 1 byte (1 character)
        let data = fileHandler.readData(ofLength: 1)

        if data.count == 0 {
            // there's nothing to read, so return nil
            return nil
        }

        guard let characterStringValue = String(data: data, encoding: String.Encoding.utf8) else {
            // there's nothing else to read, so return nil
            return nil
        }
        
        let character = Character(characterStringValue) // character representation of single character in string

        // seek to next byte for the next read
        filePointer += 1
        fileHandler.seek(toFileOffset: filePointer)

        return character
    }
}
