//
//  ResetPasswordViewController.swift
//  DormitoryForDelivery
//
//  Created by 김덕환 on 2022/02/26.
//

import UIKit
import Firebase


class ResetPasswordViewController: UIViewController {

    @IBOutlet weak var DetailsLabel: UILabel!
    @IBOutlet weak var SendButton: UIButton!
    @IBOutlet weak var Label: UILabel!
    @IBOutlet weak var EmInput: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        SendButton.layer.cornerRadius = 6
        navigationColor()
        // Do any additional setup after loading the view.
    }
    

    func navigationColor() {
            navigationController?.navigationBar.tintColor = UIColor.white
        }
    @IBAction func SendEm(_ sender: Any) {
        let auth = Auth.auth()
        
        auth.sendPasswordReset(withEmail: EmInput.text!) { (error) in
            if error != nil{
                let alert = Service.createAlertController(title: "경고", message: "존재하지 않는 이메일 입니다.")
                self.present(alert, animated: true, completion: nil)
                return
            }
            let alert = Service.createAlertController(title: "확인", message: "이 이메일로 확인 메일을 전송하였습니다.")
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}
