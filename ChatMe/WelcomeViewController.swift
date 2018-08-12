//
//  WelcomeViewController.swift
//  ChatMe
//
//  Created by Spas Belev on 11.08.18.
//  Copyright © 2018 Spas Belev. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    
    @IBOutlet weak var EmailTextField: UILabel!
    @IBOutlet weak var PasswordTextField: UILabel!
    @IBOutlet weak var RetypePasswordTextField: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    //MARK: IBActions
    @IBAction func loginButtonPressed(_ sender: Any) {
        print("login")
    }
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        print("pressed")
    }
    
    func dismissKeyboard() {
        self.view.endEditing(false)
    }
    
    func cleanTextField() {
        EmailTextField.text = ""
        PasswordTextField.text = ""
        RetypePasswordTextField.text = ""
    }
}
