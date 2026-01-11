//
//  HotelsService.swift
//  hotelbooking
//
//  Created by hemanth kiran Polu on 1/9/26.
//


import Foundation
import CoreLocation

protocol HotelsService {
    func fetchHotels(for city: City) async throws -> [Hotel]
}

final class LiveHotelsService: HotelsService {

    private let session: URLSession
    private let decoder: JSONDecoder
    private let imageBase = "https://media.expedia.com"

    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    func fetchHotels(for city: City) async throws -> [Hotel] {
        let (data, response) = try await session.data(from: city.url)

        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        guard (200...299).contains(http.statusCode) else {
            throw NetworkError.httpStatus(http.statusCode)
        }

        // Decode into a flexible root with multiple possible shapes
        // We try a couple of likely container models.
        if let rootA = try? decoder.decode(HotelsRootA.self, from: data) {
            return dedupe(rootA.hotels.map { $0.toHotel(imageBase: imageBase) })
        }
        if let rootB = try? decoder.decode(HotelsRootB.self, from: data) {
            return dedupe(rootB.hotelList.map { $0.toHotel(imageBase: imageBase) })
        }
        if let rootC = try? decoder.decode(HotelsRootC.self, from: data) {
            if let list = rootC.data.hotels ?? rootC.data.hotelList {
                return dedupe(list.map { $0.toHotel(imageBase: imageBase) })
            }
        }
        // Try common alternative root containers
        if let rootResults = try? decoder.decode(HotelsRootDResults.self, from: data) {
            return dedupe(rootResults.results.map { $0.toHotel(imageBase: imageBase) })
        }
        if let rootDataArray = try? decoder.decode(HotelsRootDDataArray.self, from: data) {
            return dedupe(rootDataArray.data.map { $0.toHotel(imageBase: imageBase) })
        }
        if let rootArray = try? decoder.decode([HotelDTO].self, from: data) {
            return dedupe(rootArray.map { $0.toHotel(imageBase: imageBase) })
        }
        
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Decode failed. Raw JSON preview:\n\(jsonString.prefix(2000))")
        }

        throw NetworkError.decodingFailed
    }

    private func dedupe(_ hotels: [Hotel]) -> [Hotel] {
        var seen = Set<String>()
        var result: [Hotel] = []
        result.reserveCapacity(hotels.count)
        for hotel in hotels {
            if seen.insert(hotel.id).inserted {
                result.append(hotel)
            }
        }
        return result
    }
}

struct HotelsRootDResults: Decodable {
    let results: [HotelDTO]
}

struct HotelsRootDDataArray: Decodable {
    let data: [HotelDTO]
}
