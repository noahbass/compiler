import Foundation
import Darwin
import compilerproject

let compiler = Compiler(inputFilePath: "/Users/noah/Projects/compiler-project/foo.txt")
try compiler.run()
