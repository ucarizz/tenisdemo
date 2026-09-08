//
//  tenisdemoApp.swift
//  tenisdemo Watch App
//
//  Created by Murat Uçar on 19.07.2026.
//

import SwiftUI
import WatchKit
import HealthKit

class ExtensionDelegate: NSObject, WKApplicationDelegate {
    func handle(_ workoutConfiguration: HKWorkoutConfiguration) {
        print("DEBUG [WatchExtensionDelegate]: Received workoutConfiguration from iPhone - launching tennis match on Apple Watch!")
        DispatchQueue.main.async {
            WatchConnectivityManager.shared.handleWatchAppLaunchedFromPhone()
        }
    }
}

@main
struct tenisdemo_Watch_AppApp: App {
    @WKApplicationDelegateAdaptor(ExtensionDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
