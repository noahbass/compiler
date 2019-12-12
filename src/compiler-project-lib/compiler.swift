import Foundation

enum FileError: Error {
    case fileNotFoundError
    case fileNotReadable
}

/**
 * Entrypoint into the compiler.
 *
 * Usage: initalize and call run()
 */
public class Compiler {
    let inputFilePath: String
    static var currentLine = 1
    static var currentColumn = 0
    var errorFlags: [String] = []
    var warningFlags: [String] = []
    
    public init(inputFilePath: String) {
        self.inputFilePath = inputFilePath
    }
    
    public func run() throws -> Void {
        // check if file exists and is readable
        let fileManager = FileManager()
        let fileExists = fileManager.fileExists(atPath: inputFilePath)
        let fileReadable = fileManager.isReadableFile(atPath: inputFilePath)
        
        if !fileExists {
            throw FileError.fileNotFoundError
        }
        
        if !fileReadable {
            throw FileError.fileNotReadable
        }
        
        // file is confirmed as existing and readable, continue
        let scanner = FAScanner(fileName: inputFilePath)
    }
    
    func reportError(message: String) -> Void {
        print("There's been an error...", message)
        errorFlags.append(message)
        exit(1) // todo: remove this
    }

    func reportWarning(message: String) -> Void {
        print("Here's a warning...", message)
        warningFlags.append(message)
    }
}
