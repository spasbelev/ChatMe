//
//  Downloaded.swift
//  ChatMe
//
//  Created by Spas Belev on 21.08.18.
//  Copyright © 2018 Spas Belev. All rights reserved.
//

import Foundation
import FirebaseStorage
import Firebase
import MBProgressHUD
import AVFoundation

let storage = Storage.storage()

// image


func uploadImage(image: UIImage, chatRoomId: String,view: UIView, completion: @escaping (_ imageLink:String?) -> Void){
    let progressHUD = MBProgressHUD.showAdded(to: view, animated: true)
    progressHUD.mode = .determinateHorizontalBar
    
    let dateString = dateFormatter().string(from: Date())
    let photoFileName = "PictureMessages/" + User.currentId() + "/" + chatRoomId + "/" + dateString + ".jpg"
    let storageRef = storage.reference(forURL: kFILEREFERENCE).child(photoFileName)
    let imageData = UIImageJPEGRepresentation(image, 0.7)
    
    var task: StorageUploadTask!
    task = storageRef.putData(imageData!, metadata: nil, completion: { (metadata, error) in
        task.removeAllObservers()
        progressHUD.hide(animated: true)
        
        if error != nil {
            print("Error uploading image: \(error!.localizedDescription)")
            return
        }
        
        storageRef.downloadURL(completion: { (url, error) in
            guard let url = url else {completion(nil)
                return
            }
            completion(url.absoluteURL.absoluteString)
        })
    })
    
    task.observe(StorageTaskStatus.progress) { (snapshot) in
        progressHUD.progress = Float((snapshot.progress?.completedUnitCount)!) / Float((snapshot.progress?.totalUnitCount)!)
    }
}