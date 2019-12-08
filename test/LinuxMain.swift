import XCTest

import compiler_projectTests

var tests = [XCTestCaseEntry]()
tests += compiler_projectTests.allTests()
XCTMain(tests)
