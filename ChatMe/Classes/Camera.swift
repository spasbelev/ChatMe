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
        
    }
}
