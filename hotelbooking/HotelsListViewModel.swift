//
//  HotelsListViewModel.swift
//  hotelbooking
//
//  Created by hemanth kiran Polu on 1/9/26.
//


import Foundation
import Combine

@MainActor
final class HotelsListViewModel: ObservableObject {
    @Published var selectedCity: City = .sanFrancisco
    @Published var hotels: [Hotel] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let service: HotelsService

    init(service: HotelsService) {
        self.service = service
    }

    init() {
        self.service = LiveHotelsService()
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            hotels = try await service.fetchHotels(for: selectedCity)
        } catch {
            hotels = []
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }
}

