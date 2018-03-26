import Foundation

struct QuizItem {
    let question: String
    let answer: String
    let imageName: String?
}


extension QuizItem: CustomStringConvertible {
    
    func truncate(string: String, toCount count: Int) -> String {
        if let endIndex = string.index(string.startIndex,
                                       offsetBy: count,
                                       limitedBy: string.endIndex) {
            let range = string.startIndex ..< endIndex
            let result = string[range]
            
            if result == string {
                return string
            } else {
                return result + "..."
            }
        }
        return string
    }
    
    var description: String {
        let q = truncate(string: question, toCount: 20)
        let a = truncate(string: answer, toCount: 10)
        let i = truncate(string: imageName ?? "", toCount: 20)
        
        let desc = "<QuizItem> \(q) - \(a) - \(i)"
        return desc
    }
    
}
