//
//  CourseTests.swift
//  RanchForecast
//
//  Created by Michael Ward on 9/16/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import XCTest
@testable import RanchForecast

class CourseTests: XCTestCase {
    
    func testCourseInitialization() {
        let course = Course(title: Constants.title,
                            url: Constants.url,
                            nextStartDate: Constants.date)
        
        XCTAssertEqual(course.title, Constants.title)
        XCTAssertEqual(course.url, Constants.url)
        XCTAssertEqual(course.nextStartDate, Constants.date)
    }
    
}
