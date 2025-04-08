//
//  siskiyouApp.swift
//  siskiyou
//
//  Created by Stephanie Wilkinson on 3/4/25.
//

import SwiftUI
import SwiftData
import CloudKit
import Combine

@main
struct siskiyouApp: App {
    var sharedModelContainer: ModelContainer = {
        // Define schema with only Item model for now
        let schema = Schema([
            Item.self,
        ])
        
        // Create a simple configuration for testing or development
        // Using in-memory storage to avoid CloudKit dependencies
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true // Use in-memory storage to avoid CloudKit issues
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // Print detailed error for debugging
            print("Failed to create ModelContainer: \(error.localizedDescription)")
            if let swiftDataError = error as? SwiftDataError {
                print("SwiftData error details: \(swiftDataError)")
            }
            
            // Fallback with a minimal configuration
            do {
                return try ModelContainer(for: schema, configurations: [])
            } catch {
                fatalError("Could not create minimal ModelContainer: \(error)")
            }
        }
    }()

    // Use StateObject for app state management
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            if appState.hasCompletedOnboarding {
                // Show the main tab view with news feed as the default tab
                MainTabView()
                    .modelContainer(sharedModelContainer)
                    .environmentObject(appState)
            } else {
                // Show the landing page for login/signup
                LandingPage()
                    .environmentObject(appState)
            }
        }
    }
}
