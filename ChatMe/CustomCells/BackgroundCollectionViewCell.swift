//
//  BackgroundCollectionViewCell.swift
//  ChatMe
//
//  Created by Spas Belev on 26.08.18.
//  Copyright © 2018 Spas Belev. All rights reserved.
//

import UIKit

class BackgroundCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func generateCell(image: UIImage) {
        self.imageView.image = image
    }
}
