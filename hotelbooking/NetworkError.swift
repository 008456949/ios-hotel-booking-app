//
//  NetworkError.swift
//  hotelbooking
//
//  Created by hemanth kiran Polu on 1/9/26.
//


import Foundation

enum NetworkError: LocalizedError {
    case invalidResponse
    case httpStatus(Int)
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .invalidResponse: return "Invalid server response."
        case .httpStatus(let code): return "Request failed (HTTP \(code))."
        case .decodingFailed: return "Could not decode JSON."
        }
    }
}
