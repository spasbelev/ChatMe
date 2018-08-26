//
//  SettingsTableViewController.swift
//  ChatMe
//
//  Created by Spas Belev on 17.08.18.
//  Copyright © 2018 Spas Belev. All rights reserved.
//

import UIKit
import ProgressHUD

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var deleteButtonOutlet: UIButton!
    @IBOutlet weak var avatarStatusSwitch: UISwitch!
    @IBOutlet weak var versionLabel: UILabel!
    
    var userDefaults = UserDefaults.standard
    var firstLoad: Bool?
    var avatarSwitchStatus = false
    
    @IBAction func cleanCacheButtonPressed(_ sender: Any) {
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: getDocumentsUrl().path)
            for file in files {
                try FileManager.default.removeItem(atPath: "\(getDocumentsUrl().path)/\(file)")
            }
            ProgressHUD.showSuccess("Media files cleaned")
        } catch  {
            ProgressHUD.showError("Couldn't clean Media files")
        }
    }
    
    //MARK : IBACtions
    @IBAction func showAvatarSwitchValue(_ sender: UISwitch) {
        avatarSwitchStatus = sender.isOn
        
        saveUserDefaults()
    }
    
    @IBAction func tellAFriendButtonPressed(_ sender: Any) {
        let text = "Hey lets chat on ChatMe \(kAPPURL)"
        let objectsToShare: [Any] = [text]
        
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        // in order not to crash on Ipad
        activityVC.popoverPresentationController?.sourceView = self.view
        activityVC.setValue("Lets chat on ChatMe", forKey: "subject")
        
        self.present(activityVC, animated: true, completion: nil)
    }
    
    
    
    @IBAction func logOutButtonPressed(_ sender: Any) {
        User.logOutCurrentUser { (success) in
            if success {
                self.showLoginView()
            }
        }
    }
    
    
    @IBAction func deleteAccountButtonPressed(_ sender: Any) {
        let optionMenu = UIAlertController(title: "Delete Account", message: "Are you sure you want to delete your account", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (alert) in
            self.deleteUser()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
            
        }
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            if let currentPopoverpresenticoncontroller = optionMenu.popoverPresentationController {
                currentPopoverpresenticoncontroller.sourceView = deleteButtonOutlet
                
                currentPopoverpresenticoncontroller.sourceRect = deleteButtonOutlet.bounds
                currentPopoverpresenticoncontroller.permittedArrowDirections = .up
                self.present(optionMenu, animated: true, completion: nil)
            }
        } else {
            self.present(optionMenu, animated: true, completion: nil)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if User.currentUser() != nil {
            loadUserDefaults()
            setupUI()
        }
    }
    
    // MARK Table view delegate
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 30
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.tableFooterView = UIView()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 1 {
            return 5
        }
        return 2
    }
    
    

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func showLoginView() {
        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "login")
        
        self.present(mainView, animated: true, completion: nil)
    }
    
    // MARK setup UI
    
    func setupUI() {
        let currentUser = User.currentUser()!
        fullNameLabel.text = currentUser.fullname
        if currentUser.avatar != "" {
            imageFromData(pictureData: currentUser.avatar) { (avatarImage) in
                if avatarImage != nil {
                    self.avatarImageView.image = avatarImage!.circleMasked
                    
                }
            }
        }
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionLabel.text = version
        }
    }
    
    // MARK delete user
    func deleteUser() {
        // delete locally
        userDefaults.removeObject(forKey: kPUSHID)
        userDefaults.removeObject(forKey: kCURRENTUSER)
        userDefaults.synchronize()
        
        // delete from firebase
        reference(.User).document(User.currentId()).delete()
        
        User.deleteUser { (error) in
            if error != nil {
                DispatchQueue.main.async {
                    ProgressHUD.showError("Couldn't delete user")
                }
                return
            }
            
            self.showLoginView()
        }
    }
    
    // MARK user defaults
    func saveUserDefaults() {
        userDefaults.set(avatarSwitchStatus, forKey: kSHOWAVATAR)
        userDefaults.synchronize()
    }
    
    func loadUserDefaults() {
        firstLoad = userDefaults.bool(forKey: kFIRSTRUN)
        if !firstLoad! {
            userDefaults.set(true, forKey: kFIRSTRUN)
            userDefaults.set(avatarSwitchStatus, forKey: kSHOWAVATAR)
            userDefaults.synchronize()
        }
        avatarSwitchStatus = userDefaults.bool(forKey: kSHOWAVATAR)
        avatarStatusSwitch.isOn = avatarSwitchStatus
    }
}
