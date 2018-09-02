//
//  GroupMemberCollectionViewCell.swift
//  ChatMe
//
//  Created by Spas Belev on 2.09.18.
//  Copyright © 2018 Spas Belev. All rights reserved.
//

import UIKit

protocol GroupMemberCollectionViewCellDelegate {
    func didClickDeleteButton(indexPath: IndexPath)
}

class GroupMemberCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    var indexPath: IndexPath!
    var delegate: GroupMemberCollectionViewCellDelegate?
    
    func generateCell(user: User, indexPath: IndexPath) {
        self.indexPath = indexPath
        nameLabel.text = user.firstname
        
        if user.avatar != " " {
            imageFromData(pictureData: user.avatar) { (avatarImage) in
                if avatarImage != nil {
                    self.avatarImageView.image = avatarImage!.circleMasked
                }
            }
        }
        
    }
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        // notify delegate
        delegate!.didClickDeleteButton(indexPath: indexPath)
    }
}
