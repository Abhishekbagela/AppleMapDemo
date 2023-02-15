//
//  SearchView.swift
//  AppleMapDemo
//
//  Created by Abhishek Bagela on 15/02/23.
//

import SwiftUI
import MapKit

struct SearchView: View {
    @StateObject private var locationManager: LocationManager = .init()
    
    @State var navigation: String?
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack(spacing: 15) {
                    Button {
                        
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(.primary)
                    }
                    
                    Text("Search Location")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search location here", text: $locationManager.searchText)
                }
                .padding(.vertical, 12)
                .padding(.horizontal)
                .background {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(.gray)
                }
                .padding(.vertical, 10)
                
                
                if let places = locationManager.fetchedPlaces, !places.isEmpty {
                    List(places, id: \.self) { place in
                        Button {
                            //MARK: setting map region
                            if let coordinate = place.location?.coordinate {
                                locationManager.pickedLocation = .init(latitude: coordinate.latitude,
                                                                       longitude: coordinate.longitude)
                                locationManager.mapView.region = .init(center: coordinate,
                                                                       latitudinalMeters: 1000,
                                                                       longitudinalMeters: 1000)
                                
                                locationManager.addDraggablePin(coordinate: coordinate)
                                locationManager.updatePlacemark(location: .init(latitude: coordinate.latitude, longitude: coordinate.longitude))
                            }
                            
                            //MARK: Navigate to map view
                            navigation = "MAPVIEW"
                            
                        } label: {
                            HStack(spacing: 15) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.gray)
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(place.name ?? "")
                                        .font(.title3.bold())
                                        .foregroundColor(.primary)
                                    
                                    Text(place.locality ?? "")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    
                } else {
                    //MARK: Live location button
                    Button {
                        //MARK: setting map region
                        if let coordinate = locationManager.userLocation?.coordinate {
                            locationManager.mapView.region = .init(center: coordinate,
                                                                   latitudinalMeters: 1000,
                                                                   longitudinalMeters: 1000)
                            
                            locationManager.addDraggablePin(coordinate: coordinate)
                            locationManager.updatePlacemark(location: .init(latitude: coordinate.latitude, longitude: coordinate.longitude))
                        }
                        
                        //MARK: Navigate to map view
                        navigation = "MAPVIEW"
                        
                    } label: {
                        Label {
                            Text("Use current location")
                                .font(.callout)
                        } icon: {
                            Image(systemName: "location.north.circle.fill")
                        }
                        .foregroundColor(.green)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
            }
            .padding()
            .frame(maxHeight: .infinity, alignment: .top)
            .background {
                NavigationLink(tag: "MAPVIEW", selection: $navigation) {
                    MapViewSelection()
                        .environmentObject(locationManager)
                        .navigationBarHidden(true)
                } label: {}
                    .labelsHidden()
            }
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}

//MARK: MapView Live selection
struct MapViewSelection: View {
    @EnvironmentObject private var locationManager: LocationManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            MapViewHelper()
                .environmentObject(locationManager)
                .ignoresSafeArea()
            
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title2.bold())
                    .foregroundColor(.primary)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            
            //MARK: Displaying data
            if let place = locationManager.pickedPlacemark {
                VStack(spacing: 15) {
                    Text("Confirm Location")
                        .font(.title3)
                    
                    HStack(spacing: 15) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text(place.name ?? "")
                                .font(.title3.bold())
                            
                            Text(place.locality ?? "")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 10)
                    
                    Button {
                        
                    } label: {
                        Text("Confirm Location")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(.green)
                            }
                            .overlay(alignment: .trailing) {
                                Image(systemName: "arrow.right")
                                    .font(.title3.bold())
                                    .padding(.trailing)
                            }
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(.white)
                        .ignoresSafeArea()
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
            }
        }
        .onDisappear {
            locationManager.pickedLocation = nil
            locationManager.pickedPlacemark = nil
            
            locationManager.mapView.removeAnnotations(locationManager.mapView.annotations)
        }
    }
}

//MARK: UIKit map view
struct MapViewHelper: UIViewRepresentable {
    
    @EnvironmentObject var locationManager: LocationManager
    typealias Context = UIViewRepresentableContext<Self>
    typealias UIViewType = MKMapView
    
    func makeUIView(context: Context) -> MKMapView {
        return locationManager.mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {}
    
}

