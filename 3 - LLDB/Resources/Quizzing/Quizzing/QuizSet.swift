import UIKit

enum QuizSetCategory: Int {
    case scienceFiction
    case music
    case mathematics
    case movies
}

struct QuizSet {
    let title: String
    let category: QuizSetCategory
    let items: [QuizItem]
    
    var highScore: Int {
        get {
            let defaults = UserDefaults.standard
            let key = "highscore - \(title)"
            let hs = defaults.integer(forKey: key)
            return hs
        }
        set {
            let defaults = UserDefaults.standard
            let key = "highscore - \(title)"
            defaults.set(newValue, forKey: key)
            
            defaults.synchronize()
        }
    }
    
    func localizedStringForCategory() -> String {
        let names = ["Science Fiction", "Music", "Mathematics", "Movies"]
        let name = names[category.rawValue]
        return name
    }
    
    static func quizSetFromPlistWith(name: String) -> QuizSet? {
        let bundle = Bundle.main
        
        let quizUrl = bundle.url(forResource: name, withExtension: "quiz")!
        
        var title: String
        var category: QuizSetCategory
        var quizItems: [QuizItem]
        
        do {
            let data = try Data.init(contentsOf: quizUrl)
            let plist = try PropertyListSerialization.propertyList(from: data,
                                                                   options: [],
                                                                   format: nil) as! [String: Any]
            title = plist["Title"] as! String
            let rawCategory = Int(plist["Category"] as! String)
            category = QuizSetCategory(rawValue: rawCategory!)!
            
            let rawItems = plist["Items"] as! [[String: String]]
            quizItems = makeQuizItems(from: rawItems)
            
        } catch {
            print("could not read/process \(quizUrl) - \(error)")
            return nil
        }
        
        return QuizSet(title: title, category: category, items: quizItems)
    }
    
    
    static func makeQuizItems(from rawItems: [[String: String]]) -> [QuizItem] {
        var quizItems = [QuizItem]()

        for rawItem in rawItems {
            let question = rawItem["Q"]!
            let answer = rawItem["A"]!
            let imageName = rawItem["I"]
            
            let item = QuizItem(question: question, answer: answer, imageName: imageName)
            quizItems.append(item)
        }

        return quizItems
    }
}

extension QuizSet: CustomStringConvertible {
    var description: String {
        return "<\(self.title) \(self.category) \(self.localizedStringForCategory()), \(self.items)>"
    }
}


