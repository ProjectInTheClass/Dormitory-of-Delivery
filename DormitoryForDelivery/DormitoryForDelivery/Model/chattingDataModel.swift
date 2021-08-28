//
//  chattingDataModel.swift
//  DormitoryForDelivery
//
//  Created by 김동현 on 2021/08/22.
//

import Foundation

struct ChatMessage {
    var fromUserId: String
    var text: String
    var timestamp: NSNumber
}

struct Group {
    var key: String
    var name: String
    var messages: Dictionary<String, Int>
    
    init(key: String, name: String) {
        self.key = key
        self.name = name
        self.messages = [:]
    }
    
    init(key: String, data: Dictionary<String, AnyObject>) {
        self.key = key
        self.name = data["name"] as! String
        if let messages = data["messages"] as? Dictionary<String, Int> {
            self.messages = messages
        } else {
            self.messages = [:]
        }
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
    var school: School?
    var nickName: String?
    var reputation: Double?
    
    init(uid:String, email: String, password: String) {
        self.email = email
        self.password = password
        self.uid = uid
        self.group = [:]
    }
}


