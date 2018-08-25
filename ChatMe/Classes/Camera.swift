//
//  Camera.swift
//  ChatMe
//
//  Created by Spas Belev on 20.08.18.
//  Copyright © 2018 Spas Belev. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices

class Camera {
    var delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate
    
    init(delegate_: UIImagePickerControllerDelegate & UINavigationControllerDelegate) {
        self.delegate = delegate_
    }
    
    func presentPhotoLibrary(target: UIViewController, canEdit: Bool) {
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) && !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum) {
            return
        }
        
        let type = kUTTypeImage as String
        let imagePicker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.sourceType = .photoLibrary
            if let availableTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) {
                if(availableTypes as NSArray).contains(type) {
                    // Set up defaults
                    imagePicker.mediaTypes = [type]
                    imagePicker.allowsEditing = canEdit
                }
            }
        } else if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            if let availableTypes = UIImagePickerController.availableMediaTypes(for: .savedPhotosAlbum) {
                if(availableTypes as NSArray).contains(type) {
                    // Set up defaults
                    imagePicker.mediaTypes = [type]
                }
            }
        } else {
            return
        }
        
        imagePicker.allowsEditing = canEdit
        imagePicker.delegate = delegate
        target.present(imagePicker, animated: true, completion: nil) // present image picker to user
        return
    }
    
    func presentMultyCamera(target: UIViewController, canEdit: Bool) {
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            return
        }
        
        let type1 = kUTTypeImage as String
        let type2 = kUTTypeMovie as String
        
        let imagePicker = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            if let availableTypes = UIImagePickerController.availableMediaTypes(for: .camera) {
                if(availableTypes as NSArray).contains(type1) {
                    // Set up defaults
                    imagePicker.mediaTypes = [type1, type2]
                    imagePicker.sourceType = UIImagePickerControllerSourceType.camera
                }
            }
            if UIImagePickerController.isCameraDeviceAvailable(.rear) {
                imagePicker.cameraDevice = UIImagePickerControllerCameraDevice.rear
            } else if UIImagePickerController.isCameraDeviceAvailable(.front){
            imagePicker.cameraDevice = UIImagePickerControllerCameraDevice.front
            }
        } else {
            // show alert
            return
        }
        
        imagePicker.allowsEditing = canEdit
        imagePicker.showsCameraControls = true
        imagePicker.delegate = delegate
        target.present(imagePicker, animated: true, completion: nil) // present image picker to user
        return
        
    }
    
    func presetnVideoCamera(target: UIViewController, canEdit: Bool) {
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            return
        }
        
        let type1 = kUTTypeMovie as String
        
        let imagePicker = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            if let availableTypes = UIImagePickerController.availableMediaTypes(for: .camera) {
                if(availableTypes as NSArray).contains(type1) {
                    // Set up defaults
                    imagePicker.mediaTypes = [type1]
                    imagePicker.sourceType = UIImagePickerControllerSourceType.camera
                    imagePicker.videoMaximumDuration = kMAXDURATION
                }
            }
            if UIImagePickerController.isCameraDeviceAvailable(.rear) {
                imagePicker.cameraDevice = UIImagePickerControllerCameraDevice.rear
            } else if UIImagePickerController.isCameraDeviceAvailable(.front){
                imagePicker.cameraDevice = UIImagePickerControllerCameraDevice.front
            }
        } else {
            // show alert
            return
        }
        
        imagePicker.allowsEditing = canEdit
        imagePicker.showsCameraControls = true
        imagePicker.delegate = delegate
        target.present(imagePicker, animated: true, completion: nil) // present image picker to user
        return
        
    }
    
    func presetnVideoLibrary(target: UIViewController, canEdit: Bool) {
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) && !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum) {
            return
        }
        
        let type1 = kUTTypeMovie as String
        
        let imagePicker = UIImagePickerController()
        imagePicker.videoMaximumDuration = kMAXDURATION
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            if let availableTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) {
                if(availableTypes as NSArray).contains(type1) {
                    // Set up defaults
                    imagePicker.mediaTypes = [type1]
                    imagePicker.allowsEditing = canEdit
                }
            }
        } else if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            if let availableTypes = UIImagePickerController.availableMediaTypes(for: .savedPhotosAlbum) {
                if(availableTypes as NSArray).contains(type1) {
                    // Set up defaults
                    imagePicker.mediaTypes = [type1]
                }
            }
        } else {
            return
        }
        
        imagePicker.allowsEditing = canEdit
        imagePicker.delegate = delegate
        target.present(imagePicker, animated: true, completion: nil) // present image picker to user
        return
        
    }
}
