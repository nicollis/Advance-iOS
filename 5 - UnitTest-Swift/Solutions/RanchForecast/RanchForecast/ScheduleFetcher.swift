
import Foundation

class ScheduleFetcher {
    
    enum Result {
        case success([Course])
        case failure(Error)
    }
    
    enum Error: Swift.Error {
        case unexpectedResponse(URLResponse?, Swift.Error?)
        case invalidJSON(Data)
        case status(Int)
    }
    
    let session: URLSession
    
    init(urlSession: URLSession = URLSession.shared) {
        session = urlSession
    }

    func fetchCourses(completionHandler: @escaping (Result) -> (Void)) {
        let url = URL(string: "https://bookapi.bignerdranch.com/courses.json")!
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request, completionHandler: {
            (data, response, error) -> Void in
            let result: Result = self.digest(data: data, response: response, error: error)
            
            defer {
                OperationQueue.main.addOperation({
                    completionHandler(result)
                })
            }

        })
        task.resume()
    }
    
    func digest(data: Data) -> Result {
        do {
            guard let topLevelDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]
            else {
                return .failure(Error.invalidJSON(data))
            }
            
            let courseDicts = topLevelDict["courses"] as! [[String:Any]]
            var courses:[Course] = []
            for courseDict in courseDicts {
                if let course = parse(courseDictionary: courseDict) {
                    courses.append(course)
                }
            }
            return .success(courses)
            
        } catch {
            print("Unable to deserialize JSON: \(error)")
            return .failure(error as! ScheduleFetcher.Error)
        }
    }
    
    func digest(data: Data?, response: URLResponse?, error: Swift.Error?) -> Result {
        var result: Result
        
        guard let data = data, let httpResponse = response as? HTTPURLResponse else {
            result = .failure(Error.unexpectedResponse(response, error))
            return result
        }
        
        print("Received \(data.count) bytes with status code \(httpResponse.statusCode).")
        
        if httpResponse.statusCode == 200 {
            result = self.digest(data: data)
        }
        else {
            result = .failure(Error.status(httpResponse.statusCode))
        }
        
        return result
    }
    
    func parse(courseDictionary courseDict: [String:Any]) -> Course? {
        let title = courseDict["title"] as! String
        let urlString = courseDict["url"] as! String
        let upcomingArray = courseDict["upcoming"] as! [[String:Any]]
        let nextUpcomingDict = upcomingArray.first!
        let nextStartDateString = nextUpcomingDict["start_date"] as! String
        
        let url = URL(string: urlString)!
        
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let nextStartDate = df.date(from: nextStartDateString)!
        
        return Course(title: title, url: url, nextStartDate: nextStartDate)
    }
    
}


