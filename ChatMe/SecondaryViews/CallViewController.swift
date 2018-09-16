//
//  CallViewController.swift
//  ChatMe
//
//  Created by Spas Belev on 15.09.18.
//  Copyright © 2018 Spas Belev. All rights reserved.
//

import UIKit

class CallViewController: UIViewController, SINCallDelegate {

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var speakerButton: UIButton!
    @IBOutlet weak var answerButtonOutlet: UIButton!
    @IBOutlet weak var endCallButtonOutlet: UIButton!
    @IBOutlet weak var declineButtonOutlet: UIButton!
    
    var speaker = false
    var mute = false
    var durationTimer: Timer! = nil
    var _call: SINCall!
    var callAnswered = false
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewWillAppear(_ animated: Bool) {
        userNameLabel.text = "Unknown"
        let id = _call.remoteUserId
        getUsersFromFirestore(withIds: [id!]) { (allUsers) in
            if allUsers.count > 0 {
                let user = allUsers.first!
                self.userNameLabel.text = user.fullname
                imageFromData(pictureData: user.avatar, withBlock: { (image) in
                    if image != nil {
                        self.avatarImageView.image = image!.circleMasked
                    }
                })
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        _call.delegate = self
        if _call.direction == SINCallDirection.incoming {
            callAnswered = false
            showButtons()
            audioController().startPlayingSoundFile(pathForSound(soundName: "incoming"), loop: true)
        } else {
            callAnswered = true
            setCallStatus(text: "Calling...")
            showButtons()
        }
    }
    
    func audioController() -> SINAudioController {
        return appDelegate._client.audioController()
    }
    
    func setCall(call: SINCall) {
        _call = call
        _call.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: IBActions
    
    @IBAction func muteButtonPressed(_ sender: Any) {
        if mute {
            mute = false
            audioController().unmute()
            muteButton.setImage(UIImage(named: "mute"), for: .normal)
        } else {
            mute = true
            audioController().mute()
            muteButton.setImage(UIImage(named: "muteSelected"), for: .normal)
        }
    }
    
    @IBAction func speakerButtonPressed(_ sender: Any) {
        if !speaker {
            speaker = true
            audioController().enableSpeaker()
            speakerButton.setImage(UIImage(named: "speakerSelected"), for: .normal)
        } else {
            speaker = false
            audioController().disableSpeaker()
            speakerButton.setImage(UIImage(named: "speaker"), for: .normal)
        }
    }
    
    @IBAction func answerButtonPressed(_ sender: Any) {
        callAnswered = true
        showButtons()
        audioController().stopPlayingSoundFile()
        _call.answer()
    }
    
    @IBAction func hangupButtonPressed(_ sender: Any) {
        _call.hangup()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func declineButtonPressed(_ sender: Any) {
        _call.hangup()
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: SinCall Delegates
    func callDidProgress(_ call: SINCall!) {
        setCallStatus(text: "Ringing...")
        audioController().startPlayingSoundFile(pathForSound(soundName: "ringback"), loop: true)
    }
    
    func callDidEstablish(_ call: SINCall!) {
        startCallDurationTimer()
        showButtons()
        audioController().stopPlayingSoundFile()
    }
    
    func callDidEnd(_ call: SINCall!) {
        audioController().stopPlayingSoundFile()
        stopCallDuration()
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Timer
    @objc func onDuration() {
        let duration = Date().timeIntervalSince(_call.details.establishedTime)
        updateTimerLabel(seconds: Int(duration))
    }
    
    func updateTimerLabel(seconds: Int) {
        let min = String(format: "%02d", seconds / 60)
        let sec = String(format: "%02d", seconds % 60)
        setCallStatus(text: "\(min) : \(sec) ")
    }
    
    func startCallDurationTimer() {
        self.durationTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.onDuration), userInfo: nil, repeats: true)
    }
    
    func stopCallDuration() {
        if durationTimer != nil {
            durationTimer.invalidate()
            durationTimer = nil
        }
    }
    
    
    // MARK: Update UI
    func setCallStatus(text: String) {
        statusLabel.text = text
    }
    
    func showButtons() {
        if callAnswered {
            declineButtonOutlet.isHidden = true
            endCallButtonOutlet.isHidden = false
            answerButtonOutlet.isHidden = true
            muteButton.isHidden = false
            speakerButton.isHidden = false
        } else {
            declineButtonOutlet.isHidden = false
            endCallButtonOutlet.isHidden = true
            answerButtonOutlet.isHidden = false
            muteButton.isHidden = true
            speakerButton.isHidden = true
        }
    }
    
    // MARK: Helpers
    func pathForSound(soundName: String) -> String {
        return Bundle.main.path(forResource: soundName, ofType: "wav")!
    }
}
