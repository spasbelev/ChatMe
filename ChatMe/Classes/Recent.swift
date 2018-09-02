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
        recent = [kRECENTID: recentId, kUSERID: userId, kCHATROOMID: chatRoomId, kMEMBERS: members, kMEMBERSTOPUSH: members, kWITHUSERFULLNAME: withUser!.fullname, kWITHUSERUSERID: withUser!.objectId, kLASTMESSAGE: "", kCOUNTER: 0, kDATE: date, kTYPE: typeOfChat, kAVATAR: withUser!.avatar] as! [String: Any]
    } else {
        if groupAvatar != nil {
            recent = [kRECENTID: recentId, kUSERID: userId, kCHATROOMID: chatRoomId, kMEMBERS: members, kMEMBERSTOPUSH: members, kWITHUSERFULLNAME: withUserUserName, kLASTMESSAGE: "", kCOUNTER: 0, kDATE: date, kTYPE: typeOfChat, kAVATAR: groupAvatar] as! [String: Any]
        }
    }
    
    localReference.setData(recent)
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
        createRecent(members: recent[kMEMBERSTOPUSH] as! [String], chatRoomId: recent[kCHATROOMID] as! String, withUserUserName: recent[kWITHUSERUSERNAME] as! String, typeOfChat: kGROUP, users: nil, groupAvatar: recent[kAVATAR] as? String)
    }
}


// MARK: Clear counter
func clearRecentCounterItem(recent: NSDictionary) {
    reference(.Recent).document(recent[kRECENTID] as! String).updateData([kCOUNTER: 0])
}
