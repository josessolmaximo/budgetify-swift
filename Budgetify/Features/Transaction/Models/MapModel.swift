//
//  MapModel.swift
//  ExpenseTracker
//
//  Created by Joses Solmaximo on 22/11/22.
//

import SwiftUI
import MapKit

struct Coordinate: Codable, Hashable {
    var longitude: Double
    var latitude: Double
    
    var dictionary: [String: Any] {
        return [
            "longitude": longitude,
            "latitude": latitude
        ]
    }
    
    init(longitude: Double, latitude: Double) {
        self.longitude = longitude
        self.latitude = latitude
    }
    
    init?(dict: [String: Any]){
        guard let longitude = dict["longitude"] as? Double,
              let latitude = dict["latitude"] as? Double
        else {
            return nil
        }
        
        self.longitude = longitude
        self.latitude = latitude
    }
}

struct Place: Identifiable, Codable, Hashable {
    var id = UUID()
    var coordinate: Coordinate?
    var name: String
    var address: String? = ""
    
    var dictionary: [String: Any] {
        return [
            "id": id.uuidString,
            "coordinate": coordinate?.dictionary ?? [:],
            "name": name,
            "address": address ?? ""
        ]
    }
    
    init(id: UUID = UUID(),
         coordinate: Coordinate? = nil,
         name: String,
         address: String? = ""
    ) {
        self.id = id
        self.coordinate = coordinate
        self.name = name
        self.address = address
    }
    
    init?(dict: [String: Any]){
        guard let id = dict["id"] as? String,
              let name = dict["name"] as? String,
              let address = dict["address"] as? String
        else {
            return nil
        }
        
        self.id = UUID(uuidString: id)!
        self.coordinate = Coordinate(dict: dict["coordinate"] as? [String: Any] ?? [:])
        self.name = name
        self.address = address
    }
}

enum GeocoderError: Error {
    case placemarkIsNil
    case unknown
}
