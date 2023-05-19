//
//  LocationSheet.swift
//  ExpenseTracker
//
//  Created by Joses Solmaximo on 06/10/22.
//

import SwiftUI
import UIKit
import CoreLocation
import MapKit
import Contacts
import OrderedCollections
import CachedAsyncImage

struct LocationSheet: View {
    @ObservedObject var mapVM: MapViewModel
    
    @FocusState var locationSearchFieldFocused: Bool
    
    @State var locationManager: CLLocationManager
    @State var isErrorAlertShown = false
    
    @Binding var isMapSheetShown: Bool
    @Binding var transaction: Transaction
    
    var map: some View {
        ZStack {
            MapView()
                .environmentObject(mapVM)
                .ignoresSafeArea()
                .overlay (
                    Image(systemName: "mappin")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                        .offset(y: -17)
                        .opacity(locationSearchFieldFocused ? 0 : 1)
                )
            
            VStack {
                HStack {
                    
                    VStack {
                        Button {
                            if mapVM.mapType == .standard {
                                mapVM.mapType = .hybrid
                            } else {
                                mapVM.mapType = .standard
                            }
                        } label: {
                            Image(systemName: mapVM.mapType == .standard ? "network" : "map")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                                .foregroundColor(.white)
                                .padding(10)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(.black)
                        )
                        
                        Button {
                            if mapVM.didFailFetchingLocation {
                                isErrorAlertShown.toggle()
                            } else {
                                mapVM.resetLocation()
                            }
                            
                        } label: {
                            if mapVM.originalLocation == nil && !mapVM.didFailFetchingLocation {
                                ProgressView()
                                    .frame(width: 25, height: 25)
                                    .padding(10)
                                    .foregroundColor(.white)
                                    .tint(.white)
                            } else {
                                Image(systemName: mapVM.didFailFetchingLocation ? "exclamationmark.triangle.fill" : "location.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(.white)
                                    .padding(10)
                            }
                            
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(.black)
                        )
                        
                        Spacer()
                    }
                    .padding()
                    
                    Spacer()
                }
                
                Spacer()
                
                HStack {
                    Button(action: {
                        mapVM.selectLocation(completionHandler: { result in
                            switch result {
                            case .failure(let error):
                                Logger.e(error.localizedDescription)
                            case .success(let place):
                                transaction.location = place
                                isMapSheetShown.toggle()
                            }
                        })
                    }, label: {
                        Text("Select Location")
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    })
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.black)
                    )
                    .opacity(locationSearchFieldFocused ? 0 : 1)
                }
            }
        }
        .alert(isPresented: $isErrorAlertShown) {
            Alert(title: Text("Location Not Found"), message: Text("We couldn't find your location. Either an error occured or you turned off location sharing. You can still enter in a location manually."), dismissButton: .default(Text("OK")))
            
        }
        
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    SearchTextField(keyword: $mapVM.searchText, placeholder: "Search Location")
                    
                    Button(action: {
                        isMapSheetShown.toggle()
                    }, label: {
                        Text("Cancel")
                    })
                }
                .onChange(of: mapVM.searchText) { value in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if value == mapVM.searchText {
                            mapVM.searchLocation()
                        }
                    }
                }
                .padding(.trailing, 20)
                .padding(.top, 12)
                
                if mapVM.searchText.isEmpty {
                    map
                } else {
                    ScrollView {
                        LazyVStack {
                            ForEach(mapVM.places) { place in
                                HStack {
                                    VStack {
                                        HStack {
                                            Text(place.name)
                                                .fontWeight(.medium)
                                            Spacer()
                                        }
                                        
                                        HStack {
                                            Text(place.address ?? "Unknown Address")
                                            Spacer()
                                        }
                                        .onTapGesture {
                                            mapVM.selectLocationSuggestion(place: place)
                                        }
                                    }
                                    
                                    Spacer()
                                }
                                
                                Divider()
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .onChange(of: mapVM.searchText) { newValue in
            if newValue == "" {
                locationSearchFieldFocused = false
            }
        }
    }
}

enum ImageSize: String {
    case large
    case small
}

struct FirebaseImage: View {
    @EnvironmentObject var tm: ThemeManager
    
    @StateObject private var vm = ImageURL()
    
    let size: ImageSize
    let id: String
    
    var body: some View {
        VStack {
            if let url = vm.imageURL {
                if size == .small {
                    CachedAsyncImage(
                        url: url,
                        content: { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .cornerRadius(10)
                        },
                        placeholder: {
                            tm.selectedTheme.tertiaryLabel
                                .frame(width: 80, height: 80)
                                .cornerRadius(10)
                        }
                    )
                } else {
                    CachedAsyncImage(
                        url: url,
                        content: { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                        },
                        placeholder: {
                            ProgressView()
                                .tint(.white)
                        }
                    )
                }
            }
        }
        .onAppear {
            vm.getURL(id: id)
        }
    }
}

extension CLPlacemark {
    func formattedAddress() -> String? {
        guard let postalAddress = postalAddress else {
            return nil
        }
        
        let formatter = CNPostalAddressFormatter()
        formatter.style = .mailingAddress
        
        return formatter.string(from: postalAddress).replacingOccurrences(of: "\n", with: ", ")
    }
    
}
