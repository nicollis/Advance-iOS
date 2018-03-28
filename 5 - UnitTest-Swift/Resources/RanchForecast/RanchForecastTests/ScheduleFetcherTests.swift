//
//  ScheduleFetcherTests.swift
//  RanchForecastTests
//
//  Created by Nicholas Ollis on 3/27/18.
//  Copyright © 2018 Big Nerd Ranch. All rights reserved.
//

import XCTest

@testable import RanchForecast

class ScheduleFetcherTests: XCTestCase {
    
    var fetcher: ScheduleFetcher!
    
    override func setUp() {
        super.setUp()
        fetcher = ScheduleFetcher(urlSession: Constants.session)
    }
    
    override func tearDown() {
        fetcher = nil
        super.tearDown()
    }
    
    func testCreateCourseFromValidDictionary() {
        let course: Course! = fetcher.parse(courseDictionary: Constants.validCourseDict)
        
        XCTAssertNotNil(course)
        XCTAssertEqual(course.title, Constants.title)
        XCTAssertEqual(course.url, Constants.url)
        XCTAssertEqual(course.nextStartDate, Constants.date)
    }
    
    func testResultFromValidHttpResponseAndValidData() {
        let result = fetcher.digest(data: Constants.jsonData, response: Constants.okResponse, error: nil)
        
        switch result {
        case .success(let courses):
            XCTAssert(courses.count == 1)
            let theCourse = courses[0]
            XCTAssertEqual(theCourse.title, Constants.title)
            XCTAssertEqual(theCourse.url, Constants.url)
            XCTAssertEqual(theCourse.nextStartDate, Constants.date)
        default:
            XCTFail("Result contains Failure, but Success was expected.")
        }
    }
    
    func testFetchCoursesCompletionQueue() {
        let completionExpectation = expectation(description: "Execute completion closure")
        fetcher.fetchCourses { (result) -> (Void) in
            XCTAssertEqual(OperationQueue.current, OperationQueue.main, "Completion handler should run on the main thread; it did not")
            completionExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
}
