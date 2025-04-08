//
//  NewsItem.swift
//  siskiyou
//
//  Created by Claude on 4/7/25.
//

import Foundation
import SwiftUI

struct NewsItem: Identifiable {
    let id = UUID()
    let title: String
    let content: String
    let date: Date
    let author: String
    let category: NewsCategory
    let imageUrl: String?
    let isPinned: Bool
    
    // Classroom-specific properties
    let classroomId: String? // Optional - null means school-wide
    let classroomName: String? // Optional display name for the classroom
    let sourceType: NewsSourceType // The source of the news (official/parent rep)
    
    // Computed property to format dates
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    // Initialize with default values for new properties
    init(title: String, content: String, date: Date, author: String, category: NewsCategory, 
         imageUrl: String?, isPinned: Bool, classroomId: String? = nil, classroomName: String? = nil, 
         sourceType: NewsSourceType = .official) {
        self.title = title
        self.content = content
        self.date = date
        self.author = author
        self.category = category
        self.imageUrl = imageUrl
        self.isPinned = isPinned
        self.classroomId = classroomId
        self.classroomName = classroomName
        self.sourceType = sourceType
    }
}

enum NewsCategory: String, CaseIterable {
    case announcement = "Announcement"
    case event = "Event"
    case sports = "Sports"
    case academic = "Academic"
    case community = "Community"
    case classroom = "Classroom" // New category for classroom-specific news
    
    var icon: String {
        switch self {
        case .announcement: return "megaphone"
        case .event: return "calendar"
        case .sports: return "sportscourt"
        case .academic: return "book"
        case .community: return "person.3"
        case .classroom: return "pencil.and.ruler"
        }
    }
    
    var color: Color {
        switch self {
        case .announcement: return Color.red
        case .event: return Color.blue
        case .sports: return Color.green
        case .academic: return Color.purple
        case .community: return Color.orange
        case .classroom: return Color.teal
        }
    }
}

// News source type - to distinguish between official announcements and parent rep posts
enum NewsSourceType: String, Codable {
    case official = "Official"
    case parentRep = "Parent Representative"
    
    var icon: String {
        switch self {
        case .official: return "building.columns.fill"
        case .parentRep: return "person.2.fill"
        }
    }
}

// Sample news data
class NewsService {
    static let shared = NewsService()
    
