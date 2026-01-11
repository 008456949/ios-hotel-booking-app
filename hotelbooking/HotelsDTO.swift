//
//  HotelsRootA.swift
//  hotelbooking
//
//  Created by hemanth kiran Polu on 1/9/26.
//


import Foundation
import CoreLocation

struct FlexibleString: Decodable {
    let value: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            value = nil
            return
        }
        if let string = try? container.decode(String.self) {
            value = string
            return
        }
        if let int = try? container.decode(Int.self) {
            value = String(int)
            return
        }
        if let double = try? container.decode(Double.self) {
            value = String(double)
            return
        }
        if let bool = try? container.decode(Bool.self) {
            value = String(bool)
            return
        }
        value = nil
    }
}

struct FlexibleDouble: Decodable {
    let value: Double?

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            value = nil
            return
        }
        if let double = try? container.decode(Double.self) {
            value = double
            return
        }
        if let int = try? container.decode(Int.self) {
            value = Double(int)
            return
        }
        if let string = try? container.decode(String.self) {
            value = Double(string.trimmingCharacters(in: .whitespacesAndNewlines))
            return
        }
        value = nil
    }
}

// Possible JSON shape 1: { "hotels": [ ... ] }
struct HotelsRootA: Decodable {
    let hotels: [HotelDTO]
}

// Possible JSON shape 2: { "hotelList": [ ... ] }
struct HotelsRootB: Decodable {
    let hotelList: [HotelDTO]
}

struct HotelsRootC: Decodable {
    let data: Inner
    struct Inner: Decodable {
        let hotels: [HotelDTO]?
        let hotelList: [HotelDTO]?
    }
}

// Core DTO (keys may differ; keep optionals)
struct HotelDTO: Decodable {
    let id: FlexibleString?
    let hotelId: FlexibleString?
    let name: String?
    let hotelName: String?
    let localizedHotelName: String?
    let starRating: FlexibleDouble?
    let hotelGuestRating: FlexibleDouble?
    let price: PriceDTO?
    let images: [ImageDTO]?
    let imageUrl: String?
    let largeThumbnailUrl: String?
    let fallbackImage: String?
    let latitude: FlexibleDouble?
    let longitude: FlexibleDouble?
    let location: LocationDTO?

    // Additional possible keys from alternative feeds
    let title: String?
    let thumbnail: String?
    let image: String?
    let lng: FlexibleDouble?

    // Nested images container variant
    let imagesContainer: ImagesContainerDTO?
}

struct PriceDTO: Decodable {
    let display: String?
    let formatted: String?
    let amount: FlexibleDouble?
}

struct ImageDTO: Decodable {
    let url: String?
}

struct ImagesContainerDTO: Decodable {
    struct Main: Decodable { let url: String? }
    let main: Main?
}

struct LocationDTO: Decodable {
    let latitude: FlexibleDouble?
    let longitude: FlexibleDouble?
    let lat: FlexibleDouble?
    let lon: FlexibleDouble?
    let lng: FlexibleDouble?
}

extension HotelDTO {
    func toHotel(imageBase: String) -> Hotel {
        let resolvedId = id?.value ?? hotelId?.value ?? UUID().uuidString
        let resolvedName = name ?? hotelName ?? localizedHotelName ?? title ?? "Unknown Hotel"

        let priceText: String = {
            if let d = price?.display { return d }
            if let f = price?.formatted { return f }
            if let a = price?.amount?.value { return "$" + String(format: "%.0f", a) }
            return "—"
        }()

        let starText: String = {
            if let s = starRating?.value ?? hotelGuestRating?.value {
                return String(format: "%.1f ★", s)
            }
            return "—"
        }()

        let rawImage: String? = {
            if let u = imageUrl { return u }
            if let u = largeThumbnailUrl { return u }
            if let first = images?.first?.url { return first }
            if let t = thumbnail { return t }
            if let i = image { return i }
            if let u = fallbackImage { return u }
            if let m = imagesContainer?.main?.url { return m }
            return nil
        }()

        let imageURL: URL? = {
            guard let raw = rawImage else { return nil }
            if raw.lowercased().hasPrefix("http") { return URL(string: raw) }
            if raw.hasPrefix("/") { return URL(string: imageBase + raw) }
            return URL(string: imageBase + "/" + raw)
        }()

        let coord: CLLocationCoordinate2D? = {
            if let lat = latitude?.value, let lon = longitude?.value ?? lng?.value {
                return CLLocationCoordinate2D(latitude: lat, longitude: lon)
            }
            if let lat = location?.latitude?.value ?? location?.lat?.value,
               let lon = location?.longitude?.value ?? location?.lon?.value ?? location?.lng?.value {
                return CLLocationCoordinate2D(latitude: lat, longitude: lon)
            }
            return nil
        }()

        return Hotel(
            id: resolvedId,
            name: resolvedName,
            priceText: priceText,
            starRatingText: starText,
            imageURL: imageURL,
            coordinate: coord
        )
    }
}
