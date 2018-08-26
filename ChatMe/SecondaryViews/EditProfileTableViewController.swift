//
//  EditProfileTableViewController.swift
//  ChatMe
//
//  Created by Spas Belev on 26.08.18.
//  Copyright © 2018 Spas Belev. All rights reserved.
//

import UIKit
import ProgressHUD
class EditProfileTableViewController: UITableViewController {

    // Control when available for click
    @IBOutlet weak var saveButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet var avatarTapGestureRecognizer: UITapGestureRecognizer!
    
    var avatarImage: UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        tableView.tableFooterView = UIView()
        setupUI()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    // MARK: IBActions
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        if areAllRequiredFieldsFileed() {
            ProgressHUD.show("Saving...")
            // block save button
            saveButtonOutlet.isEnabled = false
            let fullName = nameTextField.text! + " " + surnameTextField.text!
            var withValues = [kFIRSTNAME: nameTextField.text!, kLASTNAME: surnameTextField.text!, kFULLNAME: fullName]
            
            if avatarImage != nil {
                let avatarData = UIImageJPEGRepresentation(avatarImage!, 0.7)!
                let avatarString = avatarData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                withValues[kAVATAR] = avatarString
            }
            
            // update current user
            updateCurrentUserInFirestore(withValues: withValues) { (error) in
                if error != nil {
                    DispatchQueue.main.async {
                        ProgressHUD.showError(error!.localizedDescription)
                        print("Couldn't update user \(error!.localizedDescription)")
                    }
                    
                    return
                }
                ProgressHUD.showSuccess("Saved")
                self.saveButtonOutlet.isEnabled = true
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            ProgressHUD.showError("All fields are required")
        }
    }
    
    @IBAction func avatarTap(_ sender: Any) {
        print("show image pciker")
    }
    
    
    // MARK: setup UI
    func setupUI() {
        let currentUser = User.currentUser()!
        avatarImageView.isUserInteractionEnabled = true
        nameTextField.text = currentUser.firstname
        surnameTextField.text = currentUser.lastname
        emailTextField.text = currentUser.email
        
        if currentUser.avatar != "" {
            imageFromData(pictureData: currentUser.avatar) { (avatarImage) in
                if avatarImage != nil {
                    self.avatarImageView.image = avatarImage!.circleMasked
                }
            }
        }
    }
    
    // MARK: Helpers
    func areAllRequiredFieldsFileed() -> Bool {
        return nameTextField.text != "" && surnameTextField.text != "" && emailTextField.text != ""
    }

}
