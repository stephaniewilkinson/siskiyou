//
//  NewsFeedView.swift
//  siskiyou
//
//  Created by Claude on 4/7/25.
//

import SwiftUI

struct NewsFeedView: View {
    @EnvironmentObject private var appState: AppState
    private let settings = AppSettings.shared
    
    @State private var selectedCategory: NewsCategory? = nil
    @State private var showProfileSheet = false
    @State private var searchText = ""
    @State private var showClassroomNewsOnly = false
    @State private var showClassroomSubscriptionInfo = false
    
    // Get news items based on user's subscriptions and approval status
    private var userFilteredNewsItems: [NewsItem] {
        // Get user
        let user = appState.currentUser
        
        // Check if user is approved or admin
        let isApproved = user?.isApproved ?? false
        
        // For unapproved users, filter out classroom-specific content
        if user != nil && !isApproved {
            // Unapproved users only see school-wide announcements
            return NewsService.shared.newsItems.filter { $0.classroomId == nil }
        } else {
            // Approved users or admins see filtered content
            let newsItems = NewsService.shared.getNewsForUser(user)
            
            // If showClassroomNewsOnly toggle is on, only show classroom news
            if showClassroomNewsOnly && user != nil {
                return newsItems.filter { $0.category == .classroom }
            } else {
                return newsItems
            }
        }
    }
    
    // Filtered news items
    private var filteredNewsItems: [NewsItem] {
        // Start with all news items relevant to user
        let items = userFilteredNewsItems
        
        // Apply category filtering
        let categoryFiltered: [NewsItem]
        
        if showClassroomNewsOnly {
            // Show all classroom news
            categoryFiltered = items.filter { $0.category == .classroom }
        } else if selectedCategory != nil {
            // Normal category filtering
            categoryFiltered = items.filter { $0.category == selectedCategory }
        } else {
            // No category selected, show all available news
            categoryFiltered = items
        }
        
        // Filter by search text
        if searchText.isEmpty {
            return categoryFiltered
        } else {
            return categoryFiltered.filter { 
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.content.localizedCaseInsensitiveContains(searchText) ||
                $0.author.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // Check if user has classroom subscriptions
    private var hasClassroomSubscriptions: Bool {
        guard let user = appState.currentUser else { return false }
        return !user.classroomSubscriptions.isEmpty
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar and classroom toggle
                VStack(spacing: 10) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search news...", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // We don't need the toggle here anymore since we've moved the filtering
                    // to the category buttons
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // Category filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        // All news button
                        CategoryButton(
                            title: "All News",
                            icon: "newspaper",
                            color: Color.gray,
                            isSelected: selectedCategory == nil && !showClassroomNewsOnly,
                            action: { 
                                selectedCategory = nil
                                showClassroomNewsOnly = false
                            }
                        )
                        
                        // School-wide announcements
                        CategoryButton(
                            title: "School-wide",
                            icon: "building.columns.fill",
                            color: Color.blue,
                            isSelected: selectedCategory == .announcement && !showClassroomNewsOnly,
                            action: { 
                                selectedCategory = .announcement
                                showClassroomNewsOnly = false
                            }
                        )
                        
                        // Only show classroom filter for logged-in users with proper access
                        if let user = appState.currentUser {
                            // Check if user has classroom access
                            if user.isApproved {
                                // Show full classroom filters for approved users
                                if hasClassroomSubscriptions {
                                    // Single "Classrooms" button for all classroom news
                                    CategoryButton(
                                        title: "Classrooms",
                                        icon: "pencil.and.ruler",
                                        color: Color.teal,
                                        isSelected: showClassroomNewsOnly,
                                        action: { 
                                            showClassroomNewsOnly = true
                                            selectedCategory = .classroom
                                        }
                                    )
                                    
                                    // Show individual classrooms for more detailed filtering
                                    if !user.children.isEmpty {
                                        Divider()
                                            .frame(height: 20)
                                            .padding(.horizontal, 4)
                                    }
                                    
                                    ForEach(user.children, id: \.id) { child in
                                        CategoryButton(
                                            title: child.grade,
                                            icon: "graduationcap",
                                            color: Color.indigo,
                                            isSelected: false, // We're not implementing individual classroom filtering yet
                                            action: { 
                                                // In a future implementation, we could filter by specific classroom ID
                                                showClassroomNewsOnly = true
                                                selectedCategory = .classroom
                                            }
                                        )
                                    }
                                }
                            } else {
                                // Show classroom subscription request button for non-approved users
                                HStack {
                                    Button(action: {
                                        // Show classroom subscription request info
                                        showClassroomSubscriptionInfo = true
                                    }) {
                                        HStack {
                                            Image(systemName: "pencil.and.ruler")
                                            Text("Request Classroom Access")
                                        }
                                        .font(.caption)
                                        .padding(.vertical, 6)
                                        .padding(.horizontal, 12)
                                        .background(settings.primaryColor.opacity(0.1))
                                        .foregroundColor(settings.primaryColor)
                                        .cornerRadius(20)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }
                
                // News feed
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredNewsItems) { newsItem in
                            NewsItemCard(newsItem: newsItem)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 10)
                }
            }
            .navigationTitle("School News")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Image(systemName: "building.columns.fill")
                        .foregroundColor(settings.primaryColor)
                        .font(.title2)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showProfileSheet = true
                    }) {
                        Image(systemName: "person.circle")
                            .foregroundColor(settings.primaryColor)
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showProfileSheet) {
                ProfileView()
            }
            .sheet(isPresented: $showClassroomSubscriptionInfo) {
                ClassroomSubscriptionInfoView()
            }
        }
    }
}

