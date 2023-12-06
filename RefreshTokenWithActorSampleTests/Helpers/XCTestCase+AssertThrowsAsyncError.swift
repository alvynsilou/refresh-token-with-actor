//
//  XCTestCase+AssertThrowsAsyncError.swift
//  RefreshTokenWithActorSampleTests
//
//  Created by Alvyn S on 06/12/2023.
//

import XCTest

extension XCTestCase {

    /// Asserts that an asynchronous expression throws an error.
    /// (Intended to function as a drop-in asynchronous version of `XCTAssertThrowsError`.)
    ///
    /// Example usage:
    ///
    ///     await assertThrowsAsyncError(
    ///         try await sut.function()
    ///     ) { error in
    ///         XCTAssertEqual(error as? MyError, MyError.specificError)
    ///     }
    ///
    /// - Parameters:
    ///   - expression: An asynchronous expression that can throw an error.
    ///   - message: An optional description of a failure.
    ///   - file: The file where the failure occurs.
    ///     The default is the filename of the test case where you call this function.
    ///   - line: The line number where the failure occurs.
    ///     The default is the line number where you call this function.
    ///   - errorHandler: An optional handler for errors that expression throws.
    func assertThrowsAsyncError<T>(
        _ expression: @autoclosure () async throws -> T,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #filePath,
        line: UInt = #line,
        _ errorHandler: (_ error: Error) -> Void = { _ in }
    ) async {
        var errorThrown: Error?
        do {
            _ = try await expression()
        } catch {
            errorThrown = error
        }
        if let errorThrown {
            errorHandler(errorThrown)
        } else {
            let customMessage = message()
            if customMessage.isEmpty {
                XCTFail("Asynchronous call did not throw an error.", file: file, line: line)
            } else {
                XCTFail(customMessage, file: file, line: line)
            }
        }
    }
}
