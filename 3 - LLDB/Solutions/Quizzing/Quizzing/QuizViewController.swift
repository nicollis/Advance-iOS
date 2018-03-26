import UIKit

class QuizViewController: UIViewController {
    let animationTime: TimeInterval = 0.75
    
    var quizSet: QuizSet!
    
    var currentQuestion = 0
    var currentScore = 0
    
    // these are optinal to prevent crashes. --Geo
    @IBOutlet var quizNameLabel: UILabel?
    @IBOutlet var questionLabel: UILabel?
    @IBOutlet var answerTextField: UITextField?
    @IBOutlet var imageView: UIImageView?
    @IBOutlet var questionNumberLabel: UILabel?
    @IBOutlet var scoreLabel: UILabel?
    
    var currentItem: QuizItem {
        get {
            let item = quizSet.items[currentQuestion]
            return item
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        quizNameLabel?.text = quizSet.title
        questionLabel?.text = ""
        answerTextField?.text = ""
        imageView?.image = nil
        questionNumberLabel?.text = questionNumberTextWith(currentQuestion: 0)
        scoreLabel?.text = scoreTextWith(score: 0)
    }
    
    func questionNumberTextWith(currentQuestion: Int) -> String {
        return "\(currentQuestion) / \(quizSet.items.count)"
    }
    
    func scoreTextWith(score: Int) -> String {
        return "Score: \(score)"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        moveTo(question: 0)
    }
    
    func moveTo(question: Int) {
        if question >= quizSet.items.count {
            finishedQuiz()
            return
        }
        
        currentQuestion = question
        updateUI()
    }
    
    func finishedQuiz() {
        let qevc = QuizEndViewController()
        qevc.quizSet = quizSet
        qevc.score = currentScore
        qevc.oldHighScore = quizSet.highScore
        
        navigationController?.pushViewController(qevc, animated: true)

        if self.currentScore > quizSet.highScore {
             quizSet.highScore = currentScore
        }
    }
    
    func scoreAndMoveOn() {
        let item = currentItem
        var correct = false
        let answer = answerTextField?.text
        
        if answer?.compare(item.answer, options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive]) == .orderedSame {
            correct = true
        }
        
        if correct {
            expressHappiness()
            currentScore += 1
        } else {
            expressSadness()
        }
    }
    
    func updateUI() {
        let item = currentItem
        questionLabel?.text = item.question
        answerTextField?.text = ""
        let image = UIImage(named: item.imageName ?? "")
        imageView?.image = image
        questionNumberLabel?.text = questionNumberTextWith(currentQuestion: currentQuestion + 1)
        scoreLabel?.text = scoreTextWith(score: currentScore)
    }
    
    func expressHappiness() {
        expressImage(named: "happy", label: nil)
    }
    
    func expressSadness() {
        let item = currentItem
        expressImage(named: "frowny", label: item.answer)
    }
    
    
    func expressImage(named imageName: String, label labelText: String?) {
        let image = UIImage(named: imageName)
        var frame = view.bounds
        frame = frame.insetBy(dx: frame.width * 0.25, dy: frame.width * 0.25)
        
        let imageView = UIImageView(frame: frame)
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        imageView.alpha = 0.0
        view.addSubview(imageView)
        
        var label: UILabel?
        
        if let labelText = labelText {
            label = UILabel(frame: CGRect.zero)
            label?.text = labelText
            label?.alpha = 0.0
            label?.textAlignment = .center
            label?.backgroundColor = UIColor.yellow
            let font = UIFont.boldSystemFont(ofSize: 30)
            label?.font = font
            
            label?.sizeToFit()
            
            var labelFrame = label?.frame
            labelFrame?.size.width = view.frame.width
            labelFrame?.origin.x = 0.0
            labelFrame?.origin.y = frame.maxY
            label?.frame = labelFrame!
            
            view.addSubview(label!)
        }
        
        UIView.animate(withDuration: animationTime,
                       animations: {
                        imageView.alpha = 1.0
                        label?.alpha = 1.0
        }, completion: { finished in 
            imageView.alpha = 1.0
            label?.alpha = 1.0
            
            UIView.animate(withDuration: self.animationTime,
                           animations: {
                            imageView.alpha = 0.0
                            label?.alpha = 0.0
            }, completion: { finished in
                imageView.removeFromSuperview()
                label?.removeFromSuperview()
                self.moveTo(question: self.currentQuestion + 1)
            })
        })
    }
    
    @IBAction func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension QuizViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        scoreAndMoveOn()
        return true
    }
}
