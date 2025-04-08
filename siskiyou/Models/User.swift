//
//  User.swift
//  siskiyou
//
//  Created by Claude on 4/7/25.
//

import Foundation
import SwiftData
import CloudKit

// User roles in the system
enum UserRole: String, Codable, Sendable {
    case student = "Student"
    case parent = "Parent" 
    case teacher = "Teacher"
    case admin = "Administrator"
    case parentRep = "Parent Representative"
}

// Child model for parents
struct Child: Codable, Identifiable, Hashable, Sendable {
    var id = UUID()
    var name: String
    var grade: String
    var classroomId: String
    var teacherName: String
    
    // Computed property for display
    var classDisplay: String {
        return "\(grade) - \(teacherName)"
    }
}

// Marker protocol for documentation purposes
private protocol _UnsendableButSafe {}

@Model
// Using @unchecked Sendable is a common pattern for SwiftData models
// that need to be Sendable but have mutable properties
final class User: @unchecked Sendable, _UnsendableButSafe {
    enum CodingKeys: String, CodingKey {
        case firstName, lastName, email, passwordHash
        case isActive, lastLoginDate
        case roleRawValue, classroomSubscriptions, children
        case recordID, createdAt, updatedAt
    }
    // Basic user info
    var firstName: String
    var lastName: String
    var email: String
    var passwordHash: String // In a real app, you'd use a secure hash
    
    // User status
    var isActive: Bool = true
    var isApproved: Bool = false
    var lastLoginDate: Date?
    
    // User role stored as a string for SwiftData compatibility
    private var roleRawValue: String = UserRole.parent.rawValue
    
    // Computed property to access as enum
    var role: UserRole {
        get {
            return UserRole(rawValue: roleRawValue) ?? .parent
        }
        set {
            roleRawValue = newValue.rawValue
        }
    }
    
    // Classroom associations
    var classroomSubscriptions: [String] = [] // IDs of subscribed classrooms
    var children: [Child] = [] // For parents - their children
    
    // CloudKit record info
    var recordID: String?
    var createdAt: Date
    var updatedAt: Date
    
    // Computed property for full name
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
    
    // Init
    init(firstName: String, lastName: String, email: String, passwordHash: String, role: UserRole = .parent) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.passwordHash = passwordHash
        self.roleRawValue = role.rawValue
        self.createdAt = Date()
        self.updatedAt = Date()
        
        // Auto-approve admins and teachers
        let adminEmails = [
            "what.happens@gmail.com",
            "kristin.beers@siskiyouschool.org",
            "katherine.holden@siskiyouschool.org"
        ]
        
        // Check if user is an admin
        let isAdmin = adminEmails.contains(email.lowercased())
        
        // Check if user is a teacher based on email domain
        let isTeacher = email.lowercased().hasSuffix("@siskiyouschool.org")
        
        // If email indicates teacher, set role automatically
        if isTeacher && role == .parent {
            self.roleRawValue = UserRole.teacher.rawValue
        }
        
        // Auto-approve admins and teachers
        self.isApproved = isAdmin || isTeacher
    }
    
    // Update the timestamp when modified
    func update() {
        self.updatedAt = Date()
    }
}

// User Authentication Service
final class UserService: @unchecked Sendable {
    static let shared = UserService()
    
    private let privateDB = CKContainer.default().privateCloudDatabase
    private let recordType = "User"
    
    // Admin emails list
    private let adminEmails = [
        "what.happens@gmail.com",
        "kristin.beers@siskiyouschool.org",
        "katherine.holden@siskiyouschool.org"
    ]
    
    private init() {}
    
