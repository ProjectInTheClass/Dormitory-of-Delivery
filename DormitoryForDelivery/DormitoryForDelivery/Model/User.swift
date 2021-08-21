//
//  User.swift
//  DormitoryForDelivery
//
//  Created by 김동현 on 2021/07/25.
//

import Foundation

struct User {
    let uid: String
    var email: String
    var passWord: String
    var schoolCertificationStatus: Bool?
    
    //To do. 변수들의 사용용도에 맞게 옵셔널 처리 생각
    var name:String?
    var studentNumber:Int?
    
    var UserSchool: School?
    var nickName:String?
    var reputation: Double?
    
    init(uid:String, email:String, password:String){
        self.email = email
        self.passWord = password
        self.uid = uid
    }
}


