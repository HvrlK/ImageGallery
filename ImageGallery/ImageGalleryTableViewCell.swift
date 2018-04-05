//
//  ImageGalleryTableViewCell.swift
//  ImageGallery
//
//  Created by Vitalii Havryliuk on 4/4/18.
//  Copyright © 2018 Vitalii Havryliuk. All rights reserved.
//

import UIKit

class ImageGalleryTableViewCell: UITableViewCell, UITextFieldDelegate {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.title.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired = 2
        self.addGestureRecognizer(tap)
    }
    
    @IBOutlet weak var title: UITextField!
    
    var imageGalleryTVC: ImageGalleryTableViewController!
    
    @objc private func doubleTapped() {
        title.isEnabled = true
        title.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let indexPath = imageGalleryTVC.tableView.indexPath(for: self) {
            imageGalleryTVC.albums[indexPath.row].name = title.text!
        }
        title.isEnabled = false
        title.resignFirstResponder()
        return true
    }
    
    
    
}
