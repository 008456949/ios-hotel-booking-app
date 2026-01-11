//
//  HotelDetailView.swift
//  hotelbooking
//
//  Created by hemanth kiran Polu on 1/9/26.
//


import SwiftUI

struct HotelDetailView: View {
    let hotel: Hotel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                if let url = hotel.imageURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView().frame(height: 220)
                        case .success(let image):
                            image.resizable().scaledToFill().frame(height: 220).clipped()
                        case .failure:
                            placeholder
                        @unknown default:
                            placeholder
                        }
                    }
                } else {
                    placeholder
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(hotel.name).font(.title2).bold()
                    Text("Rating: \(hotel.starRatingText)").font(.headline)
                    Text("Price: \(hotel.priceText)").font(.headline)
                }
                .padding(.horizontal)

                if hotel.coordinate != nil {
                    NavigationLink("Show on Map") {
                        HotelMapView(hotel: hotel)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal)
                } else {
                    Text("No map location available.")
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                }
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var placeholder: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.secondary.opacity(0.15))
            .frame(height: 220)
            .overlay(Image(systemName: "photo").imageScale(.large).foregroundStyle(.secondary))
            .padding(.horizontal)
    }
}
