//
//  LandingPage.swift
//  siskiyou
//
//  Created by Claude on 4/7/25.
//

import SwiftUI

struct LandingPage: View {
    @State private var animateLogo = false
    @EnvironmentObject private var appState: AppState
    
    // Get app settings
    private let settings = AppSettings.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        settings.backgroundGradientTop,
                        settings.backgroundGradientBottom
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Large logo area
                    VStack(spacing: 15) {
                        Text("SISKIYOU SCHOOL")
                            .font(settings.titleFont)
                            .foregroundColor(settings.primaryColor)
                        
                        // Logo container with shadow and border
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 220, height: 220)
                                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                            
                            // Check if custom logo image exists, otherwise use placeholder
                            if let _ = UIImage(named: "SiskiyouLogo") {
                                Image("SiskiyouLogo")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 200, height: 200)
                            } else {
                                // Placeholder logo
                                VStack(spacing: 10) {
                                    Image(systemName: "building.columns.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 100, height: 100)
                                        .foregroundColor(settings.primaryColor)
                                    
                                    Text("Est. 1926")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(settings.primaryColor)
                                }
                                .frame(width: 200, height: 200)
                            }
                        }
                        .scaleEffect(animateLogo ? 1.0 : 0.9)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: animateLogo)
                        .onAppear {
                            animateLogo = true
                        }
                        
                        Text("Excellence in Education")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(settings.primaryColor)
                            .italic()
                            .padding(.top, 5)
                    }
                    .padding(.top, 60)
                    
                    Spacer()
                    
                    // Buttons
                    VStack(spacing: 16) {
                        // Login button with navigation link
                        NavigationLink(destination: LoginView()) {
                            Text("Log In")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(settings.primaryColor)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .shadow(color: settings.primaryColor.opacity(0.3), radius: 5, x: 0, y: 3)
                        
                        // Sign up button with navigation link
                        NavigationLink(destination: SignupView()) {
                            Text("Sign Up")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .foregroundColor(settings.primaryColor)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(settings.primaryColor, lineWidth: 1)
                                )
                                .cornerRadius(12)
                        }
                        
                        // Skip button
                        Button(action: {
                            // Update app state directly
                            appState.hasCompletedOnboarding = true
                        }) {
                            Text("Continue as Guest")
                                .font(.subheadline)
                                .foregroundColor(Color.gray.opacity(0.8))
                                .padding(.top, 8)
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 50)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct LandingPage_Previews: PreviewProvider {
    static var previews: some View {
        LandingPage()
            .environmentObject(AppState())
    }
}