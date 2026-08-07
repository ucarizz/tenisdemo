//
//  ContentView.swift
//  tenisdemo
//
//  Created by Murat Uçar on 19.07.2026.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    init() {
        // Tab Bar'ın arka planını koyu yapmak için UIKit özelleştirmesi yapıyoruz
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.05, green: 0.06, blue: 0.08, alpha: 1.0)
        
        // Aktif ve aktif olmayan sekmelerin renkleri
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(red: 0.86, green: 0.98, blue: 0.22, alpha: 1.0)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(red: 0.86, green: 0.98, blue: 0.22, alpha: 1.0)]
        appearance.stackedLayoutAppearance.normal.iconColor = .gray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Maç Sayacı (Match Tracker)
            MatchTrackerView()
                .tabItem {
                    Label("Maç Sayacı", systemImage: "tennisball.fill")
                }
                .tag(0)
            
            // Tab 2: Lig Fikstürü (League Fixtures)
            LeagueListView()
                .tabItem {
                    Label("Lig Fikstürü", systemImage: "list.bullet.rectangle.portrait.fill")
                }
                .tag(1)
            
            // Tab 3: Vuruş Analizi (Swing Analysis)
            SwingAnalysisView()
                .tabItem {
                    Label("Vuruş Analizi", systemImage: "gauge.with.needle.fill")
                }
                .tag(2)
            
            // Tab 4: Profilim (User Profile & Settings)
            ProfileView()
                .tabItem {
                    Label("Profilim", systemImage: "person.fill")
                }
                .tag(3)
        }
        .tint(Color(red: 0.86, green: 0.98, blue: 0.22)) // Aktif sekme rengi
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
