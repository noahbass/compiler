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
    case t_if
    case t_while
    case t_for
    case t_return
    
    // other usefull tokens
    case t_end // marks the end of file
    case t_unknown // unrecognized token
}


struct Token {
    let type: TokenType // the 'part of speech' of the token
    let lexeme: String // the 'value' of the token (one or more characters than form a word is called a lexeme)
    let row: Int = 0 // TODO: where the token was encountered
    let column: Int = 0 // TODO: where the token was encountered
}

// conf.set("spark.executor.heartbeatInterval","3600s")

/**
 * Performs lexical analysis (scanning) on a given file
 *
 * This scanner uses the loop and switch style scanner (aka ad hoc scanner)
 */
class Scanner {
    var fileHandler: FileHandle
    var filePointer: UInt64 = 0 // where to

    init(fileName: String) {
        // At this point, the file confirmed to be existing from Compiler.run
        // Safely open a file stream
        self.fileHandler = FileHandle(forReadingAtPath: fileName)!
        
        // setup initial symbol table with reserved words
        //symbolTable["variable"] = .t_variable
        
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
        
        // Skip whitespace, newlines, tabs, and comments
        switch character {
            case " ":
                return self.getToken() // skip whitespace

            case "\t":
                return self.getToken() // skip tabs

            case "/":
                // Could be a comment or t_divide operation
                if let nextCharacter = self.getCharacter() {
                    if nextCharacter == "/" {
                        // it's a comment, so skip the rest of this line (until '\n' or end of file)
                        let nextCharacter = self.getCharacter()
                        while true {
                            if nextCharacter == nil {
                                // we've reached the end of the file at the end of the comment
                                return Token(type: .t_end, lexeme: "")
                            }
                            
                            if nextCharacter! == "\n" {
                                // we've reached the end of the current line, so the comment is completed
                                return self.getToken()
                            }
                        }
                    }
                }

                // it's a divide operation
                return Token(type: .t_divide, lexeme: "/")
            case "\n":
                // increase line count (for debugging purposes)
                Compiler.currentLine += 1

            default:
                print("character unknown")
        }

        return Token(type: .t_identifier, lexeme: "world")
    }

    /**
     * Returns a single character (the next character to be read in the input file).
     *
     * Returns nil if there are no more characters to read
     */
    func getCharacter() -> String? {
        // read 1 byte (1 character)
        let data = fileHandler.readData(ofLength: 1)

        if data.count == 0 {
            // there's nothing to read, so return nil
            return nil
        }

        guard let character = String(data: data, encoding: String.Encoding.utf8) else {
            // there's nothing else to read, so return nil
            return nil
        }

        // seek to next byte for the next read
        filePointer += 1
        fileHandler.seek(toFileOffset: filePointer)

        return character
    }
}