// Category button
struct CategoryButton: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.subheadline)
                Text(title)
                    .font(.subheadline)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(isSelected ? color : Color.gray.opacity(0.1))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

// News item card
struct NewsItemCard: View {
    let newsItem: NewsItem
    private let settings = AppSettings.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with category and date
            HStack {
                HStack {
                    Image(systemName: newsItem.category.icon)
                        .font(.caption)
                    
                    Text(newsItem.category.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(newsItem.category.color.opacity(0.1))
                .foregroundColor(newsItem.category.color)
                .cornerRadius(12)
                
                // Show classroom if available
                if let classroomName = newsItem.classroomName {
                    Text(classroomName)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(Color.teal.opacity(0.1))
                        .foregroundColor(Color.teal)
                        .cornerRadius(12)
                }
                
                Spacer()
                
                if newsItem.isPinned {
                    Image(systemName: "pin.fill")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Text(newsItem.formattedDate)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // Show source type for classroom news
            if newsItem.category == .classroom {
                HStack {
                    Image(systemName: newsItem.sourceType.icon)
                        .font(.caption)
                    
                    Text(newsItem.sourceType.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(newsItem.sourceType == .official ? Color.indigo.opacity(0.1) : Color.orange.opacity(0.1))
                .foregroundColor(newsItem.sourceType == .official ? Color.indigo : Color.orange)
                .cornerRadius(12)
            }
            
            // Title
            Text(newsItem.title)
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(2)
            
            // Image if available
            if let imageName = newsItem.imageUrl, let _ = UIImage(named: imageName) {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 180)
                    .clipped()
                    .cornerRadius(8)
            }
            
            // Content preview
            Text(newsItem.content)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
                .padding(.bottom, 4)
            
            // Footer with author and read more
            HStack {
                Text("By \(newsItem.author)")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                NavigationLink(destination: NewsDetailView(newsItem: newsItem)) {
                    Text("Read more")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(settings.primaryColor)
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// News detail view
struct NewsDetailView: View {
    let newsItem: NewsItem
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Image
                if let imageName = newsItem.imageUrl, let _ = UIImage(named: imageName) {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 220)
                        .clipped()
                        .cornerRadius(8)
                }
                
                // Category and date
                HStack {
                    HStack {
                        Image(systemName: newsItem.category.icon)
                            .font(.caption)
                        
                        Text(newsItem.category.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(newsItem.category.color.opacity(0.1))
                    .foregroundColor(newsItem.category.color)
                    .cornerRadius(12)
                    
                    // Show classroom if available
                    if let classroomName = newsItem.classroomName {
                        Text(classroomName)
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(Color.teal.opacity(0.1))
                            .foregroundColor(Color.teal)
                            .cornerRadius(12)
                    }
                    
                    Spacer()
                    
                    Text(newsItem.formattedDate)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                // Show source type for classroom news
                if newsItem.category == .classroom {
                    HStack {
                        Image(systemName: newsItem.sourceType.icon)
                            .font(.caption)
                        
                        Text(newsItem.sourceType.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(newsItem.sourceType == .official ? Color.indigo.opacity(0.1) : Color.orange.opacity(0.1))
                    .foregroundColor(newsItem.sourceType == .official ? Color.indigo : Color.orange)
                    .cornerRadius(12)
                }
                
                // Title
                Text(newsItem.title)
                    .font(.title2)
                    .fontWeight(.bold)
                
                // Author
                Text("By \(newsItem.author)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                // Divider
                Divider()
                
                // Content
                Text(newsItem.content)
                    .font(.body)
                    .lineSpacing(8)
                
                Spacer(minLength: 50)
            }
            .padding()
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Profile view
struct ProfileView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    private let settings = AppSettings.shared
    @State private var showManageChildrenSheet = false
    @State private var showAdminPanel = false
    @State private var showTeacherNewsPanel = false
    @State private var showRequestClassroomAccess = false
    
    // Admin emails
    private let adminEmails = [
        "what.happens@gmail.com",
        "kristin.beers@siskiyouschool.org",
        "katherine.holden@siskiyouschool.org"
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // User avatar
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(settings.primaryColor)
                        .padding(.top, 40)
                    
                    if let user = appState.currentUser {
                        // User is logged in
                        Text("\(user.firstName) \(user.lastName)")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.top, 10)
                        
                        Text(user.email)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            
                        HStack(spacing: 10) {
                            // Role badge
                            Text(user.role.rawValue)
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(roleColor(for: user.role))
                                .cornerRadius(12)
                            
                            // Approval status for non-admin users
                            if !isAdmin(user: user) {
                                if user.isApproved {
                                    Text("Approved")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.green)
                                        .cornerRadius(12)
                                } else {
                                    Text("Awaiting Approval")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.orange)
                                        .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.top, 5)
                            
                        // Children section (if parent)
                        if user.role == .parent || user.role == .parentRep {
                            if user.isApproved {
                                childrenSection(user: user)
                            } else {
                                pendingApprovalSection
                            }
                        }
                        
                        // Teacher section (if teacher)
                        if user.role == .teacher {
                            teacherSection
                        }
                        
                        // Admin section
                        if isAdmin(user: user) {
                            adminSection
                        }
                    } else {
                        // Guest user
                        Text("Guest User")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.top, 10)
                        
                        Text("You're browsing as a guest")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Wrap the conditional in a VStack to provide a context for padding
                    VStack {
                        // Only show logout if user is logged in
                        if appState.currentUser != nil {
                            Button(action: {
                                appState.logout()
                            }) {
                                Text("Log Out")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(settings.primaryColor)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal, 30)
                        } else {
                            // For guest users, show login button
                            NavigationLink(destination: LoginView()) {
                                Text("Log In")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(settings.primaryColor)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal, 30)
                        }
                    }
                    .padding(.bottom, 50)
                }
                .padding(.horizontal)
            }
            .navigationTitle("Profile")
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
            .sheet(isPresented: $showManageChildrenSheet) {
                if let user = appState.currentUser {
                    ManageChildrenView(user: user)
                }
            }
        }
    }
    
    // Helper functions
    private func roleColor(for role: UserRole) -> Color {
        switch role {
        case .student:
            return .blue
        case .parent:
            return .green
        case .teacher:
            return .purple
        case .admin:
            return .red
        case .parentRep:
            return .orange
        }
    }
    
    // Admin helper method
    private func isAdmin(user: User) -> Bool {
        return adminEmails.contains(user.email.lowercased())
    }
    
    // Teacher section
    private var teacherSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Divider()
                .padding(.vertical, 5)
            
            HStack {
                Image(systemName: "person.fill.viewfinder")
                    .foregroundColor(.purple)
                Text("Teacher Tools")
                    .font(.headline)
                    .foregroundColor(.purple)
                
                Spacer()
            }
            
            Text("Manage classroom announcements and engage with your students' parents.")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Button(action: {
                showTeacherNewsPanel = true
            }) {
                HStack {
                    Image(systemName: "megaphone.fill")
                    Text("Manage Classroom Announcements")
                }
                .padding(.vertical, 12)
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
                .background(Color.purple.opacity(0.2))
                .foregroundColor(.purple)
                .cornerRadius(10)
            }
        }
        .padding(.vertical, 10)
        .sheet(isPresented: $showTeacherNewsPanel) {
            TeacherNewsView()
        }
    }
    
    // Pending approval message section (for classroom access)
    private var pendingApprovalSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Divider()
                .padding(.vertical, 5)
            
            HStack {
                Image(systemName: "person.badge.clock.fill")
                    .foregroundColor(.orange)
                Text("Classroom Access")
                    .font(.headline)
                    .foregroundColor(.orange)
                
                Spacer()
            }
            
            if appState.currentUser?.classroomSubscriptions.isEmpty ?? true {
                // User hasn't requested classroom access yet
                Text("Request access to your child's classroom to see classroom-specific announcements, events, and updates.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.vertical, 8)
                
                Button(action: {
                    showRequestClassroomAccess = true
                }) {
                    HStack {
                        Image(systemName: "person.badge.plus")
                        Text("Request Classroom Access")
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity)
                    .background(settings.primaryColor.opacity(0.2))
                    .foregroundColor(settings.primaryColor)
                    .cornerRadius(10)
                }
            } else {
                // User has requested but not yet approved
                Text("Your classroom access request is being reviewed by an administrator. You'll be notified once approved.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.vertical, 8)
                
                HStack {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.green)
                    Text("Request Submitted")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
            }
        }
        .padding(.vertical, 10)
        .sheet(isPresented: $showRequestClassroomAccess) {
            ClassroomSubscriptionInfoView()
        }
    }
    
    // Admin panel section
    private var adminSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Divider()
                .padding(.vertical, 5)
            
            HStack {
                HStack {
                    Image(systemName: "shield.fill")
                        .foregroundColor(.red)
                    Text("Admin Controls")
                        .font(.headline)
                        .foregroundColor(.red)
                }
                
                Spacer()
            }
            
            Text("Access user management and approval tools")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Button(action: {
                showAdminPanel = true
            }) {
                HStack {
                    Image(systemName: "person.badge.shield.checkmark")
                    Text("Open Admin Panel")
                }
                .padding(.vertical, 12)
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
                .background(Color.red.opacity(0.2))
                .foregroundColor(.red)
                .cornerRadius(10)
            }
        }
        .padding(.vertical, 10)
        .sheet(isPresented: $showAdminPanel) {
            AdminPanelView()
        }
    }
    
    // Children and classroom subscriptions section
    private func childrenSection(user: User) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Divider()
                .padding(.vertical, 5)
            
            HStack {
                Text("Children & Classrooms")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    showManageChildrenSheet = true
                }) {
                    Text("Manage")
                        .font(.subheadline)
                        .foregroundColor(settings.primaryColor)
                }
            }
            
            if user.children.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 10) {
                        Image(systemName: "person.2.badge.plus")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        
                        Text("No children added yet")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Button(action: {
                            showManageChildrenSheet = true
                        }) {
                            Text("Add a child")
                                .font(.callout)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(settings.primaryColor.opacity(0.2))
                                .cornerRadius(8)
                                .foregroundColor(settings.primaryColor)
                        }
                    }
                    Spacer()
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            } else {
                ForEach(user.children, id: \.id) { child in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "person.crop.circle")
                                .foregroundColor(settings.primaryColor)
                            
                            Text(child.name)
                                .font(.headline)
                            
                            Spacer()
                            
                            Text(child.grade)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        HStack {
                            Image(systemName: "person.bust")
                                .foregroundColor(.gray)
                                .font(.caption)
                            
                            Text(child.teacherName)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
            }
        }
        .padding(.top, 10)
    }
}

