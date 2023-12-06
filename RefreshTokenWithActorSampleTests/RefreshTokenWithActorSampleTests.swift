//
//  RefreshTokenWithActorSampleTests.swift
//  RefreshTokenWithActorSampleTests
//
//  Created by Alvyn S on 06/12/2023.
//
//
// Copyright © Decathlon Outdoor. All rights reserved.
//

import XCTest
import RefreshTokenWithActorSample

final class DOAuthProviderTests: XCTestCase {

    func test_authorizedRequest_failsOnTokenProviderFailure() async throws {
        let (sut, tokenProviderSpy) = makeSUT()
        tokenProviderSpy.stubRetrieveTokenWithFailure()

        await assertThrowsAsyncError(try await sut.authorized(anyURLRequest()))
    }

    func test_authorizedRequest_succeedsOnTokenProviderSuccess() async throws {
        let expectedToken = UUID().uuidString
        let (sut, tokenProviderSpy) = makeSUT()
        tokenProviderSpy.stubToken(with: expectedToken)

        let signedRequest = try await sut.authorized(anyURLRequest())

        XCTAssertEqual(signedRequest.allHTTPHeaderFields?["Authorization"], "Bearer \(expectedToken)")
    }

    func test_authorizedRequest_setsRefreshTokenTaskToNilAfterCompletion() async throws {
        let expectedToken = UUID().uuidString
        let (sut, tokenProviderSpy) = makeSUT()
        tokenProviderSpy.stubToken(with: expectedToken)

        // First call to retrieve token
        _ = try await sut.authorized(anyURLRequest())

        // Reset the call count on the token provider stub
        tokenProviderSpy.resetCallCount()

        _ = try await sut.authorized(anyURLRequest())

        XCTAssertEqual(tokenProviderSpy.callCount, 1, "Expected one call to tokenProvider for the second retrieval, but got \(tokenProviderSpy.callCount)")
    }

    #warning("This test is flaky. Sometime it fails because My tokenProvider is called more than one when executing 2 requests simultaneously")
    @MainActor
    func test_authorizedRequest_preventsMakingMoreThanOneRequestAtTheSameTime() async throws {
        let expectedToken = UUID().uuidString
        let (sut, tokenProviderSpy) = makeSUT()
        tokenProviderSpy.stubToken(with: expectedToken)

        #warning("I try to use Task and completion here to use assertFullfilement(of:), but nothing change")
        async let request1 = try await sut.authorized(anyURLRequest())
        async let request2 = try await sut.authorized(anyURLRequest())

        let tokens = try await [request1, request2].compactMap { $0.allHTTPHeaderFields?["Authorization"] }
        XCTAssertEqual(tokens, ["Bearer \(expectedToken)", "Bearer \(expectedToken)"])
        XCTAssertEqual(tokenProviderSpy.callCount, 1, "Expected only one call to tokenProvider, but got \(tokenProviderSpy.callCount)")
    }

    private func makeSUT() -> (sut: DOAuthProvider, tokenProviderStub: TokenProviderSpy) {
        let tokenProviderStub = TokenProviderSpy()
        let sut = DOAuthProvider(tokenProvider: tokenProviderStub)

        return (sut, tokenProviderStub)
    }
}

private class TokenProviderSpy: TokenProvider {

    var callCount = 0

    private var tokenResult: Result<Token, Error> = .failure(anyError())

    func retrieveOrRenewAccessToken() async throws -> Token {
        callCount += 1
        return try tokenResult.get()
    }

    // MARK: - Helpers

    func stubToken(with token: Token) {
        tokenResult = .success(token)
    }

    func stubRetrieveTokenWithFailure() {
        tokenResult = .failure(anyError())
    }

    func resetCallCount() {
        callCount = 0
    }
}
