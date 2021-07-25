//
//  User.swift
//  DormitoryForDelivery
//
//  Created by 김동현 on 2021/07/25.
//

import Foundation

enum Dormitory {
    case building1, building2, building3, building4, building5, building6, building7
}

struct User {
    // 가입자정보
    // 이름, 학번, 학교, 기숙사정보, 닉네임
    var name:String
    var studentNumber:Int
    let university:String = "창원대학교"
    var dormitory: Dormitory
    var nickName:String
}


