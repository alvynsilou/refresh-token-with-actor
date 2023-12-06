//
//  TokenProvider.swift
//  RefreshTokenWithActorSample
//
//  Created by Alvyn S on 06/12/2023.
//

import Foundation

public typealias Token = String

public protocol TokenProvider {

    /// Retrieve token from store and if expired renew it
    func retrieveOrRenewAccessToken() async throws -> Token
}
