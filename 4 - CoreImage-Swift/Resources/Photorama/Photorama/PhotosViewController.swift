//
//  Copyright © 2015 Big Nerd Ranch
//

import UIKit

class PhotosViewController: UIViewController, UICollectionViewDelegate {
    
    @IBOutlet var collectionView: UICollectionView!
    
    @IBAction func filterChoiceChanged(_ sender: UISegmentedControl) {
        enum FilterChoice: Int {
            case none = 0, gloom, sepia, blur
        }
        
        guard let choice = FilterChoice(rawValue: sender.selectedSegmentIndex) else {
            fatalError("Impossible segment selected: \(sender.selectedSegmentIndex)")
        }
        
        switch choice {
        case .none:
            selectedFilter = ImageProcessor.Filter.none
        case .gloom:
            selectedFilter = ImageProcessor.Filter.gloom(intensity: 3.0, radius: 30.0)
        case .sepia:
            selectedFilter = ImageProcessor.Filter.sepia(intensity: 3.0)
        case .blur:
            selectedFilter = ImageProcessor.Filter.blur(intensity: 10.0)
        }
        
        for request in request.values {
            request.cancel()
        }
        request.removeAll()
        thumbnailStore.clearThumbnails()
        collectionView.reloadData()
    }
    
    var store: PhotoStore!
    let photoDataSource = PhotoDataSource()
    let imageProcessor = ImageProcessor()
    let thumbnailStore = ThumbnailStore()
    var selectedFilter = ImageProcessor.Filter.none
    var request: [IndexPath:ImageProcessingRequest] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = photoDataSource
        collectionView.delegate = self
        
        updateDataSource()
        
        store.fetchInterestingPhotos {
            (photosResult) in
            
            self.updateDataSource()
        }
    }
    
    private func updateDataSource() {
        self.store.fetchAllPhotos {
            (photosResult) in
    
            switch photosResult {
            case let .success(photos):
                self.photoDataSource.photos = photos
            case .failure(_):
                self.photoDataSource.photos.removeAll()
            }
            self.collectionView.reloadSections(IndexSet(integer: 0))
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        
        let photo = photoDataSource.photos[indexPath.row]
        
        // First, check the thumbnailStore
        if let photoID = photo.photoID as NSString?,
            let thumbnail = thumbnailStore.thumbnail(forKey: photoID),
            let cell = cell as? PhotoCollectionViewCell {
            cell.update(with: thumbnail)
            return
        }
        
        // Second, check to see if we've already requested a thumbnail for this cell
        // If so just upgrade its priority
        if let request = request[indexPath] {
            request.priority = .high
            return
        }
        
        // Download the image data, which could take some time
        store.fetchImage(for: photo, completion: { (result) -> Void in
                
            // The index path for the photo might have changed between the
            // time the request started and finished, so find the most
            // recent index path
            
            // (Note: You will have an error on the next line; you will fix it shortly)
            guard let photoIndex = self.photoDataSource.photos.index(of: photo),
                case let .success(image) = result else {
                    return
            }
            let photoIndexPath = IndexPath(item: photoIndex, section: 0)
            
            // Prepare the actions for thumbnail creation
            let maxSize = CGSize(width: 200, height: 200)
            let scaleAction = ImageProcessor.Action.scale(maxSize: maxSize)
            let faceFuzzAction = ImageProcessor.Action.pixellateFaces
            let filterAction = ImageProcessor.Action.filter(self.selectedFilter)
            let actions = [faceFuzzAction, filterAction, scaleAction]
            
            
            let request = self.imageProcessor.process(image: image, actions: actions, priority: .high, completion: { (thumbResult) in
                // Actually process the available photo into a thumbnail
                let thumbnail: UIImage
                switch thumbResult {
                case let .success(filteredImage):
                    thumbnail = filteredImage
                case let .failure(error):
                    print("Error: Failed to process photo \(photo.photoID ?? "No photo ID"): \(error)")
                    thumbnail = image
                case .cancelled:
                    thumbnail = image
                }
                
                OperationQueue.main.addOperation {
                    if let photoID = photo.photoID as NSString? {
                        self.thumbnailStore.setThumbnail(image: thumbnail, forKey: photoID)
                    }
                    // When the request finishes, only update the cell if its still visiable
                    if let cell = self.collectionView.cellForItem(at: photoIndexPath) as? PhotoCollectionViewCell {
                        cell.update(with: thumbnail)
                    }
                    
                    // Stop tracking the request
                    self.request[indexPath] = nil
                }
            })
            // Start tracking the request
            OperationQueue.main.addOperation {
                self.request[indexPath] = request
            }
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        request[indexPath]?.priority = .low
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        for request in request.values {
            request.cancel()
        }
        request.removeAll()
        switch segue.identifier {
        case "showPhoto"?:
            if let selectedIndexPath =
                collectionView.indexPathsForSelectedItems?.first {
                
                let photo = photoDataSource.photos[selectedIndexPath.row]
                
                let destinationVC =
                    segue.destination as! PhotoInfoViewController
                destinationVC.photo = photo
                destinationVC.store = store
                destinationVC.activeFilter = selectedFilter
                destinationVC.imageProcessor = imageProcessor
            }
        default:
            preconditionFailure("Unexpected segue identifier.")
        }
    }
}
