//
//  ProfileTableViewController.swift
//  ChatMe
//
//  Created by Spas Belev on 18.08.18.
//  Copyright © 2018 Spas Belev. All rights reserved.
//

import UIKit
import ProgressHUD

class ProfileTableViewController: UITableViewController {

    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var messageButtonOutlet: UIButton!
    @IBOutlet weak var blockButtonOutlet: UIButton!
    @IBOutlet weak var callButtonOutlet: UIButton!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    var user: User?
    
    @IBAction func callButtonPressed(_ sender: Any) {
    }
    
    
    @IBAction func chatButtonPressed(_ sender: Any) {
        if !checkBlockStatus(withUser: user!) {
            let chatVC = ChatViewController()
            chatVC.title = user!.firstname
            chatVC.membersToPush = [User.currentId(), user!.objectId]
            chatVC.memberIds = [User.currentId(), user!.objectId]
            chatVC.chatRoomId = startPrivateChat(user1: User.currentUser()!, user2: user!)
            chatVC.isGroup = true
            chatVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(chatVC, animated: true)
        } else {
            ProgressHUD.showError("This user is not available for chat")
        }
    }
    
    
    @IBAction func blockUserButtonPressed(_ sender: Any) {
        var currentBlockedList = User.currentUser()!.blockedUsers
        if currentBlockedList.contains(user!.objectId) {
            currentBlockedList.remove(at: currentBlockedList.index(of: user!.objectId)!)
        } else {
            currentBlockedList.append(user!.objectId)
        }
        
        updateCurrentUserInFirestore(withValues: [kBLOCKEDUSERID : currentBlockedList]) { (error) in
            if error != nil {
                print("error updating user.. \(error!.localizedDescription)")
                return
            }
            
            self.updateBlockStatus()
        }
        
        blockUser(userToBlock: user!)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else {
            return 30
        }
    }
    
    func setUpUI() {
        if user != nil {
            self.title = "Profile"
            fullNameLabel.text = user!.fullname
            phoneNumberLabel.text = user!.phoneNumber
            updateBlockStatus()
            imageFromData(pictureData: user!.avatar) { (image) in
                if image != nil {
                    self.avatarImageView.image = image!.circleMasked
                }
            }
        }
    }
    
    func updateBlockStatus() {
        if user!.objectId != User.currentId() {
            blockButtonOutlet.isHidden = false
            messageButtonOutlet.isHidden = false
            callButtonOutlet.isHidden = false
        } else {
            blockButtonOutlet.isHidden = true
            messageButtonOutlet.isHidden = true
            callButtonOutlet.isHidden = true
        }
        
        if User.currentUser()!.blockedUsers.contains(user!.objectId) {
            blockButtonOutlet.setTitle("Unblock User", for: .normal)
        } else {
            blockButtonOutlet.setTitle("Block User", for: .normal)
        }
    }
}
