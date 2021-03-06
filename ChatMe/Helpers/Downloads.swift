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

func downloadImage(imageUrl: String, completion: @escaping (_ image: UIImage?) -> Void) {
    let imageURL = NSURL(string: imageUrl)
    let imageFileName = (imageUrl.components(separatedBy: "%").last!).components(separatedBy: "?").first!
    
    if fileExistsInDocumentsDir(filePath: imageFileName) {
        // exists
        if let contentsOfFile = UIImage(contentsOfFile: fileInDocumentsDirectory(fileName: imageFileName)) {
            completion(contentsOfFile)
        } else {
            print("Coulnd't generate iamge")
            completion(nil)
        }
    } else {
        let downloadQueue = DispatchQueue(label: "imageDownloadQueue")
        downloadQueue.async {
            let data = NSData(contentsOf: imageURL! as URL)
            if data != nil {
                var docURL = getDocumentsUrl()
                docURL = docURL.appendingPathComponent(imageFileName, isDirectory: false)
                data!.write(to: docURL, atomically: true)
                let imageToReturn = UIImage(data: data! as Data)
                DispatchQueue.main.async {
                    completion(imageToReturn)
                }
            } else {
                DispatchQueue.main.async {
                    print("No image in database")
                    completion(nil)
                }
            }
        }
    }
}

func downloadVideo(videoUrl: String, completion: @escaping (_ usReadyToPlay: Bool,_ videoFileName: String) -> Void) {
    let videoURL = NSURL(string: videoUrl)
    let videoFileName = (videoUrl.components(separatedBy: "%").last!).components(separatedBy: "?").first!
    
    if fileExistsInDocumentsDir(filePath: videoFileName) {
        // exists
        completion(true, videoFileName)
    } else {
        let downloadQueue = DispatchQueue(label: "videoDownloadQueue")
        downloadQueue.async {
            let data = NSData(contentsOf: videoURL! as URL)
            if data != nil {
                var docURL = getDocumentsUrl()
                docURL = docURL.appendingPathComponent(videoFileName, isDirectory: false)
                data!.write(to: docURL, atomically: true)

                DispatchQueue.main.async {
                    completion(true, videoFileName)
                }
            } else {
                DispatchQueue.main.async {
                    print("No image in database")
                }
            }
        }
    }
}


func downloadAudio(audioUrl: String, completion: @escaping (_ audioFileName: String?) -> Void) {
    let audioURL = NSURL(string: audioUrl)
    let audioFileName = (audioUrl.components(separatedBy: "%").last!).components(separatedBy: "?").first!
    
    if fileExistsInDocumentsDir(filePath: audioFileName) {
        // exists
       completion(audioFileName)
    } else {
        let downloadQueue = DispatchQueue(label: "audioDownloadQueue")
        downloadQueue.async {
            let data = NSData(contentsOf: audioURL! as URL)
            if data != nil {
                var docURL = getDocumentsUrl()
                docURL = docURL.appendingPathComponent(audioFileName, isDirectory: false)
                data!.write(to: docURL, atomically: true)
                DispatchQueue.main.async {
                    completion(audioFileName)
                }
            } else {
                DispatchQueue.main.async {
                    print("No image in database")
                    completion(nil)
                }
            }
        }
    }
}
// MARK: upload for video msg

func uploadVideo(video: NSData, chatRoomId: String,view: UIView, completion: @escaping (_ videoLink:String?) -> Void){
    let progressHUD = MBProgressHUD.showAdded(to: view, animated: true)
    progressHUD.mode = .determinateHorizontalBar
    
    let dateString = dateFormatter().string(from: Date())
    let videoFileName = "VideoMessages/" + User.currentId() + "/" + chatRoomId + "/" + dateString + ".mov"
    let storageRef = storage.reference(forURL: kFILEREFERENCE).child(videoFileName)
    
    var task: StorageUploadTask!
    task = storageRef.putData(video as Data, metadata: nil, completion: { (metadata, error) in
        task.removeAllObservers()
        progressHUD.hide(animated: true)
        
        if error != nil {
            print("Error uploading video: \(error!.localizedDescription)")
            return
        }
        
        storageRef.downloadURL(completion: { (url, error) in
            guard let downloadUrl = url else {completion(nil)
                return
            }
            completion(downloadUrl.absoluteString)
        })
    })
    
    task.observe(StorageTaskStatus.progress) { (snapshot) in
        progressHUD.progress = Float((snapshot.progress?.completedUnitCount)!) / Float((snapshot.progress?.totalUnitCount)!)
    }
}

// MARK: Audio messages
func uploadAudio(audioPath: String, chatRoomId: String,view: UIView, completion: @escaping (_ audioLink:String?) -> Void){
    let progressHUD = MBProgressHUD.showAdded(to: view, animated: true)
    progressHUD.mode = .determinateHorizontalBar
    
    let dateString = dateFormatter().string(from: Date())
    let audioFileName = "AudioMessages/" + User.currentId() + "/" + chatRoomId + "/" + dateString + ".m4a"
    let storageRef = storage.reference(forURL: kFILEREFERENCE).child(audioFileName)
    let audio  = NSData(contentsOfFile: audioPath)
    var task: StorageUploadTask!
    task = storageRef.putData(audio! as Data, metadata: nil, completion: { (metadata, error) in
        task.removeAllObservers()
        progressHUD.hide(animated: true)
        
        if error != nil {
            print("Error uploading audio: \(error!.localizedDescription)")
            return
        }
        
        storageRef.downloadURL(completion: { (url, error) in
            guard let downloadUrl = url else {completion(nil)
                return
            }
            completion(downloadUrl.absoluteString)
        })
    })
    
    task.observe(StorageTaskStatus.progress) { (snapshot) in
        progressHUD.progress = Float((snapshot.progress?.completedUnitCount)!) / Float((snapshot.progress?.totalUnitCount)!)
    }
}

// Helpers

func videoThumbnail(video: NSURL) -> UIImage {
    let asset = AVURLAsset(url: video as URL, options: nil)
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform = true
    
    let time = CMTimeMakeWithSeconds(0.5, 1000)
    var actualTime = kCMTimeZero
    
    var image: CGImage?
    do {
        image = try imageGenerator.copyCGImage(at: time, actualTime: &actualTime)
    }
    catch let error as NSError {
        print(error.localizedDescription)
    }
    let thumbnail = UIImage(cgImage: image!)
    return thumbnail
}

func fileInDocumentsDirectory(fileName: String) -> String {
    let fileURL = getDocumentsUrl().appendingPathComponent(fileName)
    return fileURL.path
}

func getDocumentsUrl() -> URL {
    let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
    return documentURL!
}

func fileExistsInDocumentsDir(filePath: String) -> Bool {
    var doesExist = false
    let filepath = fileInDocumentsDirectory(fileName: filePath)
    let fileManager = FileManager.default
    if fileManager.fileExists(atPath: filepath) {
        doesExist = true
    } else {
        doesExist = false
    }
    return doesExist
}
