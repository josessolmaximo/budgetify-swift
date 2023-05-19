//
//  MapView.swift
//  ExpenseTracker
//
//  Created by Joses Solmaximo on 21/11/22.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    
    @EnvironmentObject var vm: MapViewModel
    
    func makeCoordinator() -> Coordinator {
        return MapView.Coordinator(self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = vm.mapView
        
        mapView.showsUserLocation = true
        mapView.delegate = context.coordinator
        
        vm.initializeLocation()
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.mapType = vm.mapType
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            self.parent.vm.updateRegion(coordinate: mapView.centerCoordinate)
        }
    }
}
