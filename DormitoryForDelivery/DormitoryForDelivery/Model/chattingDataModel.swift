//
//  chattingDataModel.swift
//  DormitoryForDelivery
//
//  Created by 김동현 on 2021/08/22.
//

import Foundation

struct ChatMessage {
    var fromUserId: String
    var userID: String
    var text: String
    var timestamp: NSNumber
}

struct Group {
    var key: String
    var name: String
    var currentNumber: Int
    var lastMessage: String
    
    init(key: String, data: Dictionary<String, AnyObject>) {
        self.key = key
        self.name = data["name"] as! String
        self.currentNumber = data["currentNumber"] as! Int
        self.lastMessage = data["lastMessage"] as! String
        }
    }

struct User {
    var uid: String
    var email: String
    var password: String
    var group: Dictionary<String, Int>
    var schoolCertificationStatus: Bool?
    
    var name:String?
    var studentNumber:Int?
    var nickName: String?
    var reputation: Double?
    
    init(uid:String, email: String, password: String) {
        self.email = email
        self.password = password
        self.uid = uid
        self.group = [:]
    }
}


