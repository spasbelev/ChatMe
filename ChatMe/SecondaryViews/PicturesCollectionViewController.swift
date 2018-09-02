//
//  PicturesCollectionViewController.swift
//  ChatMe
//
//  Created by Spas Belev on 1.09.18.
//  Copyright © 2018 Spas Belev. All rights reserved.
//

import UIKit
import IDMPhotoBrowser

class PicturesCollectionViewController: UICollectionViewController {
    
    var allImages: [UIImage] = []
    var allImageLinks: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "All Pictures"
        
        if allImageLinks.count > 0 {
            downloadImages()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return allImages.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PicturesCollectionViewCell
    
        cell.generateCell(withImage: allImages[indexPath.row])
        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photos = IDMPhoto.photos(withImages: allImages)
        let browser = IDMPhotoBrowser(photos: photos)
        browser?.displayDoneButton = false
        browser?.setInitialPageIndex(UInt(indexPath.row))
        self.present(browser!, animated: true, completion: nil)
    }
    
    // MARK: Download images
    
    func downloadImages() {
        for imageLink in allImageLinks {
            downloadImage(imageUrl: imageLink) { (image) in
                if image != nil {
                    self.allImages.append(image!)
                    self.collectionView?.reloadData()
                }
            }
        }
    }

}
