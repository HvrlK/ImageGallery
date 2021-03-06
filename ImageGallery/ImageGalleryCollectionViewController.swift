//
//  ImageGalleryCollectionViewController.swift
//  ImageGallery
//
//  Created by Vitalii Havryliuk on 4/3/18.
//  Copyright © 2018 Vitalii Havryliuk. All rights reserved.
//

import UIKit

class ImageGalleryCollectionViewController: UICollectionViewController, UICollectionViewDragDelegate, UICollectionViewDropDelegate, UIDropInteractionDelegate {
    
    var imageGalleryTVC: ImageGalleryTableViewController!
    var indexPathOfAlbum: IndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(scaleCell(_:)))
        self.collectionView?.addGestureRecognizer(pinchRecognizer)
        self.collectionView?.dataSource = self
        self.collectionView?.delegate = self
        self.collectionView?.dragDelegate = self
        self.collectionView?.dropDelegate = self
    }
    
    var flowLayout: UICollectionViewFlowLayout? {
        return collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    private var scale: CGFloat = 1
    
    override func viewDidLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let cv = collectionView?.frame {
            flowLayout?.itemSize = CGSize(width: (cv.size.width - 20) / 3 * scale, height: (cv.size.width - 20) / 3 * scale)
            collectionView?.visibleCells.forEach {
                ($0 as? ImageGalleryCollectionViewCell)?.layoutIfNeeded()
            }
        }
    }
    
    @objc func scaleCell(_ gestureRecognizer : UIPinchGestureRecognizer) {
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            flowLayout?.itemSize = CGSize(width: (flowLayout?.itemSize.width)! * gestureRecognizer.scale, height: (flowLayout?.itemSize.height)! * gestureRecognizer.scale)
            scale *= gestureRecognizer.scale
            gestureRecognizer.scale = 1.0
        }
    }

    var imageURLs: [URL?] = []
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let detailVC = segue.destination.contents as? DetailViewController else {return}
        if let cell = sender as? UICollectionViewCell, let indexPath = collectionView?.indexPath(for: cell) {
            detailVC.imageURL = imageURLs[indexPath.row]
        }
    }
    

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageURLs.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath)
        if let imageCell = cell as? ImageGalleryCollectionViewCell {
            if let url = imageURLs[indexPath.item]?.imageURL {
                imageCell.spinner.startAnimating()
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    let urlContents = try? Data(contentsOf: url)
                    DispatchQueue.main.async {
                        if let imageData = urlContents, url == self?.imageURLs[indexPath.item]?.imageURL {
                            if let image = UIImage(data: imageData) {
                                imageCell.imageHeight = image.size.height
                                imageCell.imageWidth = image.size.width
                                imageCell.image = image
                                imageCell.layoutIfNeeded()
                            }
//
                            imageCell.layer.borderWidth = 5
                            imageCell.layer.borderColor = UIColor.black.cgColor
//
                        }
                    }
                }
            }
        }
        return cell
    }

    // MARK: UICollectionViewDragDelegate
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        session.localContext = collectionView
        return dragItems(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }
    
    private func dragItems(at indexPath: IndexPath) -> [UIDragItem] {
        if let image = (collectionView?.cellForItem(at: indexPath) as? ImageGalleryCollectionViewCell)?.imageView.image {
            let dragItem = UIDragItem(itemProvider: NSItemProvider(object: image))
            dragItem.localObject = image
            return [dragItem]
        } else {
            return []
        }
    }
    
    // MARK: UICollectionViewDropDelegate

    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: UIImage.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        let isSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView
        return UICollectionViewDropProposal(operation: isSelf ? .move : .copy , intent: .insertAtDestinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath {
                if item.dragItem.localObject as? UIImage != nil {
                    collectionView.performBatchUpdates({
                        imageURLs.swapAt(sourceIndexPath.item, destinationIndexPath.item)
                        imageGalleryTVC.albums[indexPathOfAlbum.row].URLs.swapAt(sourceIndexPath.item, destinationIndexPath.item)
                        collectionView.deleteItems(at: [sourceIndexPath])
                        collectionView.insertItems(at: [destinationIndexPath])
                    })
                    coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                }
            } else {
                let placeholderContext = coordinator.drop(
                    item.dragItem,
                    to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: "ImageCell")
                )
                if item.dragItem.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    item.dragItem.itemProvider.loadObject(ofClass: NSURL.self) { (provider, error) in
                        DispatchQueue.main.async {
                            if let url = provider as? URL {
                                placeholderContext.commitInsertion(dataSourceUpdates: { insertionIndexPath in
                                    self.imageURLs.insert(url.imageURL, at: insertionIndexPath.item)
                                    self.imageGalleryTVC.albums[self.indexPathOfAlbum.row].URLs.append(url.imageURL)
                                })
                            } else {
                                placeholderContext.deletePlaceholder()
                            }
                        }
                    }
                }
            }
        }
    }
    
}





