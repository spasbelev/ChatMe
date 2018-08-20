//
//  ChatViewController.swift
//  ChatMe
//
//  Created by Spas Belev on 18.08.18.
//  Copyright © 2018 Spas Belev. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import ProgressHUD
import IQAudioRecorderController
import IDMPhotoBrowser
import AVFoundation
import AVKit
import FirebaseFirestore

class ChatViewController: JSQMessagesViewController {

    var chatRoomId: String!
    var memberIds: [String]!
    var membersToPush: [String]!
    var chatTitle: String!
    var isGroup: Bool?
    var group: NSDictionary?
    var withUsers: [User] = []
    
    
    let legitTypes = [kAUDIO, kVIDEO, kPICTURE, kTEXT, kLOCATION]
    var messages: [JSQMessage] = []
    var objectMessage: [NSDictionary] = []
    var loadedMessage: [NSDictionary] = []
    var allPictureMessages:[String] = []
    var initialLoadComplete = false
    
    var newChatListener: ListenerRegistration?
    var typingListener: ListenerRegistration?
    var updatedChatListener: ListenerRegistration?
    
    var maxMessages = 0
    var minMessages = 0
    var loadOld = false
    var loadedMessagesCount = 0
    
    // MARK: Custom header
    let leftBarButtonView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        return view
    }()
    
    let avatarButton: UIButton = {
       let button = UIButton(frame: CGRect(x: 0, y: 10, width: 25, height: 25))
        return button
    }()
    
    let titleLabel: UILabel = {
       let title = UILabel(frame: CGRect(x: 30, y: 10, width: 140, height: 15))
        title.textAlignment = .left
        title.font = UIFont(name: title.font.fontName, size: 14)
        return title
    }()
    
    let subTitleLabel: UILabel = {
        let subTitle = UILabel(frame: CGRect(x: 30, y: 25, width: 140, height: 15))
        subTitle.textAlignment = .left
        subTitle.font = UIFont(name: subTitle.font.fontName, size: 10)
        return subTitle
    }()
    
    var outgoingBuble = JSQMessagesBubbleImageFactory()?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    var incomingBuble = JSQMessagesBubbleImageFactory()?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    
    override func viewDidLayoutSubviews() {
        perform(Selector(("jsq_updateCollectionViewInsets")))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        
        collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        setCustomTitle()
        
        loadMessages()
        self.senderId = User.currentId()
        self.senderDisplayName = User.currentUser()!.firstname
        
        // Fix for ihpone X
        let constraint = perform(Selector(("toolbarBottomLayoutGuide")))?.takeUnretainedValue() as! NSLayoutConstraint
        
        constraint.priority = UILayoutPriority(1000)
        self.inputToolbar.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        // end of iphone X fix
        self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "mic"), for: .normal)
        self.inputToolbar.contentView.rightBarButtonItem.setTitle("", for: .normal)
        
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(named: "Back"), style: .plain, target: self, action: #selector(self.backAction))]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK JSQMEssages data source functions
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        let data = messages[indexPath.row]
        
        // set text color
        if data.senderId == User.currentId() {
            cell.textView.textColor = .white
        } else {
            cell.textView.textColor = .black
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let data = messages[indexPath.row]
        
        if data.senderId == User.currentId() {
            return outgoingBuble
        } else {
            return incomingBuble
        }
    }
    
    func listenForNewChats() {
        var lastMessageDate = "0"
        
        if loadedMessage.count > 0 {
            lastMessageDate = loadedMessage.last![kDATE] as! String
        }
        
        newChatListener = reference(.Message).document(User.currentId()).collection(chatRoomId).whereField(kDATE, isGreaterThan: lastMessageDate).addSnapshotListener({ (snapshot, error) in
            guard let snapshot = snapshot else{return}
            
            if !snapshot.isEmpty {
                for diff in snapshot.documentChanges {
                    if (diff.type == .added) {
                        let item = diff.document.data() as NSDictionary
                        
                        if let type = item[kTYPE] {
                            if self.legitTypes.contains(type as! String) {
                                if type as! String == kPICTURE {
                                    // add to pictures
                                }
                                
                                if self.insertInitialLoadedMessages(messageDict: item) {
                                    JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
                                }
                                
                                self.finishReceivingMessage()
                            }
                        }
                    }
                }
            }
        })
    }
    
    //MARK JSQMessages delegate functions
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takePhotosOrVideo = UIAlertAction(title: "Camera", style: .default) { (action) in
            print("camera")
        }
        
        let sharePhoto = UIAlertAction(title: "Photo Library", style: .default) { (action) in
        print("Photo")
        }
        
        let shareVideo = UIAlertAction(title: "Video Library", style: .default) { (action) in
            print("Video")
        }
        
        let shareLocation = UIAlertAction(title: "Share Location ", style: .default) { (action) in
            print("Location")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            print("Cancel")
        }
        
        takePhotosOrVideo.setValue(UIImage(named: "camera"), forKey: "image")
        sharePhoto.setValue(UIImage(named: "picture"), forKey: "image")
        shareVideo.setValue(UIImage(named: "video"), forKey: "image")
        shareLocation.setValue(UIImage(named: "location"), forKey: "image")
        
        optionMenu.addAction(takePhotosOrVideo)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(shareVideo)
        optionMenu.addAction(shareLocation)
        optionMenu.addAction(cancelAction)
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            if let currentPopoverpresenticoncontroller = optionMenu.popoverPresentationController {
                currentPopoverpresenticoncontroller.sourceView = self.inputToolbar.contentView.leftBarButtonItem
                
                currentPopoverpresenticoncontroller.sourceRect = self.inputToolbar.contentView.leftBarButtonItem.bounds
                currentPopoverpresenticoncontroller.permittedArrowDirections = .up
                self.present(optionMenu, animated: true, completion: nil)
            }
        } else {
            self.present(optionMenu, animated: true, completion: nil)
        }
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        if text != "" {
            self.sendMessage(text: text, data: date, picture: nil, location: nil, video: nil, audio: nil)
            updateSendButton(isSend: false)
        } else {
            
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        
        self.loadMoreMessages(maxNumber: maxMessages, minNumber: minMessages)
        self.collectionView.reloadData()
    }
    
    // MARK: IBAction
    @objc func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func infoButtonPressed() {
        print("show Img msg")
    }
    
    @objc func showGroup() {
        print("show group")
    }
    
    @objc func showProfile() {
        let profileView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileView") as! ProfileTableViewController
        
        profileView.user = withUsers.first!
        self.navigationController?.pushViewController(profileView, animated: true)
    }
    
    override func textViewDidChange(_ textView: UITextView) {
        if textView.text != "" {
            updateSendButton(isSend: true)
        } else {
           updateSendButton(isSend: false)
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        if indexPath.item % 3 == 0 {
            let message = messages[indexPath.row]
            
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
        } else {
            return nil
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        if indexPath.item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        } else {
            return 0.0
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = objectMessage[indexPath.row]
        let status: NSAttributedString
        
        let attributedStringColor = [NSAttributedStringKey.foregroundColor: UIColor.darkGray]
        
        switch message[kSTATUS] as! String {
        case kDELIVERED:
            status = NSAttributedString(string: kDELIVERED)
        case kREAD:
            let statusText = "Read" + " " + readTimeFrom(dateString: message[kREADDATE] as! String)
            status = NSAttributedString(string: statusText, attributes: attributedStringColor)
        default:
            status = NSAttributedString(string: "✔︎")
        }
        
        if indexPath.row == (messages.count - 1) {
            return status
        } else {
            return NSAttributedString(string: "")
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        let data = messages[indexPath.row]
        
        if data.senderId == User.currentId() {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        } else {
            return 0.0
        }
    }

    // MARK custom send
    
    func updateSendButton(isSend: Bool) {
        if isSend {
            self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named:"send"), for: .normal)
        } else {
            self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named:"mic"), for: .normal)
        }
    }
    
    // MARK send message func
    
    func sendMessage(text: String?, data: Date, picture: UIImage?,location: String?, video: NSURL?, audio: String? ) {
        var outgoingMessage: OutgoingMessages?
        var currentUser = User.currentUser()!
        
        if let text = text {
            outgoingMessage = OutgoingMessages(message: text, senderId: currentUser.objectId, senderName: currentUser.firstname, date: data, status: kDELIVERED, type: kTEXT)
        }
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        self.finishSendingMessage()
        outgoingMessage!.sendMessage(chatRoomID: chatRoomId, messageDict: outgoingMessage!.messageDictionary, memberIds: memberIds, membersToPush: membersToPush)
    }
    
    // MARK load messages
    
    func loadMessages() {
        reference(.Message).document(User.currentId()).collection(chatRoomId).order(by: kDATE, descending: true).limit(to: 11).getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else{
                self.initialLoadComplete = true
                //listen for new chats
                return
            }
            let sorted = ((dictionaryFromSnapshots(snapshots: snapshot.documents)) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: true)]) as! [NSDictionary]
            
            self.loadedMessage = self.removeBadMessages(allMessages: sorted)
            
            self.insertMessages()
            self.finishReceivingMessage()
            self.initialLoadComplete = true
            print("We have \(self.messages.count) ")
            // get pic msg
            self.getOldMessagesInBackground()
            self.listenForNewChats()
        }
    }
    
    func getOldMessagesInBackground() {
        if loadedMessage.count > 10 {
            let firstMessageDate = loadedMessage.first![kDATE] as! String
            reference(.Message).document(User.currentId()).collection(chatRoomId).whereField(kDATE, isLessThan: firstMessageDate).getDocuments { (snapshot, error) in
                guard let snapshot = snapshot else{return}
                let sorted = ( (dictionaryFromSnapshots(snapshots: snapshot.documents)) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: true)]) as! [NSDictionary]
                self.loadedMessage = self.removeBadMessages(allMessages: sorted) + self.loadedMessage
                
                // get pic msg
                self.maxMessages = self.loadedMessage.count - self.loadedMessagesCount - 1
                self.minMessages = self.maxMessages - kNUMBEROFMESSAGES
            }
        }
    }
    
    
    // MARK Insert Msg
    
    func insertMessages() {
        maxMessages = loadedMessage.count - loadedMessagesCount
        minMessages = maxMessages - kNUMBEROFMESSAGES
        
        if minMessages < 0 {
            minMessages = 0
        }
        for i in minMessages ..< maxMessages {
            let messageDictionary = loadedMessage[i]
            insertInitialLoadedMessages(messageDict: messageDictionary)
            loadedMessagesCount += 1
            
        }
        self.showLoadEarlierMessagesHeader = (loadedMessagesCount != loadedMessage.count)
    }
    
    func insertInitialLoadedMessages(messageDict: NSDictionary) -> Bool {
        let incomingMessage = IncomingMessage(collectionView_: self.collectionView)
        if (messageDict[kSENDERID] as! String) != User.currentId() {
            // update message status
        }
        let message = incomingMessage.createMessage(messageDictionary: messageDict, chatRoomID: chatRoomId)
        
        if message != nil {
            objectMessage.append(messageDict)
            messages.append(message!)
        }
        
        return isIncoming(messageDict:messageDict)
    }
    
    
    func isIncoming(messageDict: NSDictionary) -> Bool{
        if User.currentId() == messageDict[kSENDERID] as! String {
            return false
        } else {
            return true
        }
    }
    
    // Load more messages
    
    func loadMoreMessages(maxNumber: Int, minNumber: Int) {
        if loadOld {
            maxMessages = minMessages - 1
            minMessages = maxMessages - kNUMBEROFMESSAGES
        }
        
        if minMessages < 0 {
            minMessages = 0
        }
        
        for i in (minMessages...maxMessages).reversed() {
            let messageDict = loadedMessage[i]
            insertNewMessage(messageDictionary: messageDict)
            loadedMessagesCount += 1
        }
        
        loadOld = true
        self.showLoadEarlierMessagesHeader = (loadedMessagesCount != loadedMessage.count)
    }
    
    func insertNewMessage(messageDictionary: NSDictionary) {
        let incomingMsg = IncomingMessage(collectionView_: self.collectionView!)
        let message = incomingMsg.createMessage(messageDictionary: messageDictionary, chatRoomID: chatRoomId)
        objectMessage.insert(messageDictionary, at: 0)
        messages.insert(message!, at: 0)
    }
    
    //MARK: UpdateUI
    func setCustomTitle() {
        leftBarButtonView.addSubview(avatarButton)
        leftBarButtonView.addSubview(titleLabel)
        leftBarButtonView.addSubview(subTitleLabel)
        
        let infoButton = UIBarButtonItem(image: UIImage(named: "info"), style: .plain, target: self, action: #selector(self.infoButtonPressed))
        
        self.navigationItem.rightBarButtonItem = infoButton
        let leftBarButtonItem = UIBarButtonItem(customView: leftBarButtonView)
        self.navigationItem.leftBarButtonItems?.append(leftBarButtonItem)
        
        if isGroup! {
            avatarButton.addTarget(self, action: #selector(self.showGroup), for: .touchUpInside)
        } else {
            avatarButton.addTarget(self, action: #selector(self.showProfile), for: .touchUpInside)
        }
        getUsersFromFirestore(withIds: memberIds) { (withUsers) in
            self.withUsers = withUsers
            
            if !self.isGroup! {
                self.setUIForSingleChat()
            }
        }
    }
    
    func setUIForSingleChat() {
        let withUser = withUsers.first!
        
        imageFromData(pictureData: withUser.avatar) { (image) in
            if image != nil {
                avatarButton.setImage(image!.circleMasked, for: .normal)
                titleLabel.text = withUser.fullname
                
                if withUser.isOnline {
                    subTitleLabel.text = "Online"
                } else {
                    subTitleLabel.text = "Offline"
                }
                
                avatarButton.addTarget(self, action: #selector(self.showProfile), for: .touchUpInside)
            }
        }
    }
    
    func removeBadMessages(allMessages: [NSDictionary]) -> [NSDictionary] {
        var tempMessages = allMessages
        
        for message in tempMessages {
            if message[kTYPE] != nil {
                if !self.legitTypes.contains(message[kTYPE] as! String) {
                    // remove the message
                    tempMessages.remove(at: tempMessages.index(of: message)!)
                }
            } else {
                tempMessages.remove(at: tempMessages.index(of: message)!)
            }
        }
        
        return tempMessages
    }
}
