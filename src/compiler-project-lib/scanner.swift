import Foundation

/**
 * Token types mapped to ascii values for single-character and multiple-character tokens
 */
enum TokenType {
    // general types
    case t_identifier
    
    // reserved keywords
    case t_variable // variable
    case t_integer // integer
    case t_bool // bool
    case t_global // global
    case t_begin // begin
    case t_end // end
    case t_program // program
    case t_end_program // "end program." or "end program ."
    case t_is // is
    case t_if
    case t_else
    case t_then
    case t_while
    case t_for
    case t_return
    case t_procedure // procedure
    
    case t_put_integer // putInteger function call (not sure what this is for yet)
    case t_put_string // putString function call (not sure what this is for yet)
    case t_get_bool // getBool function call (not sure what this is for yet)
    
    // operators
    case t_plus
    case t_minus
    case t_divide
    case t_multiply
    
    // reserved words
    case t_semicolon // ;
    case t_colon // :
    case t_comma // ,
    case t_quote // "
    case t_left_square_brace // [
    case t_right_square_brace // ]
    case t_left_curly_brace // {
    case t_right_curly_brace // }
    case t_left_bracket // <
    case t_right_bracket // >
    case t_left_paren // (
    case t_right_paren // )
    case t_assign // :=
    case t_equal // ==
    
    // other useful tokens
    case t_end_of_file // marks the end of file
    case t_unknown // unrecognized token
    
    // ignore any useless characters (comments, whitespace, newlines, etc.)
    case t_ignore
}


struct Token {
    let type: TokenType // the 'part of speech' of the token
    // TODO: make lexeme nullable for non-indentifier types
    let lexeme: String // the 'value' of the token (one or more characters than form a word is called a lexeme)
    let row: Int = 0 // TODO: where the token was encountered
    let column: Int = 0 // TODO: where the token was encountered
}

enum DFAStatus {
    case running // DFA is still reading input
    case accepted
    case rejected
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
    let startState: DFAState
    private var status: DFAStatus
    private let tokenType: TokenType // type of token that this DFA accepts
    private var tokenValue = "" // token value (lexeme) so far
    
