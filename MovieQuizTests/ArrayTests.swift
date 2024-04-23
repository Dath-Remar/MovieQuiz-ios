import Foundation
import XCTest
@testable import MovieQuiz

// MARK: - Array Tests

class ArrayTests: XCTestCase {
    
    // MARK: - Tests for Array Extension
    
    func testGetValueInRange() throws {
        
        // Given
        let array = [1, 1, 2, 3, 5]
        
        // When
        let value = array[safe: 2]
        
        // Then
        XCTAssertNotNil(value, "Value should not be nil")
        XCTAssertEqual(value, 2, "Value should be equal to 2")
        
    }
    
    func testGetValueOutRange() throws {
        
        // Given
        let array = [1, 1, 2, 3, 5]
        
        // When
        let value = array[safe: 20]
        
        // Then
        XCTAssertNil(value, "Value should be nil")
    }
}
