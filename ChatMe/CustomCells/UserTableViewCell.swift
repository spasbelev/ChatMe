//
//  UserTableViewCell.swift
//  ChatMe
//
//  Created by Spas Belev on 17.08.18.
//  Copyright © 2018 Spas Belev. All rights reserved.
//

import UIKit

protocol UserTableViewCellDelegate {
    func didTapAvatarImage(indexPath: IndexPath)
}

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    
    var indexPath: IndexPath!
    let tapGestureRec = UITapGestureRecognizer()
    var delegate: UserTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tapGestureRec.addTarget(self, action: #selector(self.avatarTap))
        avatar.isUserInteractionEnabled = true
        avatar.addGestureRecognizer(tapGestureRec)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func generateCellWith(user: User, indexPath: IndexPath) {
        self.indexPath = indexPath
        self.fullNameLabel.text = user.fullname
        
        if user.avatar != "" {
            imageFromData(pictureData: user.avatar) { (avatar) in
                if avatar != nil {
                    self.avatar.image = avatar?.circleMasked
                }
            }
        }
    }
    
    @objc func avatarTap() {
        delegate!.didTapAvatarImage(indexPath: indexPath)
    }
}