// Manage children view
struct ManageChildrenView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    let user: User
    private let settings = AppSettings.shared
    
    @State private var showAddChildSheet = false
    @State private var childName = ""
    @State private var childGrade = ""
    @State private var childTeacher = ""
    @State private var childClassroomId = ""
    
    // Sample classrooms - in a real app this would come from a database
    let sampleClassrooms = [
        ("5A", "5th Grade", "Ms. Wilson"),
        ("5B", "5th Grade", "Mr. Johnson"),
        ("4A", "4th Grade", "Ms. Martinez"),
        ("4B", "4th Grade", "Mr. Thompson"),
        ("3A", "3rd Grade", "Ms. Parker"),
        ("3B", "3rd Grade", "Ms. Rodriguez")
    ]
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Your Children")) {
                    ForEach(user.children, id: \.id) { child in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(child.name)
                                    .font(.headline)
                                Text("\(child.grade) - \(child.teacherName)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(settings.primaryColor)
                        }
                    }
                    .onDelete(perform: deleteChild)
                    
                    Button(action: {
                        showAddChildSheet = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Child")
                        }
                    }
                }
                
                Section(header: Text("Classroom Subscriptions")) {
                    Text("Parents automatically receive notifications for their children's classrooms.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.vertical, 5)
                        
                    ForEach(user.classroomSubscriptions, id: \.self) { classroomId in
                        if let (_, grade, teacher) = sampleClassrooms.first(where: { $0.0 == classroomId }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("\(grade) - \(teacher)")
                                        .font(.headline)
                                }
                                
                                Spacer()
                                
                                // In a real app, you would implement unsubscribe functionality
                                Button(action: {}) {
                                    Text("Subscribed")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(settings.primaryColor)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Manage Classrooms")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
            .sheet(isPresented: $showAddChildSheet) {
                addChildView
            }
        }
    }
    
    private var addChildView: some View {
        NavigationView {
            Form {
                Section(header: Text("Child Information")) {
                    TextField("Child's Name", text: $childName)
                    
                    // Classroom picker (simplified for demo)
                    Picker("Classroom", selection: $childClassroomId) {
                        Text("Select a classroom").tag("")
                        ForEach(sampleClassrooms, id: \.0) { classroom in
                            Text("\(classroom.1) - \(classroom.2)").tag(classroom.0)
                        }
                    }
                }
                
                Section {
                    Button(action: saveChild) {
                        Text("Add Child")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(settings.primaryColor)
                    .disabled(childName.isEmpty || childClassroomId.isEmpty)
                }
            }
            .navigationTitle("Add Child")
            .navigationBarItems(trailing: Button("Cancel") {
                showAddChildSheet = false
            })
        }
    }
    
    // Helper functions
    private func saveChild() {
        guard !childName.isEmpty, !childClassroomId.isEmpty else { return }
        
        // Find the selected classroom details
        if let classroom = sampleClassrooms.first(where: { $0.0 == childClassroomId }) {
            let newChild = Child(
                name: childName,
                grade: classroom.1,
                classroomId: classroom.0,
                teacherName: classroom.2
            )
            
            // In a real app, you would update the database
            // For now, we'll just update the local state
            if let index = appState.currentUser?.children.firstIndex(where: { $0.id == newChild.id }) {
                appState.currentUser?.children[index] = newChild
            } else {
                appState.currentUser?.children.append(newChild)
            }
            
            // Subscribe to the classroom
            if !appState.currentUser!.classroomSubscriptions.contains(classroom.0) {
                appState.currentUser?.classroomSubscriptions.append(classroom.0)
            }
        }
        
        // Reset fields and close sheet
        childName = ""
        childClassroomId = ""
        showAddChildSheet = false
    }
    
    private func deleteChild(at offsets: IndexSet) {
        // In a real app, you would update the database
        // For now, just update the local state
        
        // Get the classroom IDs of children being removed
        let classroomIdsToCheck = offsets.map { user.children[$0].classroomId }
        
        // Remove the children
        if let user = appState.currentUser {
            offsets.forEach { index in
                if index < user.children.count {
                    appState.currentUser?.children.remove(at: index)
                }
            }
            
            // Remove classroom subscriptions for classrooms that no longer have children
            for classroomId in classroomIdsToCheck {
                // If no remaining children are in this classroom, remove the subscription
                if !user.children.contains(where: { $0.classroomId == classroomId }) {
                    if let index = user.classroomSubscriptions.firstIndex(of: classroomId) {
                        appState.currentUser?.classroomSubscriptions.remove(at: index)
                    }
                }
            }
        }
    }
}

struct NewsFeedView_Previews: PreviewProvider {
    static var previews: some View {
        NewsFeedView()
            .environmentObject(AppState())
    }
}