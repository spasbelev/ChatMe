//
//  CollectionReference.swift
//  ChatMe
//
//  Created by Spas Belev on 12.08.18.
//  Copyright © 2018 Spas Belev. All rights reserved.
//

import Foundation
import FirebaseFirestore


enum FCollectionReference: String {
    case User
    case Typing
    case Recent
    case Message
    case Group
    case Call
}


func reference(_ collectionReference: FCollectionReference) -> CollectionReference{
    return Firestore.firestore().collection(collectionReference.rawValue)
}
