//
//  Copyright © 2015 Big Nerd Ranch
//

import UIKit

class PhotoInfoViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    var imageProcessor: ImageProcessor!
    var activeFilter: ImageProcessor.Filter!
    var request: ImageProcessingRequest?
    
    var photo: Photo! {
        didSet {
            navigationItem.title = photo.title
        }
    }
    var store: PhotoStore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        store.fetchImage(for: photo, completion: { (result) -> Void in
            switch result {
            case let .success(image):
                let fuzzAction = ImageProcessor.Action.pixellateFaces
                let filterAction = ImageProcessor.Action.filter(self.activeFilter)
                let actions = [fuzzAction, filterAction]
                
                self.request = self.imageProcessor.process(image: image, actions: actions,
                                                    priority: .high) { (actionResult) in
                    let bigImage: UIImage
                    switch result {
                    case let .success(filteredImage):
                        bigImage = filteredImage
                    case let .failure(error):
                        print("Error: failed to process photo \(String(describing: self.photo.photoID)): \(error)")
                        bigImage = image
                        // TODO: Present an alert to the user, maybe?
                    }
                    
                    OperationQueue.main.addOperation {
                        self.imageView.image = bigImage
                    }
                }
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
