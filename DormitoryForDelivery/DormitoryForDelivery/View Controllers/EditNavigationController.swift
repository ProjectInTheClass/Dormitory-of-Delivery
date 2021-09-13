//
//  EditNavigationController.swift
//  DormitoryForDelivery
//
//  Created by 이태영 on 2021/09/13.
//

import UIKit

class EditNavigationController: UINavigationController {
    
    var editPost: RecruitingText?

    override func viewDidLoad() {
        super.viewDidLoad()
        print(editPost)
        if let rootViewController = viewControllers.first as? RecruitmenTableViewController {
            rootViewController.mainPostInformation = editPost
        }

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