    // Create a new user in CloudKit
    // Using nonisolated to indicate this does its own sync
    nonisolated func createUser(firstName: String, lastName: String, email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        // Check if user with this email already exists
        let emailPredicate = NSPredicate(format: "email == %@", email)
        let query = CKQuery(recordType: recordType, predicate: emailPredicate)
        
        // Use the newer fetch API instead of the deprecated perform method
        Task {
            do {
                let (results, _) = try await privateDB.records(matching: query)
                let records = results.compactMap { _, result in
                    try? result.get()
                }
                
                // Check if user already exists
                if !records.isEmpty {
                    DispatchQueue.main.async {
                        completion(.failure(NSError(domain: "UserService", code: 409, userInfo: [NSLocalizedDescriptionKey: "Email already exists"])))
                    }
                    return
                }
                
                // Create a new user record
                let record = CKRecord(recordType: self.recordType)
                record.setValue(firstName, forKey: "firstName")
                record.setValue(lastName, forKey: "lastName")
                record.setValue(email, forKey: "email")
                
                // In a real app, you would hash the password before storing
                // This is a simple demo implementation
                record.setValue(password, forKey: "passwordHash")
                record.setValue(true, forKey: "isActive")
                
                // Set role based on email domain for teachers
                let isTeacher = email.lowercased().hasSuffix("@siskiyouschool.org")
                let emailRole = isTeacher ? UserRole.teacher.rawValue : UserRole.parent.rawValue
                record.setValue(emailRole, forKey: "roleRawValue")
                
                // Everyone can sign up without approval
                // isApproved now only controls access to classroom subscriptions
                let isAdmin = adminEmails.contains(email.lowercased())
                record.setValue(isAdmin || isTeacher, forKey: "isApproved") // Auto-approve admins and teachers for classroom access
                
                record.setValue(Date(), forKey: "createdAt")
                record.setValue(Date(), forKey: "updatedAt")
                
                // Save to CloudKit using the newer API
                do {
                    let savedRecord = try await privateDB.save(record)
                    
                    // Create local user object
                    let user = User(firstName: firstName, lastName: lastName, email: email, passwordHash: password)
                    user.recordID = savedRecord.recordID.recordName
                    
                    DispatchQueue.main.async {
                        completion(.success(user))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    // Authenticate user (simplified for demo)
    // Using nonisolated to indicate this does its own sync
    nonisolated func loginUser(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        let emailPredicate = NSPredicate(format: "email == %@", email)
        let query = CKQuery(recordType: recordType, predicate: emailPredicate)
        
        Task {
            do {
                let (results, _) = try await privateDB.records(matching: query)
                let records = results.compactMap { _, result in
                    try? result.get()
                }
                
                DispatchQueue.main.async {
                    guard let userRecord = records.first else {
                        completion(.failure(NSError(domain: "UserService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Please sign up for an account"])))
                        return
                    }
                    
                    // Simple password check (in real app, would verify hash)
                    guard let storedPassword = userRecord["passwordHash"] as? String, storedPassword == password else {
                        completion(.failure(NSError(domain: "UserService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Invalid password. Please try again."])))
                        return
                    }
                    
                    // Get approval status - we'll still allow login but restrict access
                    let isAdmin = self.adminEmails.contains(email.lowercased())
                    let isApproved = userRecord["isApproved"] as? Bool ?? false
                    
                    // We no longer block login for unapproved users, 
                    // but we'll set their approval status correctly
                    
                    // Create user object from record
                    let firstName = userRecord["firstName"] as? String ?? ""
                    let lastName = userRecord["lastName"] as? String ?? ""
                    let user = User(firstName: firstName, lastName: lastName, email: email, passwordHash: password)
                    user.recordID = userRecord.recordID.recordName
                    user.isApproved = isApproved || isAdmin // Set approval status
                    
                    // Update last login date
                    Task {
                        do {
                            userRecord["lastLoginDate"] = Date()
                            _ = try await self.privateDB.save(userRecord)
                        } catch {
                            // Just log the error here rather than failing the whole login
                            print("Error updating last login date: \(error.localizedDescription)")
                        }
                    }
                    
                    completion(.success(user))
                }
                
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    // Admin function: Get pending users
    nonisolated func getPendingUsers(completion: @escaping (Result<[User], Error>) -> Void) {
        let query = CKQuery(recordType: recordType, predicate: NSPredicate(format: "isApproved == %@", NSNumber(value: false)))
        
        Task {
            do {
                let (results, _) = try await privateDB.records(matching: query)
                let records = results.compactMap { _, result in
                    try? result.get()
                }
                
                DispatchQueue.main.async {
                    let pendingUsers = records.map { record -> User in
                        let firstName = record["firstName"] as? String ?? ""
                        let lastName = record["lastName"] as? String ?? ""
                        let email = record["email"] as? String ?? ""
                        
                        let user = User(firstName: firstName, lastName: lastName, email: email, passwordHash: "")
                        user.isActive = record["isActive"] as? Bool ?? true
                        user.isApproved = false
                        user.recordID = record.recordID.recordName
                        
                        if let createdAt = record["createdAt"] as? Date {
                            user.createdAt = createdAt
                        }
                        
                        return user
                    }
                    
                    completion(.success(pendingUsers))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    // Admin function: Approve user
    nonisolated func approveUser(userId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        // Create the record ID - no need for optional check since CKRecord.ID initializer is not failable
        let recordID = CKRecord.ID(recordName: userId)
        
        Task {
            do {
                let record = try await privateDB.record(for: recordID)
                
                // Update approval status
                record["isApproved"] = true
                record["updatedAt"] = Date()
                
                // Save changes
                let _ = try await privateDB.save(record)
                
                DispatchQueue.main.async {
                    completion(.success(true))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    // Admin function: Deny/delete user
    nonisolated func denyUser(userId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        // Create the record ID - no need for optional check since CKRecord.ID initializer is not failable
        let recordID = CKRecord.ID(recordName: userId)
        
        Task {
            do {
                // Delete the user record
                try await privateDB.deleteRecord(withID: recordID)
                
                DispatchQueue.main.async {
                    completion(.success(true))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    // Check if user is admin
    nonisolated func isAdmin(email: String) -> Bool {
        return adminEmails.contains(email.lowercased())
    }
}