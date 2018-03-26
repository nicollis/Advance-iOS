//
//  PhotosViewController.swift
//  Photodex
//
//  Created by Michael Ward on 8/25/15.
//  Copyright © 2015 Big Nerd Ranch. All rights reserved.
//

import UIKit

let PhotoCellIdentifier = "PhotoCell"

class PhotosViewController: UICollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pinchGR = UIPinchGestureRecognizer(target: self, action: #selector(PhotosViewController.pinched(_:)))
        collectionView?.addGestureRecognizer(pinchGR)
        
        collectionView?.reloadData()
    }
    
    // MARK: - Handling Pinches
    
    private var initialScale: CGFloat = 1.0
    private var isTransitioning: Bool = false
    private var transitionLayout: UICollectionViewTransitionLayout?
    
    @objc private func pinched(_ gr: UIPinchGestureRecognizer) {
        switch gr.state {
        case .began:
            print("gesture began with scale \(gr.scale) velocity \(gr.velocity)")
            let currentLayout = collectionView!.collectionViewLayout
            let nextLayout = (currentLayout is FlipLayout) ? SpaceFillingFlowLayout() : FlipLayout()
            transitionLayout = collectionView!.startInteractiveTransition(to: nextLayout) {
             (animationCompleted, transitionCompleted) -> Void in
                print("interactive transition completion executing")
            }
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
        return 10
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCellIdentifier, for: indexPath)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView,
        transitionLayoutForOldLayout fromLayout: UICollectionViewLayout,
        newLayout toLayout: UICollectionViewLayout) -> UICollectionViewTransitionLayout {
            
            return UICollectionViewTransitionLayout(currentLayout: fromLayout, nextLayout: toLayout)
            
    }
    
}
