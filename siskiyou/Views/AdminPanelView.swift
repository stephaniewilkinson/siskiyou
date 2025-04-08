//
//  AdminPanelView.swift
//  siskiyou
//
//  Created by Claude on 4/7/25.
//

import SwiftUI

struct AdminPanelView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    private let settings = AppSettings.shared
    
    // Admin emails
    private let adminEmails = [
        "what.happens@gmail.com",
        "kristin.beers@siskiyouschool.org",
        "katherine.holden@siskiyouschool.org"
    ]
    
    // State variables
    @State private var isLoading = false
    @State private var pendingUsers: [User] = []
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack {
                // Admin verification
                if !isAdmin {
                    unauthorizedView
                } else {
                    adminContentView
                }
            }
            .navigationTitle("Admin Panel")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .foregroundColor(settings.primaryColor)
            })
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onAppear {
                if isAdmin {
                    loadPendingUsers()
                }
            }
        }
    }
    
    // Check if current user is admin
    private var isAdmin: Bool {
        guard let currentUser = appState.currentUser else {
            return false
        }
        
        return adminEmails.contains(currentUser.email.lowercased())
    }
    
    // Unauthorized view
    private var unauthorizedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.shield")
                .font(.system(size: 70))
                .foregroundColor(.red)
                .padding(.bottom, 20)
            
            Text("Unauthorized Access")
                .font(.title)
                .fontWeight(.bold)
            
            Text("You do not have permission to access the admin panel. This area is restricted to school administrators only.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Return to App")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(settings.primaryColor)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)
        }
        .padding()
    }
    
    // Admin content view
    private var adminContentView: some View {
        VStack {
            // Tab selection
            Picker("Admin Functions", selection: $selectedTab) {
                Text("User Approvals").tag(0)
                Text("Teacher Management").tag(1)
                Text("User Management").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            .padding(.top, 10)
            
            if selectedTab == 0 {
                userApprovalsView
            } else if selectedTab == 1 {
                teacherManagementView
            } else {
                userManagementView
            }
        }
    }
    
    // User approvals tab
    private var userApprovalsView: some View {
        VStack {
            if isLoading {
                ProgressView()
                    .padding()
            } else if pendingUsers.isEmpty {
                VStack(spacing: 15) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 50))
                        .foregroundColor(.green)
                        .padding(.top, 40)
                    
                    Text("No Pending Approvals")
                        .font(.headline)
                    
                    Text("There are currently no users waiting for account approval.")
                        .multilineTextAlignment(.center)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 40)
                }
                .padding()
                
                Spacer()
                
                Button(action: loadPendingUsers) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Refresh")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(settings.primaryColor)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 20)
                
            } else {
                List {
                    ForEach(pendingUsers) { user in
                        UserApprovalRow(user: user, onApprove: { approveUser(user) }, onDeny: { denyUser(user) })
                    }
                }
                .listStyle(InsetGroupedListStyle())
                
                Button(action: loadPendingUsers) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Refresh")
                    }
                    .font(.headline)
                    .foregroundColor(settings.primaryColor)
                }
                .padding(.bottom, 10)
            }
        }
    }
    
    // Teacher management tab
    private var teacherManagementView: some View {
        VStack {
            // Add teacher header
            HStack {
                Text("Add New Teacher")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)
            
            // Teacher registration form
            VStack(spacing: 15) {
                VStack(alignment: .leading) {
                    Text("Email")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    TextField("teacher@siskiyouschool.org", text: .constant(""))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                VStack(alignment: .leading) {
                    Text("Name")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    HStack {
                        TextField("First name", text: .constant(""))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("Last name", text: .constant(""))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                
                VStack(alignment: .leading) {
                    Text("Classroom")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Picker(selection: .constant(""), label: Text("Select classroom")) {
                        Text("Kindergarten - Room 101").tag("K101")
                        Text("1st Grade - Room 203").tag("1A")
                        Text("2nd Grade - Room 205").tag("2A")
                        Text("3rd Grade - Room 207").tag("3A")
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Button(action: {
                    // This would save the teacher in a real app
                }) {
                    Text("Add Teacher")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(settings.primaryColor)
                        .cornerRadius(12)
                }
                .padding(.top, 10)
            }
            .padding()
            
            Divider()
                .padding(.vertical)
                
            // Current teachers list
            HStack {
                Text("Current Teachers")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)
            
            // Demo teacher list
            List {
                TeacherListItem(name: "Jennifer Wilson", email: "jennifer.wilson@siskiyouschool.org", classroom: "5th Grade - Room 101")
                TeacherListItem(name: "Michael Johnson", email: "michael.johnson@siskiyouschool.org", classroom: "3rd Grade - Room 203")
                TeacherListItem(name: "Sarah Parker", email: "sarah.parker@siskiyouschool.org", classroom: "Kindergarten - Room K1")
            }
            .listStyle(InsetGroupedListStyle())
        }
    }
    
    // User management tab
    private var userManagementView: some View {
        VStack {
            Text("User Management")
                .font(.headline)
                .padding()
            
            Text("This section allows you to manage existing users, reset passwords, and manage user roles.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.horizontal, 20)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            Text("User management features coming soon.")
                .italic()
                .foregroundColor(.gray)
            
            Spacer()
        }
    }
    
    // Load pending users
    private func loadPendingUsers() {
        isLoading = true
        pendingUsers = [] // Clear existing data
        
        UserService.shared.getPendingUsers { result in
            self.isLoading = false
            
            switch result {
            case .success(let users):
                self.pendingUsers = users
                
            case .failure(let error):
                self.alertTitle = "Error"
                self.alertMessage = "Failed to load pending users: \(error.localizedDescription)"
                self.showAlert = true
            }
        }
    }
    
    // Approve a user
    private func approveUser(_ user: User) {
        guard let recordID = user.recordID else {
            alertTitle = "Error"
            alertMessage = "Could not approve user - missing record ID"
            showAlert = true
            return
        }
        
        isLoading = true
        
        UserService.shared.approveUser(userId: recordID) { result in
            self.isLoading = false
            
            switch result {
            case .success(_):
                // Remove from pending list
                if let index = self.pendingUsers.firstIndex(where: { $0.id == user.id }) {
                    self.pendingUsers.remove(at: index)
                }
                
                self.alertTitle = "User Approved"
                self.alertMessage = "\(user.firstName) \(user.lastName) has been approved and can now access the app."
                self.showAlert = true
                
            case .failure(let error):
                self.alertTitle = "Error"
                self.alertMessage = "Failed to approve user: \(error.localizedDescription)"
                self.showAlert = true
            }
        }
    }
    
    // Deny a user
    private func denyUser(_ user: User) {
        guard let recordID = user.recordID else {
            alertTitle = "Error"
            alertMessage = "Could not deny user - missing record ID"
            showAlert = true
            return
        }
        
        isLoading = true
        
        UserService.shared.denyUser(userId: recordID) { result in
            self.isLoading = false
            
            switch result {
            case .success(_):
                // Remove from pending list
                if let index = self.pendingUsers.firstIndex(where: { $0.id == user.id }) {
                    self.pendingUsers.remove(at: index)
                }
                
                self.alertTitle = "User Denied"
                self.alertMessage = "\(user.firstName) \(user.lastName) has been denied access to the app."
                self.showAlert = true
                
            case .failure(let error):
                self.alertTitle = "Error"
                self.alertMessage = "Failed to deny user: \(error.localizedDescription)"
                self.showAlert = true
            }
        }
    }
}

// User approval row
struct UserApprovalRow: View {
    let user: User
    let onApprove: () -> Void
    let onDeny: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(user.firstName) \(user.lastName)")
                        .font(.headline)
                    
                    Text(user.email)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Approval/denial buttons
                HStack(spacing: 12) {
                    Button(action: onDeny) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                            .font(.title2)
                    }
                    
                    Button(action: onApprove) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.title2)
                    }
                }
            }
            
            // Registration date (hardcoded for demo)
            Text("Requested on \(formattedDate)")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
    }
    
    // Demo date (would be from user.createdAt in real implementation)
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: Date())
    }
}

// Teacher list item component
struct TeacherListItem: View {
    let name: String
    let email: String
    let classroom: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(name)
                .font(.headline)
            
            Text(email)
                .font(.caption)
                .foregroundColor(.gray)
            
            Text(classroom)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top, 3)
        }
        .padding(.vertical, 5)
    }
}

struct AdminPanelView_Previews: PreviewProvider {
    static var previews: some View {
        AdminPanelView()
            .environmentObject(AppState())
    }
}