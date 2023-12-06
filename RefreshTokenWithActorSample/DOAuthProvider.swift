//
//  DOAuthProvider.swift
//  RefreshTokenWithActorSample
//
//  Created by Alvyn S on 06/12/2023.
//

import Foundation

/// Synchronize refresh token request so that we have only one request sent to the back end

public actor DOAuthProvider: AuthProvider {

    private let tokenProvider: TokenProvider

    private var refreshTokenTask: Task<URLRequest, Error>?

    public init(tokenProvider: TokenProvider) {
        self.tokenProvider = tokenProvider
    }

    public func authorized(_ newRequest: URLRequest) async throws -> URLRequest {
        /// if a refreshTask is not nil then it is currently refreshing and we just wait for it to complet

        #warning("""
I guess here when executing 2 tasks in parallel the condition is nil for both task.
""")
        if let existingTask = refreshTokenTask {
            return try await authorizeRequest(newRequest, using: existingTask)
        }


        #warning("""
I try to assign directly the task to the refreshTokenTask field, but no success
""")
        let task = Task { () throws -> URLRequest in
            /// Set the task to nil just before the task is exited
            defer { refreshTokenTask = nil }

            let token = try await tokenProvider.retrieveOrRenewAccessToken()
            var authorizedRequest = newRequest
            authorizedRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            return authorizedRequest
        }

        refreshTokenTask = task

        return try await task.value
    }

    private func authorizeRequest(_ newRequest: URLRequest, using existingTask: Task<URLRequest, Error>) async throws -> URLRequest {
        let lastSignedRequest = try await existingTask.value
        var pendingRequest = newRequest
        pendingRequest.setValue(lastSignedRequest.allHTTPHeaderFields?["Authorization"], forHTTPHeaderField: "Authorization")
        return pendingRequest
    }
}
