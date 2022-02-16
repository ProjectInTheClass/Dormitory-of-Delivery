//
//  UserDefaultsExtension.swift
//  DormitoryForDelivery
//
//  Created by 김덕환 on 2022/02/16.
//

import Foundation

extension UserDefaults {
    private enum UserDefaultsKeys: String{
        case hasTutorial
    }
    
    var hasTutorial: Bool{
        get{
            bool(forKey: UserDefaultsKeys.hasTutorial.rawValue)
        }
        set{
            setValue(newValue, forKey: UserDefaultsKeys.hasTutorial.rawValue)
        }
    }
}
