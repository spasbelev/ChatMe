//
//  RecentChatTableViewCell.swift
//  ChatMe
//
//  Created by Spas Belev on 18.08.18.
//  Copyright © 2018 Spas Belev. All rights reserved.
//

import UIKit

protocol RecentChatTableViewCellDelegate {
    func didTapAvatarImage(indexPath: IndexPath)
}

class RecentChatTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        messageCounterBackground.layer.cornerRadius = messageCounterBackground.frame.width / 2
        tapGestureRecognizer.addTarget(self, action: #selector(self.avatarTap))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tapGestureRecognizer)
    }

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var messageCounterBackground: UIView!
    @IBOutlet weak var messageCounterLabel: UILabel!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    
    var indexPath: IndexPath!
    var tapGestureRecognizer = UITapGestureRecognizer()
    var delegate: RecentChatTableViewCellDelegate?
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    
    func generateCall(recentChat: NSDictionary, indexPath: IndexPath) {
        self.indexPath = indexPath
        
        self.fullNameLabel.text = recentChat[kWITHUSERFULLNAME] as? String
        
        let decryptedText = Encryption.decryptText(chatRoomId: recentChat[kCHATROOMID] as! String, encryptedMessage: recentChat[kLASTMESSAGE] as! String)
        self.lastMessageLabel.text = decryptedText
        self.messageCounterLabel.text = recentChat[kCOUNTER] as? String
        
        if let avatarString = recentChat[kAVATAR] {
            imageFromData(pictureData: avatarString as! String) { (avatarImage) in
                
                if avatarImage != nil {
                    self.avatarImageView.image = avatarImage!.circleMasked
                }
            }
        }
        
        if recentChat[kCOUNTER] as! Int != 0 {
            self.messageCounterLabel.text = "\(recentChat[kCOUNTER] as! Int)"
            self.messageCounterBackground.isHidden = false
            self.messageCounterLabel.isHidden = false
        } else {
            self.messageCounterBackground.isHidden = true
            self.messageCounterLabel.isHidden = true
        }
        
        var date: Date!
        
        if let created = recentChat[kDATE] {
            if (created as! String).count != 14 {
                date = Date()
            } else {
                date = dateFormatter().date(from: created as! String)
            }
        } else {
            date = Date()
        }
        
        self.dataLabel.text = timeElapsed(date: date)
    }
    
    @objc func avatarTap() {
        delegate!.didTapAvatarImage(indexPath: indexPath)
    }
}
