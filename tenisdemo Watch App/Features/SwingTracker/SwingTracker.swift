//
//  SwingTracker.swift
//  tenisdemo Watch App
//
//  Created by Antigravity on 07.08.2026.
//

import Foundation
import CoreMotion
import WatchKit

struct LocalSwingRecord: Identifiable {
    let id = UUID()
    let speedKmh: Double
    let accelerationG: Double
    let swingType: String
    let recordedAt: Date
}

class SwingTracker: ObservableObject {
    private let motionManager = CMMotionManager()
    
    @Published var isTracking = false
    @Published var lastSwingSpeedKmh: Double = 0.0
    @Published var lastAccelerationG: Double = 0.0
    @Published var lastSwingType: String = "-"
    @Published var recentSwings: [LocalSwingRecord] = []
    
    private var lastSwingTime: Date = .distantPast
    private let swingCooldown: TimeInterval = 1.2 // İki vuruş arası minimum bekleme süresi (sn)
    private let swingThresholdG: Double = 3.5    // Vuruş algılama G-kuvveti eşiği
    
    func startTracking() {
        guard motionManager.isDeviceMotionAvailable else {
            print("DEBUG [SwingTracker]: Device motion is not available on this Apple Watch.")
            return
        }
        
        isTracking = true
        motionManager.deviceMotionUpdateInterval = 1.0 / 50.0 // 50 Hz frekans
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self = self, let motion = motion else { return }
            self.processMotionData(motion)
        }
        
        // Takip başladığına dair titreşim verelim
        WKInterfaceDevice.current().play(.start)
    }
    
    func stopTracking() {
        motionManager.stopDeviceMotionUpdates()
        isTracking = false
        WKInterfaceDevice.current().play(.stop)
    }
    
    private func processMotionData(_ motion: CMDeviceMotion) {
        let userAcc = motion.userAcceleration
        
        // Toplam ivme büyüklüğü (G cinsinden)
        let totalAccG = sqrt(userAcc.x * userAcc.x + userAcc.y * userAcc.y + userAcc.z * userAcc.z)
        
        // Eşik değer aşıldıysa vuruş olarak değerlendir
        if totalAccG > swingThresholdG {
            handleSwingDetected(accelerationG: totalAccG, rotationRate: motion.rotationRate, gravity: motion.gravity)
        }
    }
    
    private func handleSwingDetected(accelerationG: Double, rotationRate: CMRotationRate, gravity: CMAcceleration) {
        let now = Date()
        
        // Süre sınırlaması (debounce) kontrolü
        guard now.timeIntervalSince(lastSwingTime) > swingCooldown else { return }
        lastSwingTime = now
        
        // İvmeye göre gerçekçi tenis vuruş hızı (km/s) hesabı
        // İvme ile raket başı hızı fiziksel olarak ilişkilidir. (Örn: 6G ivme yaklaşık 110 km/s)
        let rawSpeed = accelerationG * 18.5
        let speedKmh = min(max(rawSpeed, 45.0), 215.0) // 45 km/s ile 215 km/s arasına sabitle
        
        // Basit jiroskop analizi ile vuruş türü tespiti:
        // Z ekseni dönüşü çok yüksekse -> Servis (smaç/overhead)
        // Y ekseninin pozitif/negatif olmasına göre -> Forehand / Backhand
        let type: String
        if abs(rotationRate.z) > 4.5 {
            type = "Servis"
        } else if rotationRate.y > 0 {
            type = "Forehand"
        } else {
            type = "Backhand"
        }
        
        DispatchQueue.main.async {
            self.lastSwingSpeedKmh = speedKmh
            self.lastAccelerationG = accelerationG
            self.lastSwingType = type
            
            // Son vuruş kaydını listeye ekle
            let record = LocalSwingRecord(
                speedKmh: speedKmh,
                accelerationG: accelerationG,
                swingType: type,
                recordedAt: now
            )
            
            self.recentSwings.insert(record, at: 0)
            if self.recentSwings.count > 5 {
                self.recentSwings.removeLast()
            }
            
            // Kullanıcıya vuruş titreşimi ver
            WKInterfaceDevice.current().play(.click)
            
            // Telefon companion'a veriyi göndererek DB'ye kaydetmesini sağla
            WatchConnectivityManager.shared.sendSwingRecord(
                speedKmh: speedKmh,
                accelerationG: accelerationG,
                swingType: type
            )
            
            print("DEBUG [SwingTracker]: Swing detected: \(type) - \(String(format: "%.1f", speedKmh)) km/h (\(String(format: "%.1f", accelerationG))G)")
        }
    }
}
