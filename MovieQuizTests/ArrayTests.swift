//
//  ArrayTests.swift
//  MovieQuizTests
//

import XCTest
@testable import MovieQuiz

final class ArrayTests: XCTestCase {
    /// тест на успешное взятие элемента по индексу
    func testGetValueInRange() throws {
        // Given
        let array = [1, 1, 2, 4, 5]
        let index = 2

        // When
        let result = array[safe: index]

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result, 2)
    }
    
    /// тест на взятие элемента по неправильному индексу
    func testGetValueOutOfRange() throws {
        // Given
        let array = [1, 1, 2, 4, 5]
        let index = 20

        // When
        let result = array[safe: index]

        // Then
        XCTAssertNil(result)
    }
}

