//
//  MatchLocationManager.swift
//  tenisdemo
//
//  Created by Antigravity on 09.08.2026.
//

import Foundation
import CoreLocation
import Combine

struct TrackedLocation: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    let latitude: Double
    let longitude: Double
    let timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case timestamp
    }
    
    init(latitude: Double, longitude: Double, timestamp: Date = Date()) {
        self.latitude = latitude
        self.longitude = longitude
        self.timestamp = timestamp
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.latitude = try container.decode(Double.self, forKey: .latitude)
        self.longitude = try container.decode(Double.self, forKey: .longitude)
        
        // Decode timestamp supporting ISO 8601 string or Date directly
        if let date = try? container.decode(Date.self, forKey: .timestamp) {
            self.timestamp = date
        } else if let dateStr = try? container.decode(String.self, forKey: .timestamp),
                  let date = ISO8601DateFormatter().date(from: dateStr) {
            self.timestamp = date
        } else {
            self.timestamp = Date()
        }
    }
}

class MatchLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = MatchLocationManager()
    
    private let locationManager = CLLocationManager()
    
    @Published var locations: [TrackedLocation] = []
    @Published var isTracking = false
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 2.0 // Update every 2 meters
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.showsBackgroundLocationIndicator = true
    }
    
    func requestPermission() {
        locationManager.requestAlwaysAuthorization()
    }
    
    func startTracking() {
        requestPermission()
        locations.removeAll()
        isTracking = true
        locationManager.startUpdatingLocation()
        print("DEBUG [MatchLocationManager]: Location tracking started.")
    }
    
    func stopTracking() -> [TrackedLocation] {
        isTracking = false
        locationManager.stopUpdatingLocation()
        print("DEBUG [MatchLocationManager]: Location tracking stopped. Captured \(locations.count) points.")
        return locations
    }
    
    func reset() {
        locations.removeAll()
        isTracking = false
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard isTracking else { return }
        
        for location in locations {
            // Filter coordinates with bad accuracy (> 15 meters) to avoid GPS jumps
            guard location.horizontalAccuracy <= 15.0 else { continue }
            
            let tracked = TrackedLocation(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                timestamp: location.timestamp
            )
            
            DispatchQueue.main.async {
                self.locations.append(tracked)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("DEBUG [MatchLocationManager]: Location manager failed: \(error.localizedDescription)")
    }
    
    func calculateTotalDistance() -> Double {
        guard locations.count > 1 else { return 0.0 }
        var totalDistance: Double = 0.0
        for i in 0..<(locations.count - 1) {
            let p1 = CLLocation(latitude: locations[i].latitude, longitude: locations[i].longitude)
            let p2 = CLLocation(latitude: locations[i+1].latitude, longitude: locations[i+1].longitude)
            totalDistance += p1.distance(from: p2)
        }
        return totalDistance
    }
}
