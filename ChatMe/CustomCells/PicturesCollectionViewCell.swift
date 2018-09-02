//
//  PicturesCollectionViewCell.swift
//  ChatMe
//
//  Created by Spas Belev on 1.09.18.
//  Copyright © 2018 Spas Belev. All rights reserved.
//

import UIKit

class PicturesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func generateCell(withImage: UIImage) {
        self.imageView.image = withImage
    }
}
