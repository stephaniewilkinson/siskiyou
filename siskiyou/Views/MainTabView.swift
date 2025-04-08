//
//  MainTabView.swift
//  siskiyou
//
//  Created by Claude on 4/7/25.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var appState: AppState
    private let settings = AppSettings.shared
    
    var body: some View {
        TabView(selection: $appState.selectedTab) {
            // News Feed Tab
            NewsFeedView()
                .tabItem {
                    Label("News", systemImage: "newspaper")
                }
                .tag(AppTab.news)
            
            // Calendar Tab (placeholder)
            Text("Calendar")
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
                .tag(AppTab.calendar)
            
            // Resources Tab (placeholder)
            Text("Resources")
                .tabItem {
                    Label("Resources", systemImage: "folder")
                }
                .tag(AppTab.resources)
            
            // Settings Tab (placeholder)
            Text("Settings")
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(AppTab.settings)
        }
        .accentColor(settings.primaryColor)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(AppState())
    }
}