//
//  AppState.swift
//  siskiyou
//
//  Created by Claude on 4/7/25.
//

import SwiftUI
import Combine

// App main tabs
enum AppTab {
    case news
    case calendar
    case resources
    case settings
}

class AppState: ObservableObject {
    // Published properties automatically notify observers when changed
    @Published var hasCompletedOnboarding: Bool = false
    @Published var selectedTab: AppTab = .news
    @Published var currentUser: User? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Set up notification listeners
        setupNotifications()
    }
    
    private func setupNotifications() {
        // Listen for login/signup completion
        NotificationCenter.default.publisher(for: NSNotification.Name("ProceedToMainContent"))
            .sink { [weak self] _ in
                self?.hasCompletedOnboarding = true
            }
            .store(in: &cancellables)
        
        // Listen for logout
        NotificationCenter.default.publisher(for: NSNotification.Name("UserDidLogout"))
            .sink { [weak self] _ in
                self?.hasCompletedOnboarding = false
                self?.currentUser = nil
            }
            .store(in: &cancellables)
    }
    
    // Helper methods
    func loginCompleted(with user: User) {
        self.currentUser = user
        self.hasCompletedOnboarding = true
    }
    
    func logout() {
        self.currentUser = nil
        self.hasCompletedOnboarding = false
    }
}