# compiler-project

[![MIT license](https://img.shields.io/github/license/noahbass/compiler.svg)](https://opensource.org/licenses/MIT) [![Build Status](https://travis-ci.com/noahbass/compiler.svg?branch=master)](https://travis-ci.com/noahbass/compiler)

> (work in progress) A recursive descent compiler (LL(1)) written in Swift

## Goals

- Write in Swift
- LL lookahead 1
- Use no existing Swift features for creating compiler subsystems (no regular expressions, etc.)
- Use finite automata for the scanner
    - Explore DFAs "in parallel" with dovetailing
    - Further down the line, look into using multi-threading in Swift to explore the DFAs in parallel

## Using the compiler

```sh
$ swift build
$ ./.build/debug/compilerprojectexecutable filename.src
```

## Testing the compiler

```sh
$ swift test
```

## Compiler Details

### 1. Scanner

The scanner (or lexical analyzer) is written as many Deterministic Finite Automaton (DFA) machines, all explored in parallel until one accepts or none accept (marked as an unknown token). The scanner produces a stream of tokens.

This approach to the writing the scanner is definitely not as time efficient as writing a single large DFA, but it was still interesting to implement.

## License

[MIT](LICENSE)

