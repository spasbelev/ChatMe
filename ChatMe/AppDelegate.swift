//
//  AppDelegate.swift
//  ChatMe
//
//  Created by Spas Belev on 11.08.18.
//  Copyright © 2018 Spas Belev. All rights reserved.
//

import UIKit
import Firebase
import OneSignal
import PushKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, SINClientDelegate, SINCallClientDelegate, SINManagedPushDelegate, PKPushRegistryDelegate {
    
    
    var window: UIWindow?
    var authListener: AuthStateDidChangeListenerHandle?
    var _client: SINClient!
    var push: SINManagedPush!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        // Autologin
        authListener = Auth.auth().addStateDidChangeListener({ (auth, user) in
            Auth.auth().removeStateDidChangeListener(self.authListener!)
            
            if user != nil {
                if UserDefaults.standard.object(forKey: kCURRENTUSER) != nil {
                    DispatchQueue.main.async {
                        self.goToApplication()
                    }
                }
            }
        })
        self.voipRegistration()
        
        self.push = Sinch.managedPush(with: .development)
        self.push.delegate = self
        self.push.setDesiredPushTypeAutomatically()
        
        func userDidLogin(userId: String) {
            self.push.registerUserNotificationSettings()
            self.initSinchWithUserId(userId: userId)
            self.startOneSignal()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(USER_DID_LOGIN_NOTIFICATION), object: nil, queue: nil) { (notification) in
            let userId = notification.userInfo![kUSERID] as! String
            UserDefaults.standard.set(userId, forKey: kUSERID)
            UserDefaults.standard.synchronize()
            userDidLogin(userId: userId)
        }
        
        OneSignal.initWithLaunchOptions(launchOptions, appId: kONESIGNALAPPID)
        
        // Override point for customization after application launch.
        return true
    }
    

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        recentBadgeHandler?.remove()
        if User.currentUser() != nil {
            updateCurrentUserInFirestore(withValues: [kISONLINE: false]) { (success) in
                
            }
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        var top = self.window?.rootViewController
        
        while top?.presentedViewController != nil {
            top = top?.presentedViewController
        }
        
        if top! is UITabBarController {
            setBadges(controller: top as! UITabBarController)
        }
        
        if User.currentUser() != nil {
            updateCurrentUserInFirestore(withValues: [kISONLINE: true]) { (success) in
                
            }
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        if User.currentUser() != nil {
            updateCurrentUserInFirestore(withValues: [kISONLINE: false]) { (success) in
                
            }
        }
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    func goToApplication() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo: [kUSERID: User.currentId()])
        
        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainApplication") as! UITabBarController
        
        self.window?.rootViewController = mainView
    }
    
    // MARK: OneSignal
    func startOneSignal() {
        let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
        let userId = status.subscriptionStatus.userId
        let pushToken = status.subscriptionStatus.pushToken
        
        if pushToken != nil {
            if let playerID = userId {
                UserDefaults.standard.set(playerID, forKey: kPUSHID)
            } else {
                UserDefaults.standard.removeObject(forKey: kPUSHID)
            }
            UserDefaults.standard.synchronize()
        }
        // Update OnesignalID
        updateOneSignalId()
        
        
    }
    
    // MARK: Push notification delegates
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        self.push.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let firebaseAuth = Auth.auth()
        if firebaseAuth.canHandleNotification(userInfo) {
            return
        } else {
            self.push.application(application, didReceiveRemoteNotification: userInfo)
        }
    }
    
    
    // MARK: Sinch
    
    func initSinchWithUserId(userId: String) {
        if _client == nil {
            _client = Sinch.client(withApplicationKey: kSINCHKEY, applicationSecret: kSINCHSECRET, environmentHost: "sandbox.sinch.com" , userId: userId)
            _client.delegate = self
            _client.call()?.delegate = self
            _client.setSupportCalling(true)
            _client.enableManagedPushNotifications()
            _client.start()
            _client.startListeningOnActiveConnection()
        }
    }
    
    func managedPush(_ managedPush: SINManagedPush!, didReceiveIncomingPushWithPayload payload: [AnyHashable : Any]!, forType pushType: String!) {
        let result = SINPushHelper.queryPushNotificationPayload(payload)
        
        if result!.isCall() {
            print("Incoming push payload")
            self.handleRemetoNotifications(userInfo: payload as NSDictionary)
        }
    }
    
    func handleRemetoNotifications(userInfo: NSDictionary) {
        if _client == nil {
            let userId = UserDefaults.standard.object(forKey: kUSERID)
            
            if userId != nil {
                self.initSinchWithUserId(userId: userId as! String)
            }
        }
        
        let result = self._client.relayRemotePushNotification(userInfo as! [AnyHashable : Any])
        if result!.isCall() {
            print("Handle call notification")
        }
        
        if result!.isCall() && result!.call().isCallCanceled {
            self.presentMissedCallNotificationWithRemoteUserId(userId: result!.call().callId)
        }
    }
    
    func presentMissedCallNotificationWithRemoteUserId(userId: String) {
        
        if UIApplication.shared.applicationState == .background {
            let center = UNUserNotificationCenter.current()
            let content = UNMutableNotificationContent()
            content.title = "Missed Call"
            content.body = "From \(userId)"
            content.sound = UNNotificationSound.default()
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            
            let request = UNNotificationRequest(identifier: "ContentIdentifier", content: content, trigger: trigger)
            center.add(request) { (error) in
                if error != nil {
                    print(error!.localizedDescription)
                }
            }
        }
    }
    
    // MARK: SinchCallCleintDelegate
    func client(_ client: SINCallClient!, willReceiveIncomingCall call: SINCall!) {
        print("will receive incoming call")
    }
    
    func client(_ client: SINCallClient!, didReceiveIncomingCall call: SINCall!) {
        print("did receive incoming call")
        
        // present Call View
        var top = self.window?.rootViewController
        
        while(top?.presentedViewController != nil ) {
            top = top?.presentedViewController
        }
        
        let callVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CallVC") as! CallViewController
        callVC._call = call
        top?.present(callVC, animated: true, completion: nil)
        
    }
    
    // MARK: SyncClientDelegate
    
    func clientDidStart(_ client: SINClient!) {
        print("Sinch did start")
    }
    
    func clientDidStop(_ client: SINClient!) {
        print("Sinch did stop")
    }
    
    func clientDidFail(_ client: SINClient!, error: Error!) {
        print("Sinch did fail \(error!.localizedDescription)")

    }
    
    func voipRegistration() {
        let voipRegistry: PKPushRegistry = PKPushRegistry(queue: DispatchQueue.main)
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [PKPushType.voIP]
    }
    
    // MARK: PKPushDelegate
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {
        print("Did get incoming push")
        self.handleRemetoNotifications(userInfo: payload.dictionaryPayload as NSDictionary)
    }
    
}

