//
//  Recent.swift
//  ChatMe
//
//  Created by Spas Belev on 18.08.18.
//  Copyright © 2018 Spas Belev. All rights reserved.
//

import Foundation


func startPrivateChat(user1: User, user2: User) -> String {
    let userId1 = user1.objectId
    let userId2 = user2.objectId
    
    var chatRoomId = ""
    let value = userId1.compare(userId2).rawValue
    
    if value < 0 {
        chatRoomId = userId1 + userId2
    } else {
        chatRoomId = userId2 + userId1
    }
    
    let members = [userId1, userId2]
    
    createRecent(members: members, chatRoomId: chatRoomId, withUserUserName: "", typeOfChat: kPRIVATE, users: [user1, user2], groupAvatar: nil)
    
    return chatRoomId
}

func createRecent(members: [String], chatRoomId: String, withUserUserName: String, typeOfChat: String, users: [User]?, groupAvatar: String?) {
    var tempMembers = members
    reference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (snapshot, error) in
        guard let snapshot = snapshot else {return}
        if !snapshot.isEmpty {
            for recent in snapshot.documents {
                let currentRecent = recent.data() as NSDictionary
                if let currentUserId = currentRecent[kUSERID] {
                    if tempMembers.contains(currentUserId as! String) {
                        tempMembers.remove(at: tempMembers.index(of: currentUserId as! String)!)
                    }
                }
            }
        }
        
        for userId in tempMembers {
            createRecentItems(userId: userId, chatRoomId: chatRoomId, members: members, withUserUserName: withUserUserName, typeOfChat: typeOfChat, users: users, groupAvatar: groupAvatar)
        }
    }
}

func createRecentItems(userId: String, chatRoomId: String,members: [String], withUserUserName: String, typeOfChat: String, users: [User]?, groupAvatar: String?) {
    
    let localReference = reference(.Recent).document()
    let recentId = localReference.documentID
    
    let date = dateFormatter().string(from: Date())
    
    var recent : [String: Any]!
    
    if typeOfChat == kPRIVATE {
        var withUser: User?
        if users != nil && users!.count > 0 {
            if userId == User.currentId() {
                withUser = users!.last!
            } else {
                withUser = users!.first!
            }
        }
        recent = [kRECENTID: recentId, kUSERID: userId, kCHATROOMID: chatRoomId, kMEMBERS: members, kMEMBERSTOPUSH: members, kWITHUSERFULLNAME: withUser!.fullname, kWITHUSERUSERID: withUser!.objectId, kLASTMESSAGE: "", kCOUNTER: 0, kDATE: date, kTYPE: typeOfChat, kAVATAR: withUser!.avatar] as [String: Any]
    } else {
        if groupAvatar != nil {
            recent = [kRECENTID: recentId, kUSERID: userId, kCHATROOMID: chatRoomId, kMEMBERS: members, kMEMBERSTOPUSH: members, kWITHUSERFULLNAME: withUserUserName, kLASTMESSAGE: "", kCOUNTER: 0, kDATE: date, kTYPE: typeOfChat, kAVATAR: groupAvatar!] as [String: Any]
        }
    }
    
    localReference.setData(recent)
}

// MARK: Update recent

func updateRecents(chatRoomId: String, lastMessage: String) {
    reference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (snapshot, error) in
        guard let snapshot = snapshot else {return}
        if !snapshot.isEmpty {
            for recent in snapshot.documents {
                let currentRecent = recent.data() as NSDictionary
                updateRecentItem(recent: currentRecent, lastMessage: lastMessage)
            }
        }
    }
}

func updateRecentItem(recent: NSDictionary, lastMessage: String) {
    let date = dateFormatter().string(from: Date())
    var counter = recent[kCOUNTER] as! Int
    
    if recent[kUSERID] as! String != User.currentId() {
        counter += 1
    }
    let values = [kLASTMESSAGE: lastMessage, kCOUNTER: counter, kDATE: date] as [String: Any]
    reference(.Recent).document(recent[kRECENTID] as! String).updateData(values)
}

func deleteRecentChat(recentChatDict: NSDictionary) {
    if let recentId = recentChatDict[kRECENTID] {
        reference(.Recent).document(recentId as! String).delete()
    }
}

//resetart chat

func restartRecentChat(recent: NSDictionary) {
    if recent[kTYPE] as! String == kPRIVATE {
        createRecent(members: recent[kMEMBERSTOPUSH] as! [String], chatRoomId: recent[kCHATROOMID] as! String, withUserUserName: User.currentUser()!.firstname, typeOfChat: kPRIVATE, users: [User.currentUser()!], groupAvatar: nil)
    }
    
    if recent[kTYPE] as! String == kGROUP {
        createRecent(members: recent[kMEMBERSTOPUSH] as! [String], chatRoomId: recent[kCHATROOMID] as! String, withUserUserName: recent[kWITHUSERFULLNAME] as! String, typeOfChat: kGROUP, users: nil, groupAvatar: recent[kAVATAR] as? String)
    }
}


func clearRecentCounter(chatRoomId: String) {
    reference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (snapshot, error) in
        guard let snapshot = snapshot else {return}
        if !snapshot.isEmpty {
            for recent in snapshot.documents {
                let currentRecent = recent.data() as NSDictionary
                if currentRecent[kUSERID] as! String == User.currentId() {
                    clearRecentCounterItem(recent: currentRecent)
                }
            }
        }
    }
}

// MARK: Clear counter
func clearRecentCounterItem(recent: NSDictionary) {
    reference(.Recent).document(recent[kRECENTID] as! String).updateData([kCOUNTER: 0])
}

func updateExistingRecentWithNewValues(chatRoomID: String, members: [String], withValues: [String: Any]) {
    reference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomID).getDocuments { (snapshot, error) in
        guard let snapshot = snapshot else {return}
        
        if !snapshot.isEmpty {
            for recent in snapshot.documents {
                let recent = recent.data() as NSDictionary
                updateRecent(recentID: recent[kRECENTID] as! String, withValus: withValues)
            }
        }
    }
}

func updateRecent(recentID: String, withValus: [String: Any]) {
    reference(.Recent).document(recentID).updateData(withValus)
}

// MARK: block user

func blockUser(userToBlock: User) {
    let userId1 = User.currentId()
    let userId2 = userToBlock.objectId
    
    var chatRoomId = ""
    let value = userId1.compare(userId2).rawValue
    
    if value < 0 {
        chatRoomId = userId1 + userId2
    } else {
        chatRoomId = userId2 + userId1
    }
    getRecentsFor(chatRoomID: chatRoomId)
}

func getRecentsFor(chatRoomID: String) {
    
    reference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomID).getDocuments { (snapshot, error) in
        guard let snapshot = snapshot else {return}
        
        if !snapshot.isEmpty {
            for recent in snapshot.documents {
                let recent = recent.data() as NSDictionary
                deleteRecentChat(recentChatDict: recent)
            }
        }
    }
}

//group

func startGroupChat(group: Group) {
    
    let chatRoomId = group.groupDictionary[kGROUPID] as! String
    let members = group.groupDictionary[kMEMBERS] as! [String]
    
    createRecent(members: members, chatRoomId: chatRoomId, withUserUserName: group.groupDictionary[kNAME] as! String, typeOfChat: kGROUP, users: nil, groupAvatar: group.groupDictionary[kAVATAR] as? String)
}

func createRecentsForNewMembers(groupId: String, groupName: String, membersToPush: [String], avatar: String) {
    
    createRecent(members: membersToPush, chatRoomId: groupId, withUserUserName: groupName, typeOfChat: kGROUP, users: nil, groupAvatar: avatar)
}
