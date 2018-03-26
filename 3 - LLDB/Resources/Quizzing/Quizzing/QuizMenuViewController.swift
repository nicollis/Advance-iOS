import UIKit

class QuizMenuViewController: UIViewController {
    
    var quizzes: [QuizSet]!
    @IBOutlet var menuTableView: UITableView!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        title = "Quizzing"
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "QuizMenuTableViewCell", bundle: nil)
        menuTableView.register(nib, forCellReuseIdentifier: "MenuTableViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        menuTableView.reloadData()
    }
    
    func pushQuiz(atIndex index: Int) {
        let qvc = QuizViewController()
        let quizSet = quizzes[index]
        qvc.quizSet = quizSet
        navigationController?.pushViewController(qvc, animated: true)
    }
}


extension QuizMenuViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quizzes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableViewCell", for: indexPath) as! QuizMenuTableViewCell
        
        let quizSet = quizzes[indexPath.row]
        
        let title = quizSet.title
        let category = quizSet.localizedStringForCategory()
        let count = quizSet.items.count
        let questionCount = "\(count) question\(count == 1 ? "" : "s")"
        let highScore = "High Score: \(quizSet.highScore)"
        
        cell.titleLabel.text = title
        cell.categoryLabel.text = category
        cell.questionCountLabel.text = questionCount
        cell.highScoreLabel.text = highScore
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        pushQuiz(atIndex: indexPath.row)
    }
}

