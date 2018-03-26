//
//  PhotosViewController.swift
//  Photodex
//
//  Created by Michael Ward on 8/25/15.
//  Copyright © 2015 Big Nerd Ranch. All rights reserved.
//

import Foundation
import UIKit
import Photos

let PhotoCellIdentifier = "PhotoCell"

protocol PhotoLayoutType {
    var currentIndex: Int { get }
    var imageSize: CGSize { get }
}

class PhotosViewController: UICollectionViewController {
    
    var photoLayout: PhotoLayoutType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let photoLayout = collectionViewLayout as? PhotoLayoutType else {
            fatalError("PhotosViewController requires a Layout which conforms to PhotoLayoutType")
        }
        
        self.photoLayout = photoLayout
        
        let pinchGR = UIPinchGestureRecognizer(target: self, action: #selector(PhotosViewController.pinched(_:)))
        collectionView!.addGestureRecognizer(pinchGR)
        
        PHPhotoLibrary.requestAuthorization {
            (status) -> Void in
            switch status {
            case .authorized:
                OperationQueue.main.addOperation({ () -> Void in

                    self.cameraAssetsResult = self.fetchCameraAssets()
                    self.updateCachedAssets()
                    
                    self.collectionView!.reloadData()
                })
            default:
                break
            }
        }
    }
    
    // MARK: - Photos
    
    fileprivate var cameraAssetsResult: PHFetchResult<AnyObject>!
    fileprivate var imageRequestIDs: [IndexPath:PHImageRequestID] = [:]
    fileprivate let imageManager = PHCachingImageManager()
    fileprivate var cachedAssets: Set<PHAsset> = []
    
    fileprivate let imageFetchingOptions: PHImageRequestOptions = {
        let fetchOptions = PHImageRequestOptions()
        fetchOptions.isNetworkAccessAllowed = false
        return fetchOptions
    }()

    fileprivate let networkImageFetchingOptions: PHImageRequestOptions = {
        let fetchOptions = PHImageRequestOptions()
        fetchOptions.isNetworkAccessAllowed = true
        return fetchOptions
    }()
    
    fileprivate let placeholderImage: UIImage = {
        let rect = CGRect(x: 0, y: 0, width: 300, height: 300)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        UIColor.red.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return image
    }()
    
    fileprivate func fetchCameraAssets() -> PHFetchResult<AnyObject>? {
        
        guard PHPhotoLibrary.authorizationStatus() == .authorized else {
            return nil
        }

        let result = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
        
        let cameraCollection = result.firstObject! 
        let fetchPredicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = fetchPredicate
        let assetsResult = PHAsset.fetchAssets(in: cameraCollection, options: fetchOptions)
        
        print("found assets: \(assetsResult)")
        
        return assetsResult as? PHFetchResult<AnyObject>
    }
    
    fileprivate func updateCachedAssets() {
        
        let distance = 25
        
        let currentIndex = photoLayout.currentIndex
        
        let totalItemCount = collectionView!.numberOfItems(inSection: 0)
        guard totalItemCount > 0 else { return }
        
        let rangeStart = max(currentIndex - distance, 0)
        let rangeEnd = min(currentIndex + distance, totalItemCount)
        let range = rangeStart ..< rangeEnd

        print("ideal asset range: \(range)")
        
        let idealAssets: [PHAsset] = range.map { index -> PHAsset in
            return cameraAssetsResult.object(at: index) as! PHAsset
        }
        let idealAssetSet = Set(idealAssets)
        
        let assetsToCache: Set<PHAsset> = idealAssetSet.subtracting(cachedAssets)
        imageManager.startCachingImages(for: Array(assetsToCache), targetSize: photoLayout.imageSize, contentMode: .aspectFill, options: imageFetchingOptions)
        
        let assetsToUnCache: Set<PHAsset> = cachedAssets.subtracting(idealAssetSet)
        imageManager.stopCachingImages(for: Array(assetsToUnCache), targetSize: photoLayout.imageSize, contentMode: .aspectFill, options: imageFetchingOptions)
        
        cachedAssets = idealAssetSet
        print("Adding \(assetsToCache.count) assets and removing \(assetsToUnCache.count) in cache")
    }
    
    
    // MARK: - Handling Pinches
    
    fileprivate var initialScale: CGFloat = 1.0
    fileprivate var isTransitioning: Bool = false
    fileprivate var transitionLayout: UICollectionViewTransitionLayout?
    