    init(startState: DFAState, tokenType: TokenType) {
        status = .running
        self.tokenType = tokenType
        // Always start at the start state
        self.startState = startState
        currentState = startState
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
    
    func getTokenValue() -> String {
        return tokenValue
    }
    
    func getTokenLength() -> Int {
        return tokenValue.count
    }
    
    /**
     * Given a character, move to the next state if there is a valid state to move to.
     * The new state could be a final state (the caller can check with .isFinalState).
     */
    func nextMove(character: Character) -> DFAState? {
        guard let nextState = currentState.getMove(character: character) else {
            // No valid state to make a move to
            status = .rejected
            return nil
        }
        
        tokenValue = tokenValue + String(character)
        
        // Make move
        currentState = nextState
        
        if currentState.isFinalState {
            status = .accepted
        }
        
        // Return new state (it may be the final state - the caller can check with .isFinalState)
        return currentState
    }
    
    /**
     * Peek at the next move. Returns whether that move is accepting or not accepting.
     */
    func peekNextMove(character: Character) -> Bool {
        guard let nextState = currentState.getMove(character: character) else {
            // No valid state to make a move to
            return false
        }
        
        // A next state exists, but is it an accepting state?
        if nextState.isFinalState {
            return true
        }
        
        return false
    }
    
    /**
     * "Merge" this DFA with another given DFA.
     * This merge is somewhat simple because with a lookahead of 1, we know
     * that conflicts of more than 1 character are not possible.
     */
    func union(otherDFA: DFA) -> Void {
        // Check if the first move in the otherDFA already exist in this DFA
        let transitions = startState.transitions
        var otherTransitions = otherDFA.startState.transitions
        
        for transition in transitions {
            let character = transition.key
            
            for otherTransition in otherTransitions {
                if character == otherTransition.key {
                    // There is a transition in common from the start states of
                    // both DFAs, resolve conflict and remove transition from otherTransitions
                    
                    // There is a transition in common from the start states
                    let secondOtherState = otherDFA.startState.transitions[character]!
                    let secondOtherCharacters = otherDFA.startState.transitions[character]!.transitions
                    
                    for (otherCharacter, _) in secondOtherCharacters {
                        startState.transitions[character]?.addMove(character: otherCharacter, toState: secondOtherState)
                    }
                    
                    otherTransitions.removeValue(forKey: character)
//                    startState.transitions[character]?.addMove(character: , toState: secondOtherState)
                }
            }
        }
        
        // Create new transitions from the start state with the remaining transitions in otherTransitions
        for otherTransition in otherTransitions {
            startState.addMove(character: otherTransition.key, toState: otherDFA.startState)
        }
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

class RightSquareBraceDFA: DFA {
    init() {
        let qf = DFAState(id: 2, isFinalState: true)
        let q0 = DFAState(id: 1, possibleMoves: ["]": qf], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_right_square_brace)
    }
}

class LeftSquareBraceDFA: DFA {
    init() {
        let qf = DFAState(id: 2, isFinalState: true)
        let q0 = DFAState(id: 1, possibleMoves: ["[": qf], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_left_square_brace)
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

class QuoteDFA: DFA {
    init() {
        let qf = DFAState(id: 2, isFinalState: true)
        let q0 = DFAState(id: 1, possibleMoves: ["\"": qf], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_quote)
    }
}

class SemicolonDFA: DFA {
    init() {
        let qf = DFAState(id: 2, isFinalState: true)
        let q0 = DFAState(id: 1, possibleMoves: [";": qf], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_semicolon)
    }
}

class ColonDFA: DFA {
    init() {
        let qf = DFAState(id: 2, isFinalState: true)
        let q0 = DFAState(id: 1, possibleMoves: [":": qf], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_colon)
    }
}

class WhitespaceDFA: DFA {
    init() {
        // accepts 1 or many whitespace characters
        let qf = DFAState(id: 1, possibleMoves: [:], isFinalState: true)
        qf.addMove(character: " ", toState: qf)
        let q0 = DFAState(id: 0, possibleMoves: [" ": qf], isFinalState: false)

        super.init(startState: q0, tokenType: .t_ignore)
    }
}

class NewlineDFA: DFA {
    init() {
        // accepts 1 or many "\n" (newline) characters
        let qf = DFAState(id: 1, possibleMoves: [:], isFinalState: true)
        qf.addMove(character: "\n", toState: qf)
        let q0 = DFAState(id: 0, possibleMoves: ["\n": qf], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_ignore)
    }
}

// TODO: handle nested comments
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
        // accepts :=
        let qf = DFAState(id: 3, isFinalState: true)
        let q1 = DFAState(id: 2, possibleMoves: ["=": qf], isFinalState: false)
        let q0 = DFAState(id: 1, possibleMoves: [":": q1], isFinalState: false)
        
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

class TestDFA: DFA {
    init() {
        let dfa1 = ColonDFA()
        dfa1.union(otherDFA: AssignDFA())
        
        super.init(startState: dfa1.startState, tokenType: .t_colon)
    }
}

class IdentifierDFA: DFA {
    init() {
        // This DFA has a single accepting state that accepts any number of
        // characters 0-9, a-z, and A-Z in any order.
        let q0 = DFAState(id: 0, possibleMoves: [:], isFinalState: false) // start state
        let qf = DFAState(id: 1, possibleMoves: [:], isFinalState: true)
        
        // accept any number of digits 0-9 (every state is a final state)
        for n in 0...9 {
            let character = Character(String(n))
            
            // Add self-looping transitions from qf to qf
            q0.addMove(character: character, toState: qf)
            qf.addMove(character: character, toState: qf)
        }
        
        // accept any number of strings a-z
        let aCharacterScalar = "a".unicodeScalars
        let aCode = aCharacterScalar[aCharacterScalar.startIndex].value

        for n in 0...25 {
            let character = Character(String(UnicodeScalar(aCode + UInt32(n))!))
            // Add self-looping transitions from qf to qf
            q0.addMove(character: character, toState: qf)
            qf.addMove(character: character, toState: qf)
        }
        
        // accept any number of strings A-Z
        let ACharacterScalar = "A".unicodeScalars
        let ACode = ACharacterScalar[ACharacterScalar.startIndex].value
        
        for n in 0...25 {
            let character = Character(UnicodeScalar(ACode + UInt32(n))!)
            // Add self-looping transitions from qf to qf
            q0.addMove(character: character, toState: qf)
            qf.addMove(character: character, toState: qf)
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
class FAScanner {
    var fileHandler: FileHandle
    var filePointer: UInt64 = 0 // where the file we currently are
    let dfas: [DFA]
//    let dfa: DFA

    init(fileName: String) {
        // At this point, the file confirmed to be existing from Compiler.run
        // Safely open a file stream
        fileHandler = FileHandle(forReadingAtPath: fileName)!
        fileHandler.seek(toFileOffset: UInt64(0))
        
        // Setup all DFAs to explore in parallel (using dovetailing - aka move
        // one step at a time in each DFA until one accepts or all reject).
        dfas = [
            IdentifierDFA(),
            SemicolonDFA(),
            ColonDFA(),
            AssignDFA(),
            CommaDFA(),
            NewlineDFA(),
            WhitespaceDFA(),
            ForDFA(),
            WhileDFA(),
            IfDFA(),
            WhileDFA(),
            ReturnDFA()
        ]
        
        // If a DFA accepts, stop all DFAs (dovetailed) and return the token. Then, continue reading.
        // Keep track of the status of all DFAs (three possible statuses: running, accepted, or rejected)
        // It's possible that multiple DFAs accept, in that case, accept the 'longest' DFA (longest token),
        // for example, the divide character and a code comment.
        
        // If all DFAs reject, then the token is an unknown token. Mark it as unknown and continue reading.
        
        // Stop and accept when the string is fully read and in final state.
        // Stop and reject (mark as unknown token t_unknown) when the string is fully read and NOT in a final state.
    }
    
    deinit {
        fileHandler.closeFile()
    }
    
    func resetDFAs() -> Void {
        for dfa in dfas {
            dfa.reset()
        }
    }

    /**
     * Get the next token
     */
    func getToken() -> Token {
        // Keep the best DFA that we've seen so far (best meaning accepted with longest
        // number of characters)
        var relevantAcceptance = false
        var acceptedDFA: DFA? = nil
        
        while relevantAcceptance == false {
            // Get next character
            guard var character = self.getCharacter() else {
                // Character was nil, meaning we've reached the end of the file
                // (this logic can't be handled by a DFA because EOF doesn't have an ascii value)
                return Token(type: .t_end_of_file, lexeme: "")
            }
            
            // Lookahead 1 if neccessary
            let nextCharacter = self.getCharacter()
            
            if character == "\n" {
                // Increment line count and reset column count
                Compiler.currentLine += 1
                Compiler.currentColumn = 0
            } else {
                Compiler.currentColumn += 1
            }
            
            // Reset all DFAs before exploring
            self.resetDFAs()
            
            // This compiler has a lookahead of 1, so when feeding characters into a DFA, we stop feeding when we reach a character that cannot acted upon by that DFA.
            
            // Dovetail the DFAs with lookahead 1
            for dfa in dfas {
                // Attempt to move the DFA into the next state
                let state = dfa.nextMove(character: character)
                
                if state != nil && nextCharacter != nil {
                    // A state exists and a next character exists
                    // Peek at what the next state is (accepting or non-accepting)
                    let nextStateIsFinal = dfa.peekNextMove(character: nextCharacter!)
                    
                    // If state exists, state is an accepting state, and the next state is a non-accepting state or doesn't exist, we've found the next token
                    if state!.isFinalState && !nextStateIsFinal {
                        // We've found the next token, but before we can
                        // accept it, check that it is the longest possible token
                        if acceptedDFA == nil ||
                           (dfa.getTokenLength() > acceptedDFA!.getTokenLength()) {
                            acceptedDFA = dfa
                            
                            if dfa.getTokenType() != .t_ignore {
                                relevantAcceptance = true
                            }
                        }
                    }
                } /*else if state != nil && nextCharacter == nil {
                    // A state exists, but no next character exists
                    if state!.isFinalState {
                        // We've found the next token, but check that it is the longest possible token
                        if acceptedDFA == nil ||
                           (dfa.getTokenLength() > acceptedDFA!.getTokenLength()) {
                            acceptedDFA = dfa
                        }
                        
                        if dfa.getTokenType() != .t_ignore {
                            relevantAcceptance = true
                        }
                    }
                }*/
            }
        }
        
        guard let validTokenDFA = acceptedDFA else {
            // Unknown token
            return Token(type: .t_unknown, lexeme: "")
        }
        
        // Accepted dfa is not nil, so there is a valid token!
        return Token(type: validTokenDFA.getTokenType(), lexeme: validTokenDFA.getTokenValue())
        
//        while true {
//            if dfasExplored == dfas.count {
//                // moves exhausted for this character, move on to the next character
//                if let nextCharacter = self.getCharacter() {
//                    character = nextCharacter
//                    dfasExplored = 0
//                } else {
//                    // reached end of file
//                    return Token(type: .t_end_of_file, lexeme: "")
//                }
//            }
//
//            // Explore DFAs 'in parallel' with dovetailing
//            for dfa in dfas {
//                dfasExplored += 1
//                let nextState = dfa.nextMove(character: character)
//
//                if nextState == nil {
//                    // no valid next state to move into
//                    // take this DFA out of the running for this character
//                }
//
//                if dfa.isAcceptingState() {
//                    acceptedDFAs += [dfa]
//                    accepted = true
//
//                    // if dfa accepts a useless token, continue until we find a useful token
//                    if dfa.getTokenType() == .t_ignore {
//                        // reset all dfas, get next character, and continue
//                        self.resetDFAs()
//
//                        if let nextCharacter = self.getCharacter() {
//                            character = nextCharacter
//                            dfasExplored = 0
//                            accepted = false
//                            break
//                        } else {
//                            // reached end of file
//                            return Token(type: .t_end_of_file, lexeme: "")
//                        }
//                    }
//
//                    return Token(type: dfa.getTokenType(), lexeme: dfa.getTokenValue())
//                }
//            }
//        }
        
//        // handle case where no DFA accepts
//        if acceptedDFAs.count == 0 {
//            // unknown token
//            return Token(type: .t_unknown, lexeme: "")
//        }
//
//        if acceptedDFAs.count == 1 {
//            let dfa = acceptedDFAs.first!
//            return Token(type: dfa.getTokenType(), lexeme: dfa.getTokenValue())
//        }
        
        // If there are more than 1 accepting DFAs, choose the DFA with the longest token value
        // Do a max on the acceptedDFAs with the tokenValue key
        // TODO: clean this up
        // let maxToken = acceptedDFAs.map{$0.getTokenLength()}.max()
    }

    /**
     * Returns a single character (the next character to be read in the input file).
     * Implemented by doing a peek of the next character, then moving the file
     * pointer ahead to simulate a read.
     *
     * Returns nil if there are no more characters to read.
     */
    private func getCharacter() -> Character? {
        defer {
            // seek to next byte for the next read
            filePointer += 1
            fileHandler.seek(toFileOffset: filePointer)
        }
        
        return self.peekCharacter()
    }
    
    /**
     * Get the next character without moving the file pointer ahead after read.
     *
     * Returns nil if there are no more characters to be read.
     */
    private func peekCharacter() -> Character? {
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

        return character
    }
}
