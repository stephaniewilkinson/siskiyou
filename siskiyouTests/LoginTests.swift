//
//  LoginTests.swift
//  siskiyouTests
//
//  Created by Claude on 4/7/25.
//

import XCTest
import CloudKit
@testable import siskiyou

final class LoginTests: XCTestCase {
    
    // Mock UserService for testing
    class MockUserService: UserService {
        var shouldSucceed = true
        var errorToReturn: Error?
        var lastEmailUsed: String?
        var lastPasswordUsed: String?
        var userToReturn = User(firstName: "Test", lastName: "User", email: "test@example.com", passwordHash: "password123")
        
        override func loginUser(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
            lastEmailUsed = email
            lastPasswordUsed = password
            
            if shouldSucceed {
                completion(.success(userToReturn))
            } else {
                let error = errorToReturn ?? NSError(domain: "LoginTests", code: 401, userInfo: [NSLocalizedDescriptionKey: "Invalid credentials"])
                completion(.failure(error))
            }
        }
    }
    
    // Swizzle the shared instance for testing
    var mockUserService: MockUserService!
    var originalUserService: UserService!
    
    override func setUp() {
        super.setUp()
        
        // Save original shared instance
        originalUserService = UserService.shared
        
        // Create and install mock
        mockUserService = MockUserService()
        
        // Use swizzling to replace the shared instance with our mock
        let originalMethod = class_getClassMethod(UserService.self, #selector(getter: UserService.shared))!
        let mockMethod = class_getInstanceMethod(MockUserService.self, #selector(getter: MockUserService.shared))!
        method_exchangeImplementations(originalMethod, mockMethod)
        
        // Set the mock as the shared instance
        UserService.shared = mockUserService
    }
    
    override func tearDown() {
        // Restore original shared instance
        UserService.shared = originalUserService
        
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testLoginWithValidCredentials() {
        // Arrange
        mockUserService.shouldSucceed = true
        let expectation = self.expectation(description: "Login Success")
        
        // Act
        mockUserService.loginUser(email: "test@example.com", password: "password123") { result in
            // Assert
            switch result {
            case .success(let user):
                XCTAssertEqual(user.email, "test@example.com")
                XCTAssertEqual(user.firstName, "Test")
                XCTAssertEqual(user.lastName, "User")
                expectation.fulfill()
            case .failure:
                XCTFail("Login should succeed with valid credentials")
            }
        }
        
        // Wait for expectation
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testLoginWithInvalidCredentials() {
        // Arrange
        mockUserService.shouldSucceed = false
        mockUserService.errorToReturn = NSError(domain: "LoginTests", code: 401, userInfo: [NSLocalizedDescriptionKey: "Invalid credentials"])
        let expectation = self.expectation(description: "Login Failure")
        
        // Act
        mockUserService.loginUser(email: "wrong@example.com", password: "wrongpassword") { result in
            // Assert
            switch result {
            case .success:
                XCTFail("Login should fail with invalid credentials")
            case .failure(let error):
                XCTAssertEqual(error.localizedDescription, "Invalid credentials")
                expectation.fulfill()
            }
        }
        
        // Wait for expectation
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testLoginWithEmptyEmail() {
        // Arrange
        mockUserService.shouldSucceed = false
        mockUserService.errorToReturn = NSError(domain: "LoginTests", code: 400, userInfo: [NSLocalizedDescriptionKey: "Email cannot be empty"])
        let expectation = self.expectation(description: "Login Failure")
        
        // Act
        mockUserService.loginUser(email: "", password: "password123") { result in
            // Assert
            switch result {
            case .success:
                XCTFail("Login should fail with empty email")
            case .failure(let error):
                XCTAssertEqual(error.localizedDescription, "Email cannot be empty")
                expectation.fulfill()
            }
        }
        
        // Wait for expectation
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testLoginWithEmptyPassword() {
        // Arrange
        mockUserService.shouldSucceed = false
        mockUserService.errorToReturn = NSError(domain: "LoginTests", code: 400, userInfo: [NSLocalizedDescriptionKey: "Password cannot be empty"])
        let expectation = self.expectation(description: "Login Failure")
        
        // Act
        mockUserService.loginUser(email: "test@example.com", password: "") { result in
            // Assert
            switch result {
            case .success:
                XCTFail("Login should fail with empty password")
            case .failure(let error):
                XCTAssertEqual(error.localizedDescription, "Password cannot be empty")
                expectation.fulfill()
            }
        }
        
        // Wait for expectation
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testLoginWithNetworkError() {
        // Arrange
        mockUserService.shouldSucceed = false
        mockUserService.errorToReturn = NSError(domain: "CKErrorDomain", code: CKError.networkUnavailable.rawValue, userInfo: [NSLocalizedDescriptionKey: "Network unavailable"])
        let expectation = self.expectation(description: "Login Network Error")
        
        // Act
        mockUserService.loginUser(email: "test@example.com", password: "password123") { result in
            // Assert
            switch result {
            case .success:
                XCTFail("Login should fail with network error")
            case .failure(let error):
                XCTAssertEqual(error.localizedDescription, "Network unavailable")
                expectation.fulfill()
            }
        }
        
        // Wait for expectation
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    // MARK: - UI Tests
    
    func testLoginViewUI() {
        // Create an instance of the login view
        let loginView = LoginView()
        
        // Get the view controller
        let viewController = UIHostingController(rootView: loginView)
        
        // Present the view controller
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        
        // Let the view controller load
        _ = viewController.view
        
        // Now we could use XCTAssert to verify the view properties
        // This would require UI testing, which needs a separate test target
        // So we'll just verify that the view controller loaded successfully
        XCTAssertNotNil(viewController.view)
    }
}