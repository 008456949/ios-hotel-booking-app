//
//  HotelsListView.swift
//  hotelbooking
//
//  Created by hemanth kiran Polu on 1/9/26.
//


import SwiftUI

struct HotelsListView: View {
    @StateObject private var vm = HotelsListViewModel()

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
                    List(vm.hotels.indices, id: \.self) { index in
                        let hotel = vm.hotels[index]
                        NavigationLink {
                            HotelDetailView(hotel: hotel)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(hotel.name).font(.headline).lineLimit(2)
                                Text(hotel.priceText).foregroundStyle(.secondary)
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
}
