//
//  city.swift
//  hotelbooking
//
//  Created by hemanth kiran Polu on 1/9/26.
//

import Foundation

enum City: String, CaseIterable, Identifiable {
    case sanFrancisco = "San Francisco"
    case chicago = "Chicago"

    var id: String { rawValue }

    var url: URL {
        switch self {
        case .chicago:
            return URL(string: "https://a.travel-assets.com/mobile/json/chicago-hotels.json")!
        case .sanFrancisco:
            return URL(string: "https://a.travel-assets.com/mobile/json/san-francisco-hotels.json")!
        }
    }
}
