//
//  AuthProvider.swift
//  RefreshTokenWithActorSample
//
//  Created by Alvyn S on 06/12/2023.
//

import Foundation

public protocol AuthProvider {

    /// Synchronize request to have only one refresh token task
    func authorized(_ request: URLRequest) async throws -> URLRequest
}
