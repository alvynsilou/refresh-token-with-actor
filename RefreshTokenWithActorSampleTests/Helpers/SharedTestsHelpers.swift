//
//  SharedTestsHelpers.swift
//  RefreshTokenWithActorSampleTests
//
//  Created by Alvyn S on 06/12/2023.
//

import Foundation

// MARK: Error

func anyError(domain: String = "test-domain-error", code: Int = 1000) -> Error {
    NSError(domain: domain, code: code)
}

// MARK: Network

func anyURL(with urlString: String = "https://any-url.com") -> URL {
    URL(string: urlString)!
}

func anyHTTPURLResponse(
    url: URL = anyURL(),
    statusCode: Int = 200
) -> HTTPURLResponse {
    HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
}

func anyURLRequest(url: URL = anyURL(),
                   httpMethod: String = "GET",
                   data: Data? = nil,
                   headers: [String: String] = [:]) -> URLRequest {
    var request = URLRequest(url: url)
    request.httpMethod = httpMethod
    request.httpBody = data

    return request.append(headers: headers)
}

func anyData(with content: String = "{\"id\": 4}") -> Data {
    Data(content.utf8)
}

extension URLRequest {
    func append(headers: [String: String]) -> URLRequest {
        var request = self
        headers.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }
        return request
    }
}
