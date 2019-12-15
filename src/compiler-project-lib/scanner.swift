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
    case t_non_final
    
    // ignore any useless characters (comments, whitespace, newlines, etc.)
    case t_ignore
}


public struct Token {
    let type: TokenType // the 'part of speech' of the token
    // TODO: make lexeme nullable for non-indentifier types
    let lexeme: String // the 'value' of the token (one or more characters than form a word is called a lexeme)
    let row: Int = 0 // TODO: where the token was encountered
    let column: Int = 0 // TODO: where the token was encountered
}

/**
 * A state in finite automata
 */
class DFAState {
    let id: Int
    var transitions: [Character: DFAState] // a hash map of characters to read and the corresponding state to move to
    let isFinalState: Bool
    let tokenType: TokenType // if this state is final, designate which token it accepts
    
    init(id: Int, possibleMoves: [Character: DFAState] = [:], isFinalState: Bool = false) {
        self.id = id
        self.transitions = possibleMoves
        self.isFinalState = isFinalState
        self.tokenType = .t_non_final
    }

    init(id: Int, isFinalState: Bool, token: TokenType) {
        self.id = id
        transitions = [:]
        self.isFinalState = isFinalState
        tokenType = token
    }
    
    init(id: Int, isFinalState: Bool) {
        self.id = id
        transitions = [:]
        self.isFinalState = isFinalState
        tokenType = .t_non_final
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
    private let tokenType: TokenType // type of token that this DFA accepts
    
    init(startState: DFAState, tokenType: TokenType) {
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
    
    /**
     * Given a character, move to the next state if there is a valid state to move to.
     * The new state could be a final state (the caller can check with .isFinalState).
     *
     * To peek, the caller can specify `persistMove = false`.
     */
    func nextMove(character: Character, persistMove: Bool = true) -> DFAState? {
        guard let nextState = currentState.getMove(character: character) else {
            // No valid state to make a move to
            return nil
        }
        
        // Make move and save
        if persistMove {
            currentState = nextState
        }
        
        // Return new state (it may be the final state - the caller can check with .isFinalState)
        return nextState
    }
    
    /**
     * Peek at the next move. Returns whether that move is accepting or not accepting.
     */
    func peekNextMove(character: Character) -> DFAState? {
        return self.nextMove(character: character, persistMove: false)
    }
    
    /**
     * "Merge" this DFA with another given DFA.
     * This merge is somewhat simple because with a lookahead of 1, we know
     * that conflicts of more than 1 character are not possible.
     *
     * TODO: make this function into an actual 'union' function
     */
    func union(_ otherDFA: DFA) -> Void {
        // Check if the first move in the otherDFA already exist in this DFA
        let transitions = startState.transitions
        var otherTransitions = otherDFA.startState.transitions
        
        // TODO: clean this function up
        for transition in transitions {
            let character = transition.key
            
            for otherTransition in otherTransitions {
                if character == otherTransition.key {
                    // There is a transition in common from the start states of
                    // both DFAs, resolve conflict and remove transition from otherTransitions
                    let secondOtherCharacters = otherDFA.startState.transitions[character]!.transitions
                    
                    for (otherCharacter, _) in secondOtherCharacters {
                        let secondOtherState = otherDFA.startState.transitions[character]!.transitions[otherCharacter]!
                        startState.transitions[character]?.addMove(character: otherCharacter, toState: secondOtherState)
                    }
                    
                    otherTransitions.removeValue(forKey: character)
                }
            }
        }
        
        // Create new transitions from the start state with the remaining transitions in otherTransitions
        for otherTransition in otherTransitions {
            startState.addMove(character: otherTransition.key, toState: otherDFA.startState.transitions[otherTransition.key]!)
        }
    }
}


class RightBracketDFA: DFA {
    init() {
        let qf = DFAState(id: 2, isFinalState: true, token: .t_right_bracket)
        let q0 = DFAState(id: 1, possibleMoves: [">": qf], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_right_bracket)
    }
}

class LeftBracketDFA: DFA {
    init() {
        let qf = DFAState(id: 2, isFinalState: true, token: .t_left_bracket)
        let q0 = DFAState(id: 1, possibleMoves: ["<": qf], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_left_bracket)
    }
}

class RightSquareBraceDFA: DFA {
    init() {
        let qf = DFAState(id: 2, isFinalState: true, token: .t_right_square_brace)
        let q0 = DFAState(id: 1, possibleMoves: ["]": qf], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_right_square_brace)
    }
}

class LeftSquareBraceDFA: DFA {
    init() {
        let qf = DFAState(id: 2, isFinalState: true, token: .t_left_square_brace)
        let q0 = DFAState(id: 1, possibleMoves: ["[": qf], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_left_square_brace)
    }
}

class RightCurlyBraceDFA: DFA {
    init() {
        let qf = DFAState(id: 2, isFinalState: true, token: .t_right_curly_brace)
        let q0 = DFAState(id: 1, possibleMoves: ["}": qf], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_right_curly_brace)
    }
}

class LeftCurlyBraceDFA: DFA {
    init() {
        let qf = DFAState(id: 2, isFinalState: true, token: .t_left_curly_brace)
        let q0 = DFAState(id: 1, possibleMoves: ["{": qf], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_left_curly_brace)
    }
}

class RightParenDFA: DFA {
    init() {
        let qf = DFAState(id: 2, isFinalState: true, token: .t_right_paren)
        let q0 = DFAState(id: 1, possibleMoves: [")": qf], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_right_paren)
    }
}

class LeftParenDFA: DFA {
    init() {
        let qf = DFAState(id: 2, isFinalState: true, token: .t_left_paren)
        let q0 = DFAState(id: 1, possibleMoves: ["(": qf], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_left_paren)
    }
}

class CommaDFA: DFA {
    init() {
        let qf = DFAState(id: 2, isFinalState: true, token: .t_comma)
        let q0 = DFAState(id: 1, possibleMoves: [",": qf], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_comma)
    }
}

class QuoteDFA: DFA {
    init() {
        let qf = DFAState(id: 2, isFinalState: true, token: .t_quote)
        let q0 = DFAState(id: 1, possibleMoves: ["\"": qf], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_quote)
    }
}

class SemicolonDFA: DFA {
    init() {
        let qf = DFAState(id: 2, isFinalState: true, token: .t_semicolon)
        let q0 = DFAState(id: 1, possibleMoves: [";": qf], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_semicolon)
    }
}

class ColonDFA: DFA {
    init() {
        let qf = DFAState(id: 2, isFinalState: true, token: .t_colon)
        let q0 = DFAState(id: 1, possibleMoves: [":": qf], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_colon)
    }
}

class WhitespaceDFA: DFA {
    init() {
        // accepts 1 or many whitespace characters
        let qf = DFAState(id: 1, isFinalState: true, token: .t_ignore)
        qf.addMove(character: " ", toState: qf)
        let q0 = DFAState(id: 0, possibleMoves: [" ": qf], isFinalState: false)

        super.init(startState: q0, tokenType: .t_ignore)
    }
}

class NewlineDFA: DFA {
    init() {
        // accepts 1 or many "\n" (newline) characters
        let qf = DFAState(id: 1, isFinalState: true, token: .t_ignore)
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
        let qf = DFAState(id: 3, isFinalState: true, token: .t_ignore)
        
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
        let qf = DFAState(id: 2, isFinalState: true, token: .t_plus)
        let q0 = DFAState(id: 1, possibleMoves: ["+": qf], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_plus)
    }
}

class MinusDFA: DFA {
    init() {
        let qf = DFAState(id: 2, isFinalState: true, token: .t_minus)
        let q0 = DFAState(id: 1, possibleMoves: ["-": qf], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_minus)
    }
}

class MultiplyDFA: DFA {
    init() {
        let qf = DFAState(id: 2, isFinalState: true, token: .t_multiply)
        let q0 = DFAState(id: 1, possibleMoves: ["*": qf], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_multiply)
    }
}

class DivideDFA: DFA {
    init() {
        let qf = DFAState(id: 2, isFinalState: true, token: .t_divide)
        let q0 = DFAState(id: 1, possibleMoves: ["/": qf], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_divide)
    }
}

class AssignDFA: DFA {
    init() {
        // accepts :=
        let qf = DFAState(id: 3, isFinalState: true, token: .t_assign)
        let q1 = DFAState(id: 2, possibleMoves: ["=": qf], isFinalState: false)
        let q0 = DFAState(id: 1, possibleMoves: [":": q1], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_assign)
    }
}

class EqualDFA: DFA {
    init() {
        let qf = DFAState(id: 3, isFinalState: true, token: .t_equal)
        let q1 = DFAState(id: 2, possibleMoves: ["=": qf], isFinalState: false)
        let q0 = DFAState(id: 1, possibleMoves: ["=": q1], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_equal)
    }
}

class IntegerDFA: DFA {
    init() {
        let qf = DFAState(id: 8, isFinalState: true, token: .t_integer)
        let q6 = DFAState(id: 7, possibleMoves: ["r": qf], isFinalState: false)
        let q5 = DFAState(id: 6, possibleMoves: ["e": q6], isFinalState: false)
        let q4 = DFAState(id: 5, possibleMoves: ["g": q5], isFinalState: false)
        let q3 = DFAState(id: 4, possibleMoves: ["e": q4], isFinalState: false)
        let q2 = DFAState(id: 3, possibleMoves: ["t": q3], isFinalState: false)
        let q1 = DFAState(id: 2, possibleMoves: ["n": q2], isFinalState: false)
        let q0 = DFAState(id: 1, possibleMoves: ["i": q1], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_integer)
    }
}

class BoolDFA: DFA {
    init() {
        let qf = DFAState(id: 5, isFinalState: true, token: .t_bool)
        let q3 = DFAState(id: 4, possibleMoves: ["l": qf], isFinalState: false)
        let q2 = DFAState(id: 3, possibleMoves: ["o": q3], isFinalState: false)
        let q1 = DFAState(id: 2, possibleMoves: ["o": q2], isFinalState: false)
        let q0 = DFAState(id: 1, possibleMoves: ["b": q1], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_bool)
    }
}

class GlobalDFA: DFA {
    init() {
        let qf = DFAState(id: 7, isFinalState: true, token: .t_global)
        let q5 = DFAState(id: 6, possibleMoves: ["l": qf], isFinalState: false)
        let q4 = DFAState(id: 5, possibleMoves: ["a": q5], isFinalState: false)
        let q3 = DFAState(id: 4, possibleMoves: ["b": q4], isFinalState: false)
        let q2 = DFAState(id: 3, possibleMoves: ["o": q3], isFinalState: false)
        let q1 = DFAState(id: 2, possibleMoves: ["l": q2], isFinalState: false)
        let q0 = DFAState(id: 1, possibleMoves: ["g": q1], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_global)
    }
}

class BeginDFA: DFA {
    init() {
        let qf = DFAState(id: 6, isFinalState: true, token: .t_begin)
        let q4 = DFAState(id: 5, possibleMoves: ["n": qf], isFinalState: false)
        let q3 = DFAState(id: 4, possibleMoves: ["i": q4], isFinalState: false)
        let q2 = DFAState(id: 3, possibleMoves: ["g": q3], isFinalState: false)
        let q1 = DFAState(id: 2, possibleMoves: ["e": q2], isFinalState: false)
        let q0 = DFAState(id: 1, possibleMoves: ["b": q1], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_begin)
    }
}

class EndDFA: DFA {
    init() {
        let qf = DFAState(id: 4, isFinalState: true, token: .t_end)
        let q2 = DFAState(id: 3, possibleMoves: ["d": qf], isFinalState: false)
        let q1 = DFAState(id: 2, possibleMoves: ["n": q2], isFinalState: false)
        let q0 = DFAState(id: 1, possibleMoves: ["e": q1], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_end)
    }
}

class ProgramDFA: DFA {
    init() {
        let qf = DFAState(id: 8, isFinalState: true, token: .t_program)
        let q6 = DFAState(id: 7, possibleMoves: ["m": qf], isFinalState: false)
        let q5 = DFAState(id: 6, possibleMoves: ["a": q6], isFinalState: false)
        let q4 = DFAState(id: 5, possibleMoves: ["r": q5], isFinalState: false)
        let q3 = DFAState(id: 4, possibleMoves: ["g": q4], isFinalState: false)
        let q2 = DFAState(id: 3, possibleMoves: ["o": q3], isFinalState: false)
        let q1 = DFAState(id: 2, possibleMoves: ["r": q2], isFinalState: false)
        let q0 = DFAState(id: 1, possibleMoves: ["p": q1], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_program)
    }
}

class EndProgramDFA: DFA {
    init() {
        // Accepts "end program." or "end program ."
        let qf = DFAState(id: 14, isFinalState: true, token: .t_end_program)
        let q12 = DFAState(id: 13, possibleMoves: [".": qf], isFinalState: false)
        let q11 = DFAState(id: 12, possibleMoves: [".": qf, " ": q12], isFinalState: false)
        let q10 = DFAState(id: 11, possibleMoves: ["m": q11], isFinalState: false)
        let q9 = DFAState(id: 10, possibleMoves: ["a": q10], isFinalState: false)
        let q8 = DFAState(id: 9, possibleMoves: ["r": q9], isFinalState: false)
        let q7 = DFAState(id: 8, possibleMoves: ["g": q8], isFinalState: false)
        let q6 = DFAState(id: 7, possibleMoves: ["o": q7], isFinalState: false)
        let q5 = DFAState(id: 6, possibleMoves: ["r": q6], isFinalState: false)
        let q4 = DFAState(id: 5, possibleMoves: ["p": q5], isFinalState: false)
        let q3 = DFAState(id: 4, possibleMoves: [" ": q4], isFinalState: false)
        let q2 = DFAState(id: 3, possibleMoves: ["d": q3], isFinalState: false)
        let q1 = DFAState(id: 2, possibleMoves: ["n": q2], isFinalState: false)
        let q0 = DFAState(id: 1, possibleMoves: ["e": q1], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_end_program)
    }
}

class IsDFA: DFA {
    init() {
        let qf = DFAState(id: 3, isFinalState: true, token: .t_is)
        let q1 = DFAState(id: 2, possibleMoves: ["s": qf], isFinalState: false)
        let q0 = DFAState(id: 1, possibleMoves: ["i": q1], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_is)
    }
}

class ProcedureDFA: DFA {
    init() {
        let qf = DFAState(id: 10, isFinalState: true, token: .t_procedure)
        let q8 = DFAState(id: 9, possibleMoves: ["e": qf], isFinalState: false)
        let q7 = DFAState(id: 8, possibleMoves: ["r": q8], isFinalState: false)
        let q6 = DFAState(id: 7, possibleMoves: ["u": q7], isFinalState: false)
        let q5 = DFAState(id: 6, possibleMoves: ["d": q6], isFinalState: false)
        let q4 = DFAState(id: 5, possibleMoves: ["e": q5], isFinalState: false)
        let q3 = DFAState(id: 4, possibleMoves: ["c": q4], isFinalState: false)
        let q2 = DFAState(id: 3, possibleMoves: ["o": q3], isFinalState: false)
        let q1 = DFAState(id: 2, possibleMoves: ["r": q2], isFinalState: false)
        let q0 = DFAState(id: 1, possibleMoves: ["p": q1], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_procedure)
    }
}

class VariableDFA: DFA {
    init() {
        let qf = DFAState(id: 9, isFinalState: true, token: .t_variable)
        let q7 = DFAState(id: 8, possibleMoves: ["e": qf], isFinalState: false)
        let q6 = DFAState(id: 7, possibleMoves: ["l": q7], isFinalState: false)
        let q5 = DFAState(id: 6, possibleMoves: ["b": q6], isFinalState: false)
        let q4 = DFAState(id: 5, possibleMoves: ["a": q5], isFinalState: false)
        let q3 = DFAState(id: 4, possibleMoves: ["i": q4], isFinalState: false)
        let q2 = DFAState(id: 3, possibleMoves: ["r": q3], isFinalState: false)
        let q1 = DFAState(id: 2, possibleMoves: ["a": q2], isFinalState: false)
        let q0 = DFAState(id: 1, possibleMoves: ["v": q1], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_variable)
    }
}

class IfDFA: DFA {
    init() {
        let q2 = DFAState(id: 3, isFinalState: true, token: .t_if)
        let q1 = DFAState(id: 2, possibleMoves: ["f": q2], isFinalState: false)
        let q0 = DFAState(id: 1, possibleMoves: ["i": q1], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_if)
    }
}

class ElseDFA: DFA {
    init() {
        let qf = DFAState(id: 5, isFinalState: true, token: .t_else)
        let q3 = DFAState(id: 4, possibleMoves: ["e": qf], isFinalState: false)
        let q2 = DFAState(id: 3, possibleMoves: ["s": q3], isFinalState: false)
        let q1 = DFAState(id: 2, possibleMoves: ["l": q2], isFinalState: false)
        let q0 = DFAState(id: 1, possibleMoves: ["e": q1], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_else)
    }
}

class ThenDFA: DFA {
    init() {
        let qf = DFAState(id: 5, isFinalState: true, token: .t_then)
        let q3 = DFAState(id: 4, possibleMoves: ["n": qf], isFinalState: false)
        let q2 = DFAState(id: 3, possibleMoves: ["e": q3], isFinalState: false)
        let q1 = DFAState(id: 2, possibleMoves: ["h": q2], isFinalState: false)
        let q0 = DFAState(id: 1, possibleMoves: ["t": q1], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_then)
    }
}

class WhileDFA: DFA {
    init() {
        let q5 = DFAState(id: 6, isFinalState: true, token: .t_while)
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
        let qf = DFAState(id: 4, isFinalState: true, token: .t_for)
        let q2 = DFAState(id: 3, possibleMoves: ["r": qf], isFinalState: false)
        let q1 = DFAState(id: 2, possibleMoves: ["o": q2], isFinalState: false)
        let q0 = DFAState(id: 1, possibleMoves: ["f": q1], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_for)
    }
}

class ReturnDFA: DFA {
    init() {
        let qf = DFAState(id: 6, isFinalState: true, token: .t_return)
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
        let q0 = DFAState(id: 0, possibleMoves: [:], isFinalState: false) // start state
        let qf = DFAState(id: 1, isFinalState: true, token: .t_identifier)
        
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

class PutIntegerDFA: DFA {
    init() {
        let qf = DFAState(id: 11, isFinalState: true, token: .t_put_integer)
        let q9 = DFAState(id: 10, possibleMoves: ["r": qf], isFinalState: false)
        let q8 = DFAState(id: 9, possibleMoves: ["e": q9], isFinalState: false)
        let q7 = DFAState(id: 8, possibleMoves: ["g": q8], isFinalState: false)
        let q6 = DFAState(id: 7, possibleMoves: ["e": q7], isFinalState: false)
        let q5 = DFAState(id: 6, possibleMoves: ["t": q6], isFinalState: false)
        let q4 = DFAState(id: 5, possibleMoves: ["n": q5], isFinalState: false)
        let q3 = DFAState(id: 4, possibleMoves: ["I": q4], isFinalState: false)
        let q2 = DFAState(id: 3, possibleMoves: ["t": q3], isFinalState: false)
        let q1 = DFAState(id: 2, possibleMoves: ["u": q2], isFinalState: false)
        let q0 = DFAState(id: 1, possibleMoves: ["p": q1], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_put_integer)
    }
}

class PutStringDFA: DFA {
    init() {
        let qf = DFAState(id: 10, isFinalState: true, token: .t_put_string)
        let q8 = DFAState(id: 9, possibleMoves: ["g": qf], isFinalState: false)
        let q7 = DFAState(id: 8, possibleMoves: ["n": q8], isFinalState: false)
        let q6 = DFAState(id: 7, possibleMoves: ["i": q7], isFinalState: false)
        let q5 = DFAState(id: 6, possibleMoves: ["r": q6], isFinalState: false)
        let q4 = DFAState(id: 5, possibleMoves: ["t": q5], isFinalState: false)
        let q3 = DFAState(id: 4, possibleMoves: ["S": q4], isFinalState: false)
        let q2 = DFAState(id: 3, possibleMoves: ["t": q3], isFinalState: false)
        let q1 = DFAState(id: 2, possibleMoves: ["u": q2], isFinalState: false)
        let q0 = DFAState(id: 1, possibleMoves: ["p": q1], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_put_string)
    }
}

class GetBoolDFA: DFA {
    init() {
        let qf = DFAState(id: 8, isFinalState: true, token: .t_get_bool)
        let q6 = DFAState(id: 7, possibleMoves: ["l": qf], isFinalState: false)
        let q5 = DFAState(id: 6, possibleMoves: ["o": q6], isFinalState: false)
        let q4 = DFAState(id: 5, possibleMoves: ["o": q5], isFinalState: false)
        let q3 = DFAState(id: 4, possibleMoves: ["B": q4], isFinalState: false)
        let q2 = DFAState(id: 3, possibleMoves: ["t": q3], isFinalState: false)
        let q1 = DFAState(id: 2, possibleMoves: ["e": q2], isFinalState: false)
        let q0 = DFAState(id: 1, possibleMoves: ["g": q1], isFinalState: false)
        
        super.init(startState: q0, tokenType: .t_get_bool)
    }
}


/**
 * Performs lexical analysis (scanning) on a given file
 *
 * This scanner uses a finite state machine to read symbols. The scanner
 * uses the state machine to recognize tokens.
 *
 * The scanner explores a finite state machine (in the form of a DFA) to
 * decide when to accept and reject possible tokens.
 */
public class FAScanner {
    private var fileHandler: FileHandle
    private var filePointer: UInt64 = 0 // where the file we currently are
    private let dfa: DFA

    init(fileName: String) {
        // At this point, the file confirmed to be existing from Compiler.run
        // Safely open a file stream
        fileHandler = FileHandle(forReadingAtPath: fileName)!
        fileHandler.seek(toFileOffset: UInt64(0))
        
        // Create a 'mega' DFA made up of every 'small' DFA
        dfa = ColonDFA()
        dfa.union(RightBracketDFA())
        dfa.union(LeftBracketDFA())
        dfa.union(RightSquareBraceDFA())
        dfa.union(LeftSquareBraceDFA())
        dfa.union(RightCurlyBraceDFA())
        dfa.union(LeftCurlyBraceDFA())
        dfa.union(RightParenDFA())
        dfa.union(LeftParenDFA())
        dfa.union(CommaDFA())
        dfa.union(QuoteDFA())
        dfa.union(SemicolonDFA())
        dfa.union(WhitespaceDFA())
        dfa.union(NewlineDFA())
        dfa.union(CommentDFA())
        dfa.union(PlusDFA())
        dfa.union(MinusDFA())
        dfa.union(MultiplyDFA())
        dfa.union(DivideDFA())
        dfa.union(AssignDFA())
        dfa.union(EqualDFA())
        dfa.union(IdentifierDFA())
        dfa.union(VariableDFA())
        dfa.union(IntegerDFA())
        dfa.union(BoolDFA())
        dfa.union(GlobalDFA())
        dfa.union(BeginDFA())
        dfa.union(EndDFA())
        dfa.union(ProgramDFA())
        dfa.union(EndProgramDFA())
        dfa.union(IsDFA())
        dfa.union(ProcedureDFA())
        dfa.union(IfDFA())
        dfa.union(ElseDFA())
        dfa.union(ThenDFA())
        dfa.union(WhileDFA())
        dfa.union(ReturnDFA())
        dfa.union(ForDFA())
        dfa.union(PutIntegerDFA())
        dfa.union(PutStringDFA())
        dfa.union(GetBoolDFA())
    }
    
    deinit {
        fileHandler.closeFile()
    }

    /**
     * Get the next token by exploring the 'mega' DFA.
     */
    public func getToken() -> Token {
        var relevantAcceptance = false // Don't return useless tokens (like whitespace, newline, etc.)
        var acceptedState: DFAState? = nil
        var lexeme = ""
        
        while !relevantAcceptance {
            // Get next character
            guard let character = self.getCharacter() else {
                // Character was nil, meaning we've reached the end of the file
                // (this logic can't be handled by a DFA because EOF doesn't have an ascii value)
                return Token(type: .t_end_of_file, lexeme: lexeme)
            }
            
            // Lookahead 1 character
            let nextCharacter = self.peekCharacter()
            
            if character == "\n" { // TODO: pretty this up
                // Increment line count and reset column count
                Compiler.currentLine += 1
                Compiler.currentColumn = 0
            } else {
                Compiler.currentColumn += 1
            }
            
            if lexeme.isEmpty {
                // reset DFA before exploring the DFA if needed
                dfa.reset()
            }
            
            lexeme += String(character)
            
            let state = dfa.nextMove(character: character)
            
            // TODO: clean up this logic
            if state != nil && state!.isFinalState && nextCharacter == nil {
                // Accept!
                acceptedState = state
            } else if state != nil && state!.isFinalState && nextCharacter != nil {
                // Check (peek) next character for possible acceptance in the DFA
                // without actually making the move
                let nextState = dfa.peekNextMove(character: nextCharacter!)
                
                if (nextState != nil && !nextState!.isFinalState) || nextState == nil {
                    // Accept!
                    acceptedState = state
                }
            }
            
            if let state = acceptedState {
                if state.tokenType == .t_ignore {
                    lexeme = "" // Reset lexeme
                    acceptedState = nil
                } else {
                    relevantAcceptance = true // Break out of loop
                }
            }
        }
        
        if acceptedState != nil {
            return Token(type: acceptedState!.tokenType, lexeme: lexeme)
        }
        
        // No valid token found
        return Token(type: .t_unknown, lexeme: "")
    }

    /**
     * Returns a single character (the next character to be read in the input file).
     * Implemented by doing a peek of the next character, then moving the file
     * pointer ahead to simulate a read.
     *
     * Returns nil if there are no more characters to read.
     */
    private func getCharacter() -> Character? {
        let character = self.peekCharacter()
        
        // seek to next byte for the next read
        filePointer += 1
        fileHandler.seek(toFileOffset: filePointer)
        
        return character
    }
    
    /**
     * Get the next character without moving the file pointer ahead after read.
     *
     * Returns nil if there are no more characters to be read.
     */
    private func peekCharacter() -> Character? {
        // read 1 byte (1 character)
        let data = fileHandler.readData(ofLength: 1)
        
        // Stay in same location as before the read
        fileHandler.seek(toFileOffset: filePointer)
        
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
