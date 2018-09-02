//
//  BlockedUsersViewController.swift
//  ChatMe
//
//  Created by Spas Belev on 26.08.18.
//  Copyright © 2018 Spas Belev. All rights reserved.
//

import UIKit
import ProgressHUD

class BlockedUsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UserTableViewCellDelegate {
    

    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var blockedUsers : [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        tableView.tableFooterView = UIView()
        loadUsers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        notificationLabel.isHidden = blockedUsers.count != 0
        return blockedUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UserTableViewCell
        cell.delegate = self
        cell.generateCellWith(user: blockedUsers[indexPath.row], indexPath: indexPath)
        return cell
    }
    
    // MARK: Table view delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Unblock"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        var tempBlockedUsers = User.currentUser()!.blockedUsers
        let userIdToUnblock  = blockedUsers[indexPath.row].objectId
        tempBlockedUsers.remove(at: tempBlockedUsers.index(of: userIdToUnblock)!)
        blockedUsers.remove(at: indexPath.row)
        updateCurrentUserInFirestore(withValues: [kBLOCKEDUSERID: tempBlockedUsers]) { (error) in
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
            }
            
            self.tableView.reloadData()
        }
    }
    
    // MARK: user table view cell delegate
    func didTapAvatarImage(indexPath: IndexPath) {
        let profileVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileView") as! ProfileTableViewController
        
        profileVC.user = blockedUsers[indexPath.row]
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    // MARK: load blocked users
    func loadUsers() {
        if User.currentUser()!.blockedUsers.count > 0 {
            ProgressHUD.show()
            getUsersFromFirestore(withIds: User.currentUser()!.blockedUsers) { (allBlockedUsers) in
                ProgressHUD.dismiss()
                self.blockedUsers = allBlockedUsers
                self.tableView.reloadData()
            }
        }
    }

}
