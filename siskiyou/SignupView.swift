//
//  SignupView.swift
//  siskiyou
//
//  Created by Claude on 4/7/25.
//

import SwiftUI

struct SignupView: View {
    @EnvironmentObject private var appState: AppState
    
    // App settings
    private let settings = AppSettings.shared
    
    // User input
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    
    // UI state
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccessAlert = false
    @State private var createdUser: User? = nil
    
    // Environment
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    // Form validation
    var isFormValid: Bool {
        !firstName.isEmpty && 
        !lastName.isEmpty && 
        !email.isEmpty && 
        email.contains("@") && 
        password.count >= 6
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Create Account")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(settings.primaryColor)
                        
                        Text("Join the Siskiyou School community")
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
                
                // Sign up form
                VStack(spacing: 20) {
                    // Personal info section
                    GroupBox(label: Text("Personal Information")
                        .font(.headline)
                        .foregroundColor(settings.primaryColor)
                    ) {
                        VStack(spacing: 16) {
                            // First Name
                            VStack(alignment: .leading, spacing: 8) {
                                Text("First Name")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                TextField("Enter your first name", text: $firstName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .textContentType(.givenName)
                                    .autocapitalization(.words)
                                    .disableAutocorrection(true)
                            }
                            
                            // Last Name
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Last Name")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                TextField("Enter your last name", text: $lastName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .textContentType(.familyName)
                                    .autocapitalization(.words)
                                    .disableAutocorrection(true)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .padding(.bottom, 5)
                    
                    // Account info section
                    GroupBox(label: Text("Account Information")
                        .font(.headline)
                        .foregroundColor(settings.primaryColor)
                    ) {
                        VStack(spacing: 16) {
                            // Email
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email Address")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                TextField("Enter your email", text: $email)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.emailAddress)
                                    .textContentType(.emailAddress)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            }
                            
                            // Password
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                // Use ZStack to create a more reliable password field that doesn't use iCloud Keychain
                                ZStack {
                                    if password.isEmpty {
                                        HStack {
                                            Text("Choose a password (min. 6 characters)")
                                                .foregroundColor(.gray)
                                                .padding(.leading, 8)
                                            Spacer()
                                        }
                                    }
                                    
                                    SecureField("", text: $password)
                                        .disableAutocorrection(true)
                                        .autocapitalization(.none)
                                        .accessibilityIdentifier("password")
                                }
                                .padding(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                            }
                            
                            // Password validation and guidance
                            if !password.isEmpty {
                                VStack(alignment: .leading, spacing: 4) {
                                    if password.count < 6 {
                                        Text("Password must be at least 6 characters")
                                            .font(.caption)
                                            .foregroundColor(.red)
                                    }
                                    
                                    Text("For a strong password, include uppercase letters, numbers, and special characters")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.top, 4)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                .padding(.horizontal, 5)
                
                // Create account button
                Button(action: {
                    createAccount()
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isFormValid ? settings.primaryColor : Color.gray.opacity(0.3))
                            .frame(height: 55)
                        
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Create Account")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                    }
                }
                .disabled(!isFormValid || isLoading)
                .padding(.top, 10)
                .padding(.horizontal, 20)
                
                // Terms and Conditions
                Text("By creating an account, you agree to our Terms of Service and Privacy Policy")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.top, 10)
                
                // Already have an account?
                HStack {
                    Text("Already have an account?")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                    
                    Button("Log In") {
                        dismiss()
                    }
                    .foregroundColor(settings.primaryColor)
                    .font(.subheadline.weight(.semibold))
                }
                .padding(.vertical)
                
                Spacer(minLength: 30)
            }
            .padding(.horizontal)
        }
        .alert(isPresented: $showSuccessAlert) {
            // Different message based on admin status
            if createdUser != nil && isAdmin(email: createdUser!.email) {
                return Alert(
                    title: Text("Admin Account Created"),
                    message: Text("Your administrator account has been created successfully!"),
                    dismissButton: .default(Text("Continue")) {
                        // Use appState to proceed to main content
                        if let user = createdUser {
                            appState.loginCompleted(with: user)
                        }
                        dismiss()
                    }
                )
            } else {
                return Alert(
                    title: Text("Account Created"),
                    message: Text("Your account has been created successfully! You can now browse school-wide announcements. Request classroom access from your profile if you'd like to see classroom-specific content."),
                    dismissButton: .default(Text("Continue")) {
                        if let user = createdUser {
                            appState.loginCompleted(with: user)
                        }
                        dismiss()
                    }
                )
            }
        }
        .navigationTitle("Sign Up")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // Helper to check if email is admin
    private func isAdmin(email: String) -> Bool {
        let adminEmails = [
            "what.happens@gmail.com",
            "kristin.beers@siskiyouschool.org",
            "katherine.holden@siskiyouschool.org"
        ]
        return adminEmails.contains(email.lowercased())
    }
    
    // Create account function
    private func createAccount() {
        guard isFormValid else {
            errorMessage = "Please fill in all fields correctly"
            showError = true
            return
        }
        
        isLoading = true
        showError = false
        
        // Use UserService to create account with CloudKit
        UserService.shared.createUser(
            firstName: firstName,
            lastName: lastName,
            email: email,
            password: password
        ) { result in
            isLoading = false
            
            switch result {
            case .success(let user):
                // Store the created user and show success alert
                createdUser = user
                showSuccessAlert = true
                
            case .failure(let error):
                // Show error message
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SignupView()
                .environmentObject(AppState())
        }
    }
}