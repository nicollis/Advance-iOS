//
//  Copyright © 2015 Big Nerd Ranch
//

import UIKit

class PhotoInfoViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    
    var photo: Photo! {
        didSet {
            navigationItem.title = photo.title
        }
    }
    var store: PhotoStore!
    var imageProcessor: ImageProcessor!
    var activeFilter: ImageProcessor.Filter!
    var request: ImageProcessingRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        store.fetchImage(for: photo, completion: { (result) -> Void in
            switch result {
            case let .success(image):
                
                let fuzzAction = ImageProcessor.Action.pixellateFaces
                let filterAction = ImageProcessor.Action.filter(self.activeFilter)
                let actions = [fuzzAction, filterAction]
                
                self.request = self.imageProcessor.process(image: image, actions: actions, priority: .high, completion: { (actionResult) in
                    let bigImage: UIImage
                    switch actionResult {
                    case let .success(filteredImage):
                        bigImage = filteredImage
                    case let .failure(error):
                        print("Error: Failed to process photo \(self.photo.photoID ?? "No photo ID"): \(error)")
                        bigImage = image
                    case .cancelled:
                        bigImage = image
                    }
                    
                    OperationQueue.main.addOperation({
                        self.imageView.image = bigImage
                    })
                })
            case let .failure(error):
                print("Error fetching image for photo: \(error)")
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        request?.cancel()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showTags"?:
            let navController = segue.destination as! UINavigationController
            let tagController = navController.topViewController as! TagsViewController
            
            tagController.store = store
            tagController.photo = photo
        default:
            preconditionFailure("Unexpected segue identifier.")
        }
    }
}