    var newsItems: [NewsItem] = [
        // School-wide news items
        NewsItem(
            title: "Principal's Welcome Message",
            content: "Welcome back to Siskiyou School for the 2025-2026 academic year! We're excited to see all our students return and to welcome new faces to our community. This year promises many enriching opportunities for learning and growth. Our teachers have prepared engaging curricula, and our facilities have been refreshed over the summer. Remember, our doors are always open for questions or concerns. Let's make this the best year yet!",
            date: Date().addingTimeInterval(-86400 * 2), // 2 days ago
            author: "Dr. Sarah Johnson, Principal",
            category: .announcement,
            imageUrl: "school_welcome",
            isPinned: true,
            classroomId: nil,
            classroomName: nil
        ),
        NewsItem(
            title: "Fall Sports Tryouts Begin Next Week",
            content: "Attention all student athletes! Tryouts for fall sports begin next week. Soccer, cross country, and volleyball teams are looking for new members. Please make sure to have your physical examination forms completed before tryouts. Schedule: Soccer - Monday 3:30 PM, Cross Country - Tuesday 3:30 PM, Volleyball - Wednesday 3:30 PM. All tryouts will take place at the main athletic field or gymnasium. Contact Coach Williams for more information.",
            date: Date().addingTimeInterval(-86400), // 1 day ago
            author: "Athletic Department",
            category: .sports,
            imageUrl: "sports_tryouts",
            isPinned: false,
            classroomId: nil,
            classroomName: nil
        ),
        NewsItem(
            title: "New Science Lab Equipment Arrives",
            content: "We're excited to announce that our science department has received new state-of-the-art laboratory equipment. This update includes digital microscopes, chemistry apparatus, and interactive physics demonstration tools. The new equipment will enhance our STEM curriculum and provide students with hands-on experience using the same technology found in modern research facilities. Special thanks to the Siskiyou Parents Association for their fundraising efforts that made this possible.",
            date: Date().addingTimeInterval(-43200), // 12 hours ago
            author: "Dr. Michael Chen, Science Department Head",
            category: .academic,
            imageUrl: "science_lab",
            isPinned: false,
            classroomId: nil,
            classroomName: nil
        ),
        NewsItem(
            title: "Fall Festival Coming October 15th",
            content: "Mark your calendars for the annual Siskiyou School Fall Festival! This beloved community tradition features games, food, music, and the famous pumpkin decorating contest. We need parent volunteers to help with booths and activities. Please sign up through the school portal if you can assist. The festival runs from 11:00 AM to 4:00 PM on the main campus grounds. All proceeds support the school's arts program.",
            date: Date().addingTimeInterval(-21600), // 6 hours ago
            author: "Events Committee",
            category: .event,
            imageUrl: "fall_festival",
            isPinned: true,
            classroomId: nil,
            classroomName: nil
        ),
        NewsItem(
            title: "Library Book Drive Success",
            content: "Thank you to everyone who contributed to our library book drive! We collected over 500 books that will help expand our library's collection. Special recognition goes to Ms. Rodriguez's 3rd grade class for bringing in the most donations. The new books span various genres and reading levels, ensuring there's something for every reader. The library staff is currently processing the donations, and they should be available for checkout within the next two weeks.",
            date: Date().addingTimeInterval(-3600), // 1 hour ago
            author: "Ms. Patricia Lee, Librarian",
            category: .community,
            imageUrl: "library_books",
            isPinned: false,
            classroomId: nil,
            classroomName: nil
        ),
        NewsItem(
            title: "Math Olympiad Team Forming",
            content: "Calling all math enthusiasts! The Siskiyou Math Olympiad Team is now accepting applications for the 2025-2026 competition season. Students in grades 6-8 who enjoy mathematical challenges are encouraged to apply. The team will meet Tuesdays and Thursdays after school to prepare for regional and state competitions. Application forms are available from the Math Department or can be downloaded from the school website. Applications are due by September 15th.",
            date: Date(), // Now
            author: "Mr. Robert Takahashi, Math Coach",
            category: .academic,
            imageUrl: "math_olympiad",
            isPinned: false,
            classroomId: nil,
            classroomName: nil
        ),
        
        // Classroom-specific news items (official)
        NewsItem(
            title: "5th Grade Science Project Due Next Week",
            content: "Dear 5th Grade parents, this is a reminder that the science project on ecosystems is due next Friday. Students should prepare both a written report and a visual display. The projects will be presented in class, and parents are welcome to attend the presentations on Friday afternoon from 1:30-3:00 PM. Please ensure your child has all necessary materials to complete their project. Contact me if you have any questions.",
            date: Date().addingTimeInterval(-36000), // 10 hours ago
            author: "Ms. Jennifer Wilson, 5th Grade Teacher",
            category: .classroom,
            imageUrl: nil,
            isPinned: false,
            classroomId: "5A",
            classroomName: "5th Grade - Ms. Wilson"
        ),
        NewsItem(
            title: "3rd Grade Field Trip Permission Forms",
            content: "Our field trip to the Natural History Museum is scheduled for October 12th. Please complete and return the permission forms by October 5th. We'll need 4-5 parent volunteers to help chaperone the trip. If you're interested in volunteering, please indicate this on the permission form. The bus will leave at 9:00 AM and return by 2:30 PM. Students should bring a packed lunch and wear their school t-shirts.",
            date: Date().addingTimeInterval(-50400), // 14 hours ago
            author: "Ms. Maria Rodriguez, 3rd Grade Teacher",
            category: .classroom,
            imageUrl: nil,
            isPinned: false,
            classroomId: "3B",
            classroomName: "3rd Grade - Ms. Rodriguez"
        ),
        
        // Parent representative posts
        NewsItem(
            title: "5th Grade Parents: Volunteers Needed for Science Fair",
            content: "Hello 5th grade parents! We need volunteers to help set up for the upcoming science fair on October 20th. We'll need help arranging tables, setting up displays, and organizing refreshments. If you can spare 2-3 hours either before school (7:30-9:00 AM) or after school (3:30-5:00 PM) on that day, please reach out to me at jane.doe@email.com. Thank you for your support!",
            date: Date().addingTimeInterval(-7200), // 2 hours ago
            author: "Jane Doe, 5th Grade Parent Representative",
            category: .classroom,
            imageUrl: nil,
            isPinned: false,
            classroomId: "5A",
            classroomName: "5th Grade - Ms. Wilson"
        ),
        NewsItem(
            title: "3rd Grade Halloween Party Planning",
            content: "Dear 3rd grade parents, we're starting to plan the Halloween class party for October 31st. We need volunteers to bring snacks, drinks, crafts, and games. Please sign up through the link that will be sent to your email. Also, remember that all treats must be nut-free due to allergies in our class. Let's make this a fun and memorable celebration for our kids!",
            date: Date().addingTimeInterval(-10800), // 3 hours ago
            author: "Michael Smith, 3rd Grade Parent Representative",
            category: .classroom,
            imageUrl: nil,
            isPinned: false,
            classroomId: "3B",
            classroomName: "3rd Grade - Ms. Rodriguez"
        )
    ]
    
