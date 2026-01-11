//
//  Hotel.swift
//  hotelbooking
//
//  Created by hemanth kiran Polu on 1/9/26.
//


import Foundation
import CoreLocation

struct Hotel: Identifiable, Equatable {
    let id: String
    let name: String
    let priceText: String
    let starRatingText: String
    let imageURL: URL?
    let coordinate: CLLocationCoordinate2D?

    static func == (lhs: Hotel, rhs: Hotel) -> Bool {
        lhs.id == rhs.id
    }
}
