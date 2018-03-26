
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
    
    init() {
        session = URLSession.shared
    }

    func fetchCourses(completionHandler: @escaping (Result) -> (Void)) {
        let url = URL(string: "https://bookapi.bignerdranch.com/courses.json")!
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request, completionHandler: {
            (data, response, error) -> Void in
            let result: Result
            
            defer {
                OperationQueue.main.addOperation({
                    completionHandler(result)
                })
            }
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                result = .failure(Error.unexpectedResponse(response, error))
                return
            }
            
            print("Received \(data.count) bytes with status code \(httpResponse.statusCode).")
            
            if httpResponse.statusCode == 200 {
                result = self.digest(data: data)
            }
            else {
                result = .failure(Error.status(httpResponse.statusCode))
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