    @objc fileprivate func pinched(_ gr: UIPinchGestureRecognizer) {
        switch gr.state {
        case .began:
            print("gesture began with scale \(gr.scale) velocity \(gr.velocity)")
            let currentLayout = collectionView!.collectionViewLayout
            let nextLayout = (currentLayout is FlipLayout) ? SpaceFillingFlowLayout() : FlipLayout()
            transitionLayout = collectionView!.startInteractiveTransition(to: nextLayout, completion: { (animationCompleted, transitionCompleted) -> Void in
                print("interactive transition completion executing")
            })
        case .changed:
            print("gesture changed to \(gr.scale) at \(gr.velocity))")
            let progress: CGFloat
            let startingScale: CGFloat = 1.0
            let currentScale = gr.scale
            let targetScale: CGFloat
            if transitionLayout?.nextLayout is FlipLayout {
                targetScale = 0.25
                progress = (startingScale - currentScale) / (startingScale - targetScale)
            } else {
                targetScale = 4.0
                progress = (currentScale - startingScale) / (targetScale - startingScale)
            }
            transitionLayout!.transitionProgress = progress
        case .ended:
            print("gesture ended")
            if transitionLayout!.transitionProgress > 0.7 {
                collectionView!.finishInteractiveTransition()
            } else {
                collectionView!.cancelInteractiveTransition()
            }
        default:
            print("gesture state \(gr.state)")
        }
    }
}

// MARK: - Collection View Data Source
extension PhotosViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let cameraAssetsResult = cameraAssetsResult,
            PHPhotoLibrary.authorizationStatus() == .authorized else {
                return 0
        }
        return cameraAssetsResult.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCellIdentifier, for: indexPath) as! PhotoCell
        cell.imageView.image = UIImage(named: "bnr_hat")
        return cell
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    
        guard let currentCell = cell as? PhotoCell else {
            print("unexpectedly non-PhotoCell cell")
            return
        }
        

        let imageAsset = cameraAssetsResult.object(at: (indexPath as NSIndexPath).row) as! PHAsset
        
        let beginningTimestamp = mach_absolute_time()
        let placeholder = self.placeholderImage
        
        let networkRequestHandler: (UIImage?, [AnyHashable : Any]?) -> Void = {
            [weak self] (maybeImage, maybeInfo) -> Void in
            guard let image = maybeImage
                else {
                    print("Bailing on image fill second time: \(String(describing: maybeImage)), \(String(describing: maybeInfo))")
                      return
            }
            
            
            func fill() {
                currentCell.imageView.image = image
                print("Filling cell \((indexPath as NSIndexPath).row): \(String(describing: maybeInfo))")
            }
            
            if self?.imageRequestIDs[indexPath] != nil {
                OperationQueue.main.addOperation(fill)
            } else {
                fill()
            }
        }
        
        let imageRequestHandler: (UIImage?, [AnyHashable : Any]?) -> Void = {
            [weak self] (maybeImage, maybeInfo) -> Void in
            
            let endingTimestamp = mach_absolute_time()
            
            var timebase : mach_timebase_info = mach_timebase_info(numer: 0, denom: 0)
            mach_timebase_info(&timebase)
            let scale = CGFloat(timebase.numer) / CGFloat(timebase.denom)
            let elapsedTimeNanos = CGFloat(endingTimestamp - beginningTimestamp) * scale
            let elapsedTime = elapsedTimeNanos / CGFloat(NSEC_PER_SEC)
            
            print("ELAPSED TIME \(elapsedTime)")
            
            let isIcloud = (maybeInfo?[PHImageResultIsInCloudKey] as? NSNumber)?.boolValue ?? false
            
            guard let image = maybeImage
                else {
                    print("Bailing on image fill: \(String(describing: maybeImage)), \(String(describing: maybeInfo)), trying network styles: \(isIcloud)")
                    
                    if isIcloud {
                        
                        self?.imageRequestIDs[indexPath] = self?.imageManager.requestImage( for: imageAsset,
                            targetSize: self!.photoLayout.imageSize,
                            contentMode: .aspectFill,
                            options: self?.networkImageFetchingOptions,
                            resultHandler: networkRequestHandler)
                        print("kicking orff request \(String(describing: self?.imageRequestIDs[indexPath]))")
                    }
                    
                    return
            }
            
            func fill() {
                currentCell.imageView.image = image
                // print("Filling cell \(indexPath.row): \(maybeInfo)")
            }
            
            if self?.imageRequestIDs[indexPath] != nil {
                OperationQueue.main.addOperation(fill)
            } else {
                fill()
            }

        }

        imageRequestIDs[indexPath] = imageManager.requestImage( for: imageAsset,
                                                                    targetSize: photoLayout.imageSize,
                                                                    contentMode: .aspectFill,
                                                                    options: imageFetchingOptions,
                                                                    resultHandler: imageRequestHandler)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let oldRequestID = imageRequestIDs.removeValue(forKey: indexPath) else { return }
        PHImageManager.default().cancelImageRequest(oldRequestID)
    }
    
    override func collectionView(_ collectionView: UICollectionView,
        transitionLayoutForOldLayout fromLayout: UICollectionViewLayout,
        newLayout toLayout: UICollectionViewLayout) -> UICollectionViewTransitionLayout {
            
            return UICollectionViewTransitionLayout(currentLayout: fromLayout, nextLayout: toLayout)
            
    }
    
}

// MARK: - Scroll View Delegate
extension PhotosViewController {
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        updateCachedAssets()
    }
    
}
