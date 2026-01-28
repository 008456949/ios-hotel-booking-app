//
//  HotelsListView.swift
//  hotelbooking
//
//  Created by hemanth kiran Polu on 1/9/26.
//


import SwiftUI

struct HotelsListView: View {
    @StateObject private var vm = HotelsListViewModel()
    @StateObject private var favoritesManager = FavoritesManager.shared
    @State private var showFavoritesOnly = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Picker("City", selection: $vm.selectedCity) {
                    ForEach(City.allCases) { city in
                        Text(city.rawValue).tag(city)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .onChange(of: vm.selectedCity) { _, _ in
                    Task { await vm.load() }
                }
                
                Toggle("Show Favorites Only", isOn: $showFavoritesOnly)
                    .padding(.horizontal)

                if vm.isLoading {
                    ProgressView("Loading…")
                    Spacer()
                } else if let msg = vm.errorMessage {
                    VStack(spacing: 10) {
                        Text("Error").font(.headline)
                        Text(msg).foregroundStyle(.secondary).multilineTextAlignment(.center)
                        Button("Retry") { Task { await vm.load() } }
                            .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    Spacer()
                } else {
                    List(filteredHotels.indices, id: \.self) { index in
                        let hotel = filteredHotels[index]
                        NavigationLink {
                            HotelDetailView(hotel: hotel)
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(hotel.name).font(.headline).lineLimit(2)
                                    Text(hotel.priceText).foregroundStyle(.secondary)
                                }
                                Spacer()
                                if favoritesManager.isFavorite(hotel.id) {
                                    Image(systemName: "heart.fill")
                                        .foregroundStyle(.red)
                                }
                            }
                            .padding(.vertical, 6)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Hotels")
        }
        .task {
            await vm.load()
        }
    }
    
    private var filteredHotels: [Hotel] {
        if showFavoritesOnly {
            return vm.hotels.filter { favoritesManager.isFavorite($0.id) }
        } else {
            return vm.hotels
        }
    }
}
