//
//  SettingsTableViewController.swift
//  ChatMe
//
//  Created by Spas Belev on 17.08.18.
//  Copyright © 2018 Spas Belev. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBAction func logOutButtonPressed(_ sender: Any) {
        User.logOutCurrentUser { (success) in
            if success {
                self.showLoginView()
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func showLoginView() {
        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "login")
        
        self.present(mainView, animated: true, completion: nil)
    }
}
