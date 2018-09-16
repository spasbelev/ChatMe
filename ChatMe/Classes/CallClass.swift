//
//  CallClass.swift
//  ChatMe
//
//  Created by Spas Belev on 14.09.18.
//  Copyright © 2018 Spas Belev. All rights reserved.
//

import Foundation

class CallClass {
    var objectId: String
    var callerId: String
    var callerFullName: String
    var withUserFullName: String
    var withUserId: String
    var status: String
    var isIncoming: Bool
    var callDate: Date
    
    init(_calledId: String, _withUserId: String, _callerFullName: String, _withUserFullName: String) {
        objectId = UUID().uuidString
        callerId = _calledId
        callerFullName = _callerFullName
        withUserFullName = _withUserFullName
        withUserId = _withUserId
        status = ""
        isIncoming = false
        callDate = Date()
    }
    
    init(_dictionary: NSDictionary) {
        objectId = _dictionary[kOBJECTID] as! String
        
        if let callId = _dictionary[kCALLERID] {
            callerId = callId as! String
        } else {
            callerId = ""
        }
        if let withId = _dictionary[kWITHUSERUSERID] {
            withUserId = withId as! String
        } else {
            withUserId = ""
        }
        if let callFullName = _dictionary[kCALLERFULLNAME] {
            callerFullName = callFullName as! String
        } else {
            callerFullName = "Unknown"
        }
        if let withFullName = _dictionary[kWITHUSERFULLNAME] {
            withUserFullName = withFullName as! String
        } else {
            withUserFullName = "Unknown"
        }
        if let callStatus = _dictionary[kCALLSTATUS] {
            status = callStatus as! String
        } else {
            status = "Unknown"
        }
        if let incoming = _dictionary[kISINCOMING] {
            isIncoming = incoming as! Bool
        } else {
            isIncoming = false
        }
        if let date = _dictionary[kCREATEDAT] {
            if (date as! String).count != 14 {
                callDate = Date()
            } else {
                callDate = dateFormatter().date(from: date as! String)!
            }
        } else {
            callDate = Date()
        }
    }
    
    func dictionaryFromCall() -> NSDictionary {
        let dateString = dateFormatter().string(from: callDate)
        return NSDictionary(objects: [objectId, callerId, callerFullName, withUserFullName, withUserId, status,isIncoming, dateString], forKeys: [kOBJECTID as NSCopying, kCALLERID as NSCopying, kCALLERFULLNAME as NSCopying, kWITHUSERFULLNAME as NSCopying, kWITHUSERUSERID as NSCopying, kSTATUS as NSCopying, kISINCOMING as NSCopying, kDATE as NSCopying])
    }
    
    //MARK: Save
    func saveCallInBackgrund() {
        reference(.Call).document(callerId).collection(callerId).document(objectId).setData(dictionaryFromCall() as! [String: Any])
        
        reference(.Call).document(withUserId).collection(withUserId).document(objectId).setData(dictionaryFromCall() as! [String: Any])
    }
    
    //MARK: Delete
    func deleteCall() {
        reference(.Call).document(User.currentId()).collection(User.currentId()).document(objectId).delete()
    }
}
