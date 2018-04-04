//
//  ImageGalleryCollectionViewCell.swift
//  ImageGallery
//
//  Created by Vitalii Havryliuk on 4/3/18.
//  Copyright © 2018 Vitalii Havryliuk. All rights reserved.
//

import UIKit

class ImageGalleryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var imageHeight: CGFloat = 0
    var imageWidth: CGFloat = 0
    
    var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.frame.origin = CGPoint(x: 0, y: self.frame.midY - (imageHeight / imageWidth * self.frame.size.width) / 2)
            imageView.frame.size = CGSize(width: self.frame.size.width, height: imageHeight / imageWidth * self.frame.size.width)
            imageView.image = newValue
            spinner.stopAnimating()
        }
    }
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
}
