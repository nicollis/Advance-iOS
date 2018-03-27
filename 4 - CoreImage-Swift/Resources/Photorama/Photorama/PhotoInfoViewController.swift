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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        store.fetchImage(for: photo, completion: { (result) -> Void in
            switch result {
            case let .success(image):
                
                let fuzzAction = ImageProcessor.Action.pixellateFaces
                let filterAction = ImageProcessor.Action.filter(self.activeFilter)
                let actions = [fuzzAction, filterAction]
                
                var filteredImage: UIImage
                do {
                    filteredImage = try self.imageProcessor.preform(actions, on: image)
                } catch {
                    print("Error: unable to filter image for \(self.photo): \(error)")
                    filteredImage = image
                }
                OperationQueue.main.addOperation {
                    self.imageView.image = filteredImage
                }
            case let .failure(error):
                print("Error fetching image for photo: \(error)")
            }
        })
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