    private init() {
        // Sort news items by date (newest first) and then by pinned status
        sortNews()
    }
    
    func sortNews() {
        newsItems.sort { (item1, item2) -> Bool in
            if item1.isPinned && !item2.isPinned {
                return true
            } else if !item1.isPinned && item2.isPinned {
                return false
            } else {
                return item1.date > item2.date
            }
        }
    }
    
    func getNewsByCategory(_ category: NewsCategory?) -> [NewsItem] {
        guard let category = category else {
            return newsItems
        }
        
        return newsItems.filter { $0.category == category }
    }
    
    // New method to get news for a specific user based on their classroom subscriptions
    func getNewsForUser(_ user: User?) -> [NewsItem] {
        // If user is nil (guest), return only school-wide news
        guard let user = user else {
            return newsItems.filter { $0.classroomId == nil }
        }
        
        // For non-approved users, only show school-wide news regardless of subscriptions
        if !user.isApproved {
            return newsItems.filter { $0.classroomId == nil }
        }
        
        // If user is approved but has no classroom subscriptions, return only school-wide news
        if user.classroomSubscriptions.isEmpty {
            return newsItems.filter { $0.classroomId == nil }
        }
        
        // For approved users with subscriptions, return school-wide news plus
        // news from their subscribed classrooms
        return newsItems.filter { newsItem in
            // Include all school-wide news
            if newsItem.classroomId == nil {
                return true
            }
            
            // Include news from subscribed classrooms
            if let classroomId = newsItem.classroomId,
               user.classroomSubscriptions.contains(classroomId) {
                
                // For parent users who aren't parent reps, only show official classroom posts
                if user.role == .parent && newsItem.sourceType == .parentRep {
                    return false
                }
                
                return true
            }
            
            return false
        }
    }
    
    // Filter news items by classroom
    func getNewsByClassroom(_ classroomId: String) -> [NewsItem] {
        return newsItems.filter { $0.classroomId == classroomId }
    }
    
    // Add a news item
    func addNewsItem(_ item: NewsItem) {
        // In a real app, you would persist this to the database
        // For this demo, we'll just add it to our in-memory array
        newsItems.append(item)
        
        // Re-sort the news items
        sortNews()
    }
}