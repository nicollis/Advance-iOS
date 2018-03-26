
import Foundation

class Course: NSObject {
    let title: String
    let url: URL
    let nextStartDate: Date
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()
    var nextStartDateString: String {
        return dateFormatter.string(from: nextStartDate)
    }
    
    init(title: String, url: URL, nextStartDate: Date) {
        self.title = title
        self.url = url
        self.nextStartDate = nextStartDate
        super.init()
    }
}

extension Course {
    override var description: String {
        return "<Course: \"\(title)\" on \(nextStartDateString) via \(url.lastPathComponent)>"
    }
}
