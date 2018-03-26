import UIKit

class QuizEndViewController: UIViewController {
    var quizSet: QuizSet!
    var score: Int = 0
    var oldHighScore: Int = 0
    
    @IBOutlet var finalScoreLabel: UILabel!
    @IBOutlet var highScoreLabel: UILabel!
    
    
    override func viewDidLoad() {
        if score == quizSet.items.count {
            finalScoreLabel.text = "Perfect Score!"
        } else {
            let outOf = "Final Score \(score) out of \(quizSet.items.count)"
            finalScoreLabel.text = outOf
        }
        
        if score > oldHighScore {
            highScoreLabel.text = "New High Score!"
        } else {
            let currentScore = "High Score: \(oldHighScore)"
            highScoreLabel.text = currentScore
        }
    }

    @IBAction func dismiss() {
        _ = navigationController?.popToRootViewController(animated: true)
    }
    
}

