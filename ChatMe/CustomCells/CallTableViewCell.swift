//
//  CallTableViewCell.swift
//  ChatMe
//
//  Created by Spas Belev on 14.09.18.
//  Copyright © 2018 Spas Belev. All rights reserved.
//

import UIKit

class CallTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func generateCellWith(call: CallClass) {
        dateLabel.text = formatCallTime(date: call.callDate)
        statusLabel.text = ""
        if call.callerId == User.currentId() {
            statusLabel.text = "Outgoing"
            fullNameLabel.text = call.withUserFullName
            // add avatar if needed but makes it slow
            
//            avatarImageView.image = UIImage(named: "Outgoing")
        } else {
            statusLabel.text = "Incoming"
            fullNameLabel.text = call.callerFullName
//            avatarImageView.image = UIImage(named: "Incoming")
        }
    }

}
