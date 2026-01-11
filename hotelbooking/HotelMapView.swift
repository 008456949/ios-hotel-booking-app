//
//  HotelMapView.swift
//  hotelbooking
//
//  Created by hemanth kiran Polu on 1/9/26.
//


import SwiftUI
import MapKit

struct HotelMapView: View {
    let hotel: Hotel
    @State private var position: MapCameraPosition = .automatic

    var body: some View {
        Group {
            if let coord = hotel.coordinate {
                Map(position: $position) {
                    Marker(hotel.name, coordinate: coord)
                }
                .onAppear {
                    position = .region(
                        MKCoordinateRegion(
                            center: coord,
                            span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
                        )
                    )
                }
            } else {
                ContentUnavailableView("No Location",
                                      systemImage: "map",
                                      description: Text("This hotel has no coordinates."))
            }
        }
        .navigationTitle("Map")
        .navigationBarTitleDisplayMode(.inline)
    }
}
