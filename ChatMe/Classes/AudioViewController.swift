//
//  AudioViewController.swift
//  ChatMe
//
//  Created by Spas Belev on 25.08.18.
//  Copyright © 2018 Spas Belev. All rights reserved.
//

import Foundation
import IQAudioRecorderController

class AudioViewController {
    var delegate: IQAudioRecorderViewControllerDelegate
    
    init(withDelegate: IQAudioRecorderViewControllerDelegate) {
        self.delegate = withDelegate
    }
    
    func presentAudioRecorder(target: UIViewController) {
        let controller = IQAudioRecorderViewController()
        controller.delegate = delegate
        controller.title = "Record"
        controller.maximumRecordDuration = kMAXDURATION
        controller.allowCropping = true
        
        target.presentBlurredAudioRecorderViewControllerAnimated(controller)
    }
}
