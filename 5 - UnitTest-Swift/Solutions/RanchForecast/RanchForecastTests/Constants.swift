//
//  Constants.swift
//  RanchForecast
//
//  Created by Michael Ward on 9/16/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import Foundation

struct Constants {
    static let urlString = "https://training.bignerdranch.com/classes/test-course"
    static let url = URL(string: urlString)!
    static let title = "Test Course"

    static let dateString = "2014-06-02"
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    static let date = dateFormatter.date(from: dateString)!
    
    static let validCourseDict: [String:Any]
        = [ "title" : title,
            "url" : urlString,
            "upcoming" : [["start_date" : dateString]] ]
    
    static let coursesDictionary = ["courses" : [validCourseDict]]

    static let okResponse = HTTPURLResponse(url: url,
                                            statusCode: 200,
                                            httpVersion: nil,
                                            headerFields: nil)!

    static let jsonData = try! JSONSerialization.data(withJSONObject: coursesDictionary,
                                                      options: [])
    
    static let session: URLSession = {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [FakeScheduleURLProtocol.self]
        return URLSession(configuration: config)
    }()
}
