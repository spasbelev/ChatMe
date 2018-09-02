//
//  Encryption.swift
//  ChatMe
//
//  Created by Spas Belev on 2.09.18.
//  Copyright © 2018 Spas Belev. All rights reserved.
//

import Foundation
import RNCryptor


class Encryption {
    
    class func encryptText(chatRoomId: String, message: String) -> String {
        
        let data = message.data(using: String.Encoding.utf8)
        let encryptedData = RNCryptor.encrypt(data: data!, withPassword: chatRoomId)
        
        return encryptedData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
    }
    
    class func decryptText(chatRoomId: String, encryptedMessage: String) -> String {
        
        let decryptor = RNCryptor.Decryptor(password: chatRoomId)
        
        let encryptedData = NSData(base64Encoded: encryptedMessage, options: NSData.Base64DecodingOptions(rawValue: 0))
        
        var message: NSString = ""
        
        if encryptedData != nil {
            do {
                let decryptedData = try decryptor.decrypt(data: encryptedData! as Data)
                message = NSString(data: decryptedData, encoding: String.Encoding.utf8.rawValue)!
            } catch {
                print("error decrypting text \(error.localizedDescription)")
            }
        }
        
        return message as String
    }
    
    
    
}
