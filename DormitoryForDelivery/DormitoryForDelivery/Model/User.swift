//
//  User.swift
//  DormitoryForDelivery
//
//  Created by 김동현 on 2021/07/25.
//

import Foundation

struct User {
    // 가입자정보
    // 이름, 학번, 학교, 기숙사정보, 닉네임
    var name:String
    var studentNumber:Int
    let university:String = "창원대학교"
    var dormitory: SortOfDormitory
    var nickName:String
}


