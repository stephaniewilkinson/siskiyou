//
//  TeacherNewsView.swift
//  siskiyou
//
//  Created by Claude on 4/7/25.
//

import SwiftUI

struct TeacherNewsView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    private let settings = AppSettings.shared
    
    // State for creating new announcement
    @State private var showNewAnnouncementSheet = false
    @State private var title = ""
    @State private var content = ""
    @State private var isPinned = false
    
    // State for managing news items
    @State private var isLoading = false
    @State private var classroomNewsItems: [NewsItem] = []
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    // Teacher's classroom information
    private var classroomId: String {
        return appState.currentUser?.classroomSubscriptions.first ?? "Unknown"
    }
    
    private var classroomName: String {
        return "Your Classroom" // In a real app, get from user profile
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Teacher verification
                if !isTeacher {
                    unauthorizedView
                } else {
                    teacherContentView
                }
            }
            .navigationTitle("Classroom Announcements")
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
                if isTeacher {
                    loadClassroomNews()
                }
            }
        }
    }
    
    // Check if current user is a teacher
    private var isTeacher: Bool {
        return appState.currentUser?.role == .teacher
    }
    
    // Unauthorized view
    private var unauthorizedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.shield")
                .font(.system(size: 70))
                .foregroundColor(.red)
                .padding(.bottom, 20)
            
            Text("Teacher Access Only")
                .font(.title)
                .fontWeight(.bold)
            
            Text("This area is restricted to teachers only.")
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
    
    // Teacher content view
    private var teacherContentView: some View {
        VStack {
            // Classroom header
            HStack {
                VStack(alignment: .leading) {
                    Text(classroomName)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Manage your classroom announcements")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 10)
            
            if isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else {
                if classroomNewsItems.isEmpty {
                    emptyStateView
                } else {
                    newsListView
                }
            }
            
            // Add new announcement button
            Button(action: {
                showNewAnnouncementSheet = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("New Announcement")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(settings.primaryColor)
                .cornerRadius(12)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .sheet(isPresented: $showNewAnnouncementSheet) {
            createAnnouncementView
        }
    }
    
    // Empty state view
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "megaphone")
                .font(.system(size: 70))
                .foregroundColor(.gray)
            
            Text("No Announcements Yet")
                .font(.title3)
                .fontWeight(.medium)
            
            Text("Create your first classroom announcement by tapping the button below.")
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
    
    // News items list
    private var newsListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(classroomNewsItems) { item in
                    teacherNewsItemCard(item)
                        .padding(.horizontal)
                }
            }
            .padding(.vertical, 10)
        }
    }
    
    // News item card for teacher view
    private func teacherNewsItemCard(_ item: NewsItem) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with date and pinned status
            HStack {
                Text(item.formattedDate)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                if item.isPinned {
                    HStack {
                        Image(systemName: "pin.fill")
                        Text("Pinned")
                    }
                    .font(.caption)
                    .foregroundColor(.orange)
                    .padding(.vertical, 3)
                    .padding(.horizontal, 8)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            
            // Title
            Text(item.title)
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(2)
            
            // Content preview
            Text(item.content)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .padding(.bottom, 4)
            
            // Actions row
            HStack {
                Spacer()
                
                Button(action: {
                    // Edit action would go here
                }) {
                    HStack {
                        Image(systemName: "pencil")
                        Text("Edit")
                    }
                    .font(.caption)
                    .foregroundColor(settings.primaryColor)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                    .background(settings.primaryColor.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Button(action: {
                    // Delete action would go here
                }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete")
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                }
                .padding(.leading, 8)
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // Create announcement view
    private var createAnnouncementView: some View {
        NavigationView {
            Form {
                Section(header: Text("Announcement Details")) {
                    TextField("Title", text: $title)
                    
                    ZStack(alignment: .topLeading) {
                        if content.isEmpty {
                            Text("Content")
                                .foregroundColor(Color.gray.opacity(0.7))
                                .padding(.top, 8)
                                .padding(.leading, 5)
                        }
                        
                        TextEditor(text: $content)
                            .frame(minHeight: 150)
                    }
                    
                    Toggle("Pin this announcement", isOn: $isPinned)
                }
                
                Section {
                    Button(action: saveAnnouncement) {
                        Text("Post Announcement")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(
                        (!title.isEmpty && !content.isEmpty) 
                        ? settings.primaryColor 
                        : Color.gray
                    )
                    .disabled(title.isEmpty || content.isEmpty)
                }
            }
            .navigationTitle("New Announcement")
            .navigationBarItems(trailing: Button("Cancel") {
                showNewAnnouncementSheet = false
                title = ""
                content = ""
                isPinned = false
            })
        }
    }
    
    // Load classroom news
    private func loadClassroomNews() {
        isLoading = true
        
        // In a real app, you would fetch from the database
        // For now, filter the existing news items for this classroom
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.classroomNewsItems = NewsService.shared.newsItems.filter { 
                $0.classroomId == self.classroomId && $0.category == .classroom 
            }
            self.isLoading = false
        }
    }
    
    // Save new announcement
    private func saveAnnouncement() {
        guard !title.isEmpty && !content.isEmpty else { return }
        guard let teacher = appState.currentUser else { return }
        
        isLoading = true
        
        // Create new announcement
        let newAnnouncement = NewsItem(
            title: title,
            content: content,
            date: Date(),
            author: "\(teacher.fullName), Teacher",
            category: .classroom,
            imageUrl: nil,
            isPinned: isPinned,
            classroomId: classroomId,
            classroomName: classroomName
        )
        
        // In a real app, you would persist to database
        // For demo, just add to the in-memory list
        NewsService.shared.addNewsItem(newAnnouncement)
        
        // Refresh the list with the new item
        self.classroomNewsItems = NewsService.shared.newsItems.filter { 
            $0.classroomId == self.classroomId && $0.category == .classroom 
        }
        
        // Reset form and close sheet
        title = ""
        content = ""
        isPinned = false
        showNewAnnouncementSheet = false
        isLoading = false
        
        // Show success alert
        alertTitle = "Announcement Posted"
        alertMessage = "Your announcement has been posted to your classroom feed."
        showAlert = true
    }
}

struct TeacherNewsView_Previews: PreviewProvider {
    static var previews: some View {
        TeacherNewsView()
            .environmentObject(AppState())
    }
}