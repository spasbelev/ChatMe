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
            message = createVideoMessage(messageDict: messageDictionary)
        case kAUDIO:
            message = createAudioMessage(messageDict: messageDictionary)
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
    
    func createVideoMessage(messageDict: NSDictionary) -> JSQMessage{
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
        let videoURL = NSURL(fileURLWithPath: messageDict[kVIDEO] as! String)
        let mediaItem = VideoMessage(withFileUrl: videoURL, maskOutgoing: returnuOutgoingStatusForUser(senderId: userID!))
        downloadVideo(videoUrl: messageDict[kVIDEO] as! String) { (isReadyToPlay, fileName) in
            let url = NSURL(fileURLWithPath: fileInDocumentsDirectory(fileName: fileName))
            mediaItem.status = kSUCCESS
            mediaItem.fileURL = url
            
            imageFromData(pictureData: messageDict[kPICTURE] as! String, withBlock: { (image) in
                if image != nil {
                    mediaItem.image = image
                    self.collectionView.reloadData()
                }
            })
            // Reload view when video is set to remove loading bar
            self.collectionView.reloadData()
        }
        return JSQMessage(senderId: userID, displayName: name, media: mediaItem)
    }
    
    func createAudioMessage(messageDict: NSDictionary) -> JSQMessage{
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
        let audioItem = JSQAudioMediaItem(data: nil)
        audioItem.appliesMediaViewMaskAsOutgoing = returnuOutgoingStatusForUser(senderId: userID!)
        let audioMessage = JSQMessage(senderId: userID!, displayName: name!, media: audioItem)
        
        // download audio
        downloadAudio(audioUrl: messageDict[kAUDIO] as! String) { (fileName) in
            let url = NSURL(fileURLWithPath: fileInDocumentsDirectory(fileName: fileName!))
            let audioData = try? Data(contentsOf: url as URL)
            audioItem.audioData = audioData
            
            self.collectionView.reloadData()
        }
        return audioMessage!
    }
   
    // MARK: Helper
    
    func returnuOutgoingStatusForUser(senderId: String) -> Bool {
        return senderId == User.currentId()
    }
}
