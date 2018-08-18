//
//  WelcomeViewController.swift
//  ChatMe
//
//  Created by Spas Belev on 11.08.18.
//  Copyright © 2018 Spas Belev. All rights reserved.
//

import UIKit
import ProgressHUD

class WelcomeViewController: UIViewController {

    
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var RetypePasswordTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    //MARK: IBActions
    @IBAction func loginButtonPressed(_ sender: Any) {
        dismissKeyboard()
        if EmailTextField.text != "" && PasswordTextField.text != "" {
            logInUser()
        } else {
            ProgressHUD.showError("Email and password are required to log in.")
        }
    }
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        dismissKeyboard()
        
        if EmailTextField.text != "" && PasswordTextField.text != ""  && RetypePasswordTextField.text != "" {
            if PasswordTextField.text! == RetypePasswordTextField.text! {
                registerUser()
            } else {
                ProgressHUD.showError("Passwords don't match")
            }
        } else {
            ProgressHUD.showError("All fields are required")
        }
    }
    
    func logInUser() {
        ProgressHUD.show("Login..")
        User.loginUserWith(email: EmailTextField.text!,password: PasswordTextField.text!) { (error) in
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            self.goToApp()
        }
    }
    
    func registerUser() {
        performSegue(withIdentifier: "fromWelcomeToFinishReg", sender: self)

        cleanTextField()
        dismissKeyboard()        
    }
    
    func dismissKeyboard() {
        self.view.endEditing(false)
    }
    
    func cleanTextField() {
        EmailTextField.text = ""
        PasswordTextField.text = ""
        RetypePasswordTextField.text = ""
    }
    
    func goToApp() {
        ProgressHUD.dismiss()
        cleanTextField()
        dismissKeyboard()
        
        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainApplication") as! UITabBarController
        
        self.present(mainView, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromWelcomeToFinishReg" {
            let vc = segue.destination as! FinishRegisterViewController
            vc.email = EmailTextField.text!
            vc.password = PasswordTextField.text!
        }
    }
}
