//
//  ChatsViewController.swift
//  ChatMe
//
//  Created by Spas Belev on 18.08.18.
//  Copyright © 2018 Spas Belev. All rights reserved.
//

import UIKit
import FirebaseFirestore


class ChatsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    var recentChats: [NSDictionary] = []
    var filteredChats: [NSDictionary] = []
    var recentListener: ListenerRegistration!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        loadRecentChats()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func createNewChatButtonPressed(_ sender: Any) {
        
        let userVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "usersTableView") as! UsersTableViewController
        
        self.navigationController?.pushViewController(userVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print(recentChats.count)
        return recentChats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RecentChatTableViewCell
        
        let recent = recentChats[indexPath.row]
        cell.generateCall(recentChat: recent, indexPath: indexPath)
        return cell
    }
    
    func loadRecentChats() {
        recentListener = reference(.Recent).whereField(kUSERID, isEqualTo: User.currentId()).addSnapshotListener({ (snapshot, error) in
            guard let snapshot = snapshot else {return}
            self.recentChats = []
            
            if !snapshot.isEmpty {
                let sorted = (dictionaryFromSnapshots(snapshots: snapshot.documents) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: false)]) as! [NSDictionary]
                
                for recent in sorted {
                    if recent[kLASTMESSAGE] as! String != "" && recent[kCHATROOMID] != nil && recent[kRECENTID] != nil {
                        self.recentChats.append(recent)
                    }
                }
                
                self.tableView.reloadData()
            }
            
            print("Snapshot empty")
        })
    }
}
