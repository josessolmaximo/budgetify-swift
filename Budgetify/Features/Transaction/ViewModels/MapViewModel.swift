//
//  MapViewModel.swift
//  ExpenseTracker
//
//  Created by Joses Solmaximo on 21/11/22.
//

import SwiftUI
import MapKit
import CoreLocation

class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var mapView = MKMapView()
    @Published var region: MKCoordinateRegion!
    @Published var permissionDenied = false
    @Published var mapType: MKMapType = .standard
    @Published var searchText: String = ""
    @Published var places: [Place] = []
    @Published var selectedPlace: Place?
    @Published var didFailFetchingLocation = false
    
    var originalLocation: MKCoordinateRegion?
    private var transaction: Transaction
    
    init(transaction: Transaction) {
        self.transaction = transaction
    }
    
    func initializeLocation(){
        DispatchQueue.main.asyncAfter(deadline: .now()){
            if let coordinate = self.transaction.location.coordinate {
                self.region = MKCoordinateRegion(
                    center: CLLocationCoordinate2D(
                        latitude: coordinate.latitude,
                        longitude: coordinate.longitude),
                    latitudinalMeters: 1000,
                    longitudinalMeters: 1000
                )
                self.mapView.setRegion(self.region, animated: true)
                
                self.mapView.setVisibleMapRect(self.mapView.visibleMapRect, animated: true)
            } else if self.selectedPlace == nil {
                self.resetLocation()
            }
        }
    }
    
    func resetLocation(){
        guard let originalLocation = originalLocation else { return }
        self.mapView.setRegion(originalLocation, animated: true)
        self.mapView.setVisibleMapRect(self.mapView.visibleMapRect, animated: true)
    }
    
    func focusLocation(){
        guard let _ = region else { return }
        
        self.mapView.setRegion(self.region, animated: true)
        self.mapView.setVisibleMapRect(self.mapView.visibleMapRect, animated: true)
    }
    
    func updateRegion(coordinate: CLLocationCoordinate2D){
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        
        DispatchQueue.main.async {
            self.region = region
        }
    }
    
    func selectLocation(completionHandler: @escaping (Result<Place, GeocoderError>) -> Void){
        getPlacemark(forLocation: CLLocation(latitude: region.center.latitude, longitude: region.center.longitude)) { placemark, error in
            guard error == nil else {
                completionHandler(.failure(error!))
                return
            }
            
            completionHandler(.success(
                Place(
                    coordinate: Coordinate(
                        longitude: self.region.center.longitude,
                        latitude: self.region.center.latitude),
                    name: placemark?.name ?? "",
                    address: placemark?.formattedAddress())
            ))
        }
    }
    
    func selectLocationSuggestion(place: Place){
        searchText = ""
        
        guard let coordinate = place.coordinate else { return }
        
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude), latitudinalMeters: 1000, longitudinalMeters: 1000)
        
        self.region = region
        mapView.setRegion(region, animated: true)
        mapView.setVisibleMapRect(mapView.visibleMapRect, animated: true)
        
        selectedPlace = place
    }
    
    func getPlacemark(forLocation location: CLLocation, completionHandler: @escaping (CLPlacemark?, GeocoderError?) -> ()) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, completionHandler: {
            placemarks, error in

            if error != nil {
                completionHandler(nil, .unknown)
            } else if let placemarkArray = placemarks {
                if let placemark = placemarkArray.first {
                    completionHandler(placemark, nil)
                } else {
                    completionHandler(nil, .placemarkIsNil)
                }
            } else {
                completionHandler(nil, .unknown)
            }
        })

    }
    
    func searchLocation(){
        places.removeAll()
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        
        MKLocalSearch(request: request).start { response, error in
            guard let result = response else { return }
            self.places = result.mapItems.compactMap({ item -> Place? in
                return Place(coordinate: Coordinate(longitude: item.placemark.coordinate.longitude, latitude: item.placemark.coordinate.latitude), name: item.placemark.name ?? "", address: item.placemark.formattedAddress())
            })
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .denied:
            didFailFetchingLocation = true
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        default:
            ()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        didFailFetchingLocation = true
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let originalLocation = locations.first else { return }
        self.originalLocation = MKCoordinateRegion(center: originalLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        
        if let coordinate = transaction.location.coordinate {
            self.region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude),
                latitudinalMeters: 1000,
                longitudinalMeters: 1000
            )
            
            let pointAnnotation = MKPointAnnotation()
            pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
            pointAnnotation.title = transaction.location.name
            
            DispatchQueue.main.async {
                self.mapView.addAnnotation(pointAnnotation)
                self.mapView.setRegion(self.region, animated: true)
                
                self.mapView.setVisibleMapRect(self.mapView.visibleMapRect, animated: true)
            }
            
        } else {
            guard let location = locations.last else { return }
            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            self.region = region
            
            if self.originalLocation == nil {
                self.originalLocation = region
            }
            
            self.mapView.setRegion(self.region, animated: true)
            
            self.mapView.setVisibleMapRect(self.mapView.visibleMapRect, animated: true)
        }
    }
}
