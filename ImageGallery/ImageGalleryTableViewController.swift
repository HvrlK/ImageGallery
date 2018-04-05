//
//  ImageGalleryTableViewController.swift
//  ImageGallery
//
//  Created by Vitalii Havryliuk on 4/4/18.
//  Copyright © 2018 Vitalii Havryliuk. All rights reserved.
//

import UIKit

class ImageGalleryTableViewController: UITableViewController {

    var albums: [Album] = [Album(name: "Food", URLs: [])]
    var deletedAlbums: [Album] = []
    
    @IBAction func newAlbum(_ sender: UIBarButtonItem) {
        var names: [String] = []
        for album in albums {
            names += [album.name]
        }
        albums.append(Album(name: "Untitled".madeUnique(withRespectTo: names), URLs: []))
        tableView.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if splitViewController?.preferredDisplayMode != .primaryOverlay {
            splitViewController?.preferredDisplayMode = .primaryOverlay
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
            return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return albums.count
        case 1:
            return deletedAlbums.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumCell", for: indexPath)
        if let albumCell = cell as? ImageGalleryTableViewCell {
            if indexPath.section == 0 {
                albumCell.title.text = albums[indexPath.row].name
                albumCell.imageGalleryTVC = self
            } else {
                albumCell.title.text = deletedAlbums[indexPath.row].name
                albumCell.imageGalleryTVC = self
            }
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 && !deletedAlbums.isEmpty {
            return "Recently Deleted"
        } else {
            return nil
        }
    }
    

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if indexPath.section == 0 {
                deletedAlbums.append(albums.remove(at: indexPath.row))
                tableView.moveRow(at: indexPath, to: IndexPath(row: deletedAlbums.count - 1, section: 1))
            } else {
                deletedAlbums.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                reloadRecentlyDelatedData()
            }
        }
    }
    
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 1 {
            let contextual = UIContextualAction(style: .destructive, title: "Undelete") { (contextAction, view, isSuccess) in
                self.albums.append(self.deletedAlbums.remove(at: indexPath.row))
                tableView.moveRow(at: indexPath, to: IndexPath(row: self.albums.count - 1, section: 0))
                self.tableView.reloadData()
                self.reloadRecentlyDelatedData()
                isSuccess(true)
            }
            contextual.backgroundColor = .green
            return UISwipeActionsConfiguration(actions: [contextual])
        } else {
            return nil
        }
    }
    
    private func reloadRecentlyDelatedData() {
        if self.deletedAlbums.isEmpty {
            tableView.reloadSections(IndexSet(integer: 1), with: .fade)
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let NC = segue.destination as! UINavigationController
        let imageGallaryCVC = NC.topViewController as! ImageGalleryCollectionViewController
        if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
            imageGallaryCVC.title = albums[indexPath.row].name
            imageGallaryCVC.imageURLs = albums[indexPath.row].URLs
            imageGallaryCVC.indexPathOfAlbum = indexPath
            imageGallaryCVC.imageGalleryTVC = self
        }

    }

}
