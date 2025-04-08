//
//  AppSettings.swift
//  siskiyou
//
//  Created by Claude on 4/7/25.
//

import SwiftUI

// Define app-wide settings and theme
class AppSettings {
    // Singleton for app-wide access
    static let shared = AppSettings()
    
    // School colors
    let primaryColor = Color(red: 0.122, green: 0.247, blue: 0.545) // Deep Blue
    let secondaryColor = Color(red: 0.976, green: 0.557, blue: 0.204) // Gold/Yellow
    
    // Additional theme colors
    let accentColor = Color(red: 0.122, green: 0.247, blue: 0.545).opacity(0.8)
    let backgroundGradientTop = Color.white
    let backgroundGradientBottom = Color(red: 0.122, green: 0.247, blue: 0.545).opacity(0.1)
    
    // Typography
    let titleFont = Font.system(size: 32, weight: .bold)
    let headlineFont = Font.headline
    let bodyFont = Font.body
    
    // Button styles
    var primaryButtonStyle: some ButtonStyle {
        PrimaryButtonStyle()
    }
    
    var secondaryButtonStyle: some ButtonStyle {
        SecondaryButtonStyle()
    }
    
    private init() {} // Prevent multiple instances
}

// Button styles
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity)
            .background(AppSettings.shared.primaryColor)
            .foregroundColor(.white)
            .cornerRadius(12)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .shadow(color: AppSettings.shared.primaryColor.opacity(0.3), radius: 5, x: 0, y: 3)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .foregroundColor(AppSettings.shared.primaryColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppSettings.shared.primaryColor, lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}