import UIKit

class InfographicViewController: UIViewController {
    @IBOutlet var infographicView: InfographicView!
    
    var wordCounter: WordCounter!

    override func viewDidLoad() {
        self.title = wordCounter.currentTextStats.title
        infographicView.wordCounter = wordCounter
        
        let recountButton = UIBarButtonItem(title: "Recount", 
                                            style: .plain,
                                            target: self,
                                            action: #selector(recount))
        navigationItem.rightBarButtonItem = recountButton
    }
    
    @objc func recount() {
        wordCounter.reset()
        wordCounter.start {
            print("recounted")
        }
        infographicView.wordCounter = wordCounter // force it to pay attention.
    }
}

