//
//  tenisdemoApp.swift
//  tenisdemo
//
//  Created by Murat Uçar on 19.07.2026.
//

import SwiftUI

@main
struct tenisdemoApp: App {
    @StateObject private var authManager = AuthManager.shared
    
    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                ContentView()
            } else {
                LoginView()
            }
        }
    }
}
