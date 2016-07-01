import Foundation
import XCTest

func expectNoError(@noescape block: () throws -> Void) {

    do {
        try block()
    } catch {
        XCTFail("block has thrown")
    }
}

func ignoreError(@noescape block: () throws -> Void) {

    do {
        try block()
    } catch {
        // no op
    }
}

enum TestError: ErrorType {
    case IrrelevantError
}

let irrelevantError = TestError.IrrelevantError
