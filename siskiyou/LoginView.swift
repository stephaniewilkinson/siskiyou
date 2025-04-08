//
//  LoginView.swift
//  siskiyou
//
//  Created by Claude on 4/7/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var appState: AppState
    
    // App settings
    private let settings = AppSettings.shared
    
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Welcome Back")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(settings.primaryColor)
                            
                            Text("Sign in to access your account")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.top, 20)
                    
                    // Error message if shown
                    if showError {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.subheadline)
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    // Login form
                    VStack(spacing: 20) {
                        // Email field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email Address")
                                .font(.headline)
                                .foregroundColor(Color.primary.opacity(0.8))
                            
                            TextField("Enter your email", text: $email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .textContentType(.emailAddress)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }
                        
                        // Password field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.headline)
                                .foregroundColor(Color.primary.opacity(0.8))
                            
                            // Use ZStack to create a more reliable password field that doesn't use iCloud Keychain
                            ZStack {
                                if password.isEmpty {
                                    HStack {
                                        Text("Enter your password")
                                            .foregroundColor(.gray)
                                            .padding(.leading, 8)
                                        Spacer()
                                    }
                                }
                                
                                SecureField("", text: $password)
                                    .disableAutocorrection(true)
                                    .autocapitalization(.none)
                                    .accessibilityIdentifier("loginPassword")
                            }
                            .padding(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                        
                        // Forgot password
                        HStack {
                            Spacer()
                            Button(action: {
                                // Handle forgot password
                            }) {
                                Text("Forgot Password?")
                                    .foregroundColor(settings.primaryColor)
                                    .font(.subheadline)
                            }
                        }
                        .padding(.top, -5)
                    }
                    .padding(.top, 10)
                    
                    // Login button
                    Button(action: {
                        loginUser()
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(settings.primaryColor)
                                .frame(height: 55)
                            
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Log In")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .disabled(email.isEmpty || password.isEmpty || isLoading)
                    .padding(.top, 30)
                    .padding(.horizontal, 20)
                    
                    // Don't have an account?
                    HStack {
                        Text("Don't have an account?")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                        
                        NavigationLink(destination: SignupView()) {
                            Text("Sign Up")
                                .fontWeight(.semibold)
                                .foregroundColor(settings.primaryColor)
                                .font(.subheadline)
                        }
                    }
                    .padding(.vertical)
                    
                    Spacer(minLength: 30)
                }
                .padding(.horizontal)
            }
            .navigationTitle("Log In")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // Login function
    private func loginUser() {
        guard !email.isEmpty && !password.isEmpty else {
            errorMessage = "Please enter email and password"
            showError = true
            return
        }
        
        isLoading = true
        showError = false
        
        // Use UserService to authenticate
        UserService.shared.loginUser(
            email: email,
            password: password
        ) { result in
            isLoading = false
            
            switch result {
            case .success(let user):
                // Update app state directly
                appState.loginCompleted(with: user)
                dismiss()
                
            case .failure(let error):
                // Check error type for pending approval
                let nsError = error as NSError
                if nsError.code == 403 {
                    errorMessage = "Your account is pending approval by an administrator. You will be notified once your account is approved."
                } else {
                    errorMessage = error.localizedDescription
                }
                showError = true
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AppState())
    }
}