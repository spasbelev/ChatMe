//
//  PhotoMedia.swift
//  ChatMe
//
//  Created by Spas Belev on 22.08.18.
//  Copyright © 2018 Spas Belev. All rights reserved.
//

import Foundation
import JSQMessagesViewController


class PhotoMediaItem: JSQPhotoMediaItem {
    override func mediaViewDisplaySize() -> CGSize {
        let defaultSize:CGFloat = 256
        var thumbSize: CGSize = CGSize(width: defaultSize, height: defaultSize)
        if self.image != nil && self.image.size.height > 0 && self.image.size.width > 0 {
            let aspectRatio:CGFloat = self.image.size.width / self.image.size.height
            
            if self.image.size.width > self.image.size.height {
                thumbSize = CGSize(width: defaultSize, height: defaultSize / aspectRatio)
            } else {
                thumbSize = CGSize(width: defaultSize * aspectRatio, height: defaultSize)
            }
        }
        return thumbSize
    }
}
