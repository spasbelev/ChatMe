//
//  IncomingMessages.swift
//  ChatMe
//
//  Created by Spas Belev on 18.08.18.
//  Copyright © 2018 Spas Belev. All rights reserved.
//

import Foundation
import JSQMessagesViewController

class IncomingMessage {
    var collectionView: JSQMessagesCollectionView
    
    init(collectionView_: JSQMessagesCollectionView) {
        collectionView = collectionView_
    }
    
    // MARK create message
    func createMessage(messageDictionary: NSDictionary, chatRoomID: String) -> JSQMessage? {
        var message: JSQMessage?
        
        let type = messageDictionary[kTYPE] as! String
        
        switch type {
        case kTEXT:
            message = createTextMessage(messageDict: messageDictionary, chatRoomId: chatRoomID)
        case kPICTURE:
            message = createPictureMessage(messageDict: messageDictionary)
        case kVIDEO:
            print("create video")
        case kAUDIO:
            print("create audio")
        case kLOCATION:
            print("location")
        default:
            print("Unknown message type")
        }
        
        if message != nil {
            return message
        }
        
        return nil
    }
    
    func createTextMessage(messageDict: NSDictionary, chatRoomId: String) -> JSQMessage{
        let name = messageDict[kSENDERNAME] as? String
        let userID = messageDict[kSENDERID] as? String
        
        var date: Date!
        
        if let created = messageDict[kDATE] {
            if(created as! String).count != 14 {
                date = Date()
            } else {
                date = dateFormatter().date(from: created as! String)
            }
        } else {
            date = Date()
        }
        let text = messageDict[kMESSAGE] as! String
        return JSQMessage(senderId: userID, senderDisplayName: name, date: date, text: text)
    }
    
    func createPictureMessage(messageDict: NSDictionary) -> JSQMessage{
        let name = messageDict[kSENDERNAME] as? String
        let userID = messageDict[kSENDERID] as? String
        var date: Date!
        
        if let created = messageDict[kDATE] {
            if(created as! String).count != 14 {
                date = Date()
            } else {
                date = dateFormatter().date(from: created as! String)
            }
        } else {
            date = Date()
        }
        let mediaItem = PhotoMediaItem(image: nil)
        mediaItem?.appliesMediaViewMaskAsOutgoing = returnuOutgoingStatusForUser(senderId: userID!)
        downloadImage(imageUrl: messageDict[kPICTURE] as! String) { (image) in
            if image != nil {
                mediaItem?.image = image
                self.collectionView.reloadData()
            }
        }
        return JSQMessage(senderId: userID, displayName: name, media: mediaItem)
    }
   
    // MARK: Helper
    
    func returnuOutgoingStatusForUser(senderId: String) -> Bool {
        return senderId == User.currentId()
    }
}
