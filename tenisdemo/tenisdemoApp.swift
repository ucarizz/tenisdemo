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
    @StateObject private var configManager = AppConfigManager.shared
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if authManager.isAuthenticated {
                    ContentView()
                } else {
                    LoginView()
                }
                
                // İsteğe Bağlı Güncelleme Popup Kartı (Kapatılabilir)
                if configManager.isSoftUpdateAvailable && !configManager.isSoftUpdateDismissed {
                    SoftUpdateView(
                        appStoreUrl: configManager.appStoreUrl,
                        message: configManager.updateMessage,
                        onDismiss: {
                            configManager.dismissSoftUpdate()
                        }
                    )
                }
                
                // Zorunlu Güncelleme Ekranı (Tam Ekran, Kapatılamaz, En Üst Katman)
                if configManager.isForceUpdateRequired {
                    ForceUpdateView(
                        appStoreUrl: configManager.appStoreUrl,
                        message: configManager.updateMessage
                    )
                    .transition(.opacity)
                }
            }
            .task {
                await configManager.checkVersion()
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    Task {
                        await configManager.checkVersion()
                    }
                }
            }
        }
    }
}
