//
//  FirebaseDataService.swift
//  DormitoryForDelivery
//
//  Created by 김동현 on 2021/08/22.
//

// 파이어베이스와 연동을 위한 싱글턴 클래스


import Foundation
import Firebase

fileprivate let baseRef = Database.database().reference()

class FirebaseDataService {
    static let instance = FirebaseDataService()
    
    let userRef = baseRef.child("user")
    
    let groupRef = baseRef.child("group")
    
    let messageRef = baseRef.child("message")
    
    var currentUserUid: String?{
        get{
            guard let uid = Auth.auth().currentUser?.uid else {
                return nil
            }
            return uid
        }
    }
    
    
}
