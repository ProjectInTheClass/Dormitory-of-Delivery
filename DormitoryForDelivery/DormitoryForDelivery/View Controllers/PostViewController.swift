//
//  PostViewController.swift
//  DormitoryForDelivery
//
//  Created by 이태영 on 2021/08/15.
//

import UIKit

class PostViewController: UIViewController {
    
    var mainPostInformation: RecruitingText?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 네비게이션바 디자인 설정
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        

        // Do any additional setup after loading the view.
    }
    


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(mainPostInformation)
        if segue.identifier == "sendPostInformation" {
            let destinationViewController = segue.destination as? PostTableViewController
            destinationViewController?.mainPostInformation = self.mainPostInformation
        }
    }


}
