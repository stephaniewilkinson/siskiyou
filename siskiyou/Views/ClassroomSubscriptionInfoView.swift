//
//  ClassroomSubscriptionInfoView.swift
//  siskiyou
//
//  Created by Claude on 4/7/25.
//

import SwiftUI

struct ClassroomSubscriptionInfoView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var appState: AppState
    private let settings = AppSettings.shared
    
    @State private var childName = ""
    @State private var grade = ""
    @State private var teacherName = ""
    @State private var relationToChild = ""
    @State private var additionalInfo = ""
    
    @State private var showSuccess = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Request Classroom Access")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(settings.primaryColor)
                        
                        Text("Please provide information about your child and their classroom to request access to classroom-specific announcements.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 10)
                    
                    // Form
                    VStack(spacing: 20) {
                        // Child's name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Child's Name")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("Enter child's full name", text: $childName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.words)
                        }
                        
                        // Grade
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Grade/Class")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("e.g., 3rd Grade, Kindergarten", text: $grade)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        // Teacher's name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Teacher's Name")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("e.g., Ms. Smith", text: $teacherName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        // Relation to child
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Your Relation to the Child")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("e.g., Parent, Guardian, Grandparent", text: $relationToChild)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        // Additional info
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Additional Information (Optional)")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            ZStack(alignment: .topLeading) {
                                if additionalInfo.isEmpty {
                                    Text("Any additional details that might help verify your request...")
                                        .foregroundColor(Color.gray.opacity(0.7))
                                        .padding(.top, 8)
                                        .padding(.leading, 5)
                                }
                                
                                TextEditor(text: $additionalInfo)
                                    .frame(minHeight: 120)
                                    .padding(1)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                            }
                            .frame(minHeight: 120)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                    
                    // Submit button
                    Button(action: submitRequest) {
                        Text("Submit Request")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(formIsValid ? settings.primaryColor : Color.gray)
                            .cornerRadius(12)
                    }
                    .disabled(!formIsValid)
                    .padding(.top, 10)
                    
                    // Request note
                    Text("Note: An administrator will review your request and grant access to the appropriate classroom news feed. You'll be notified when your request is approved.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 10)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
            .navigationTitle("Classroom Access")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .alert(isPresented: $showSuccess) {
                Alert(
                    title: Text("Request Submitted"),
                    message: Text("Your classroom access request has been submitted successfully. You'll be notified once an administrator approves your request."),
                    dismissButton: .default(Text("OK")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
        }
    }
    
    // Form validation
    private var formIsValid: Bool {
        !childName.isEmpty &&
        !grade.isEmpty &&
        !teacherName.isEmpty &&
        !relationToChild.isEmpty
    }
    
    // Submit request
    private func submitRequest() {
        // In a real app, you would send this request to a backend service
        // For this demo, we'll just simulate a successful submission
        
        // Save the request info (in a real app)
        // ...
        
        // Show success message
        showSuccess = true
    }
}

struct ClassroomSubscriptionInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ClassroomSubscriptionInfoView()
            .environmentObject(AppState())
    }
}