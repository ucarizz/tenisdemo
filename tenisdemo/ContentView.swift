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
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .zinc950
        
        // 1px crisp top hairline border
        appearance.shadowColor = .zinc800
        appearance.shadowImage = nil
        
        // Active & Inactive styles - Linear Neutral White / Zinc
        appearance.stackedLayoutAppearance.selected.iconColor = .zinc50
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.zinc50,
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]
        appearance.stackedLayoutAppearance.normal.iconColor = .zinc500
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.zinc500,
            .font: UIFont.systemFont(ofSize: 10, weight: .regular)
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Maç Sayacı
            MatchTrackerView()
                .tabItem {
                    Label("Maç", systemImage: "figure.tennis")
                }
                .tag(0)
            
            // Tab 2: Lig Fikstürü
            LeagueListView()
                .tabItem {
                    Label("Fikstür", systemImage: "list.bullet.rectangle")
                }
                .tag(1)
            
            // Tab 3: Vuruş Analizi
            SwingAnalysisView()
                .tabItem {
                    Label("Analiz", systemImage: "chart.xyaxis.line")
                }
                .tag(2)
            
            // Tab 4: Profil
            ProfileView()
                .tabItem {
                    Label("Profil", systemImage: "person")
                }
                .tag(3)
        }
        .tint(.zinc50)
        .background(Color.zinc950.ignoresSafeArea())
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
