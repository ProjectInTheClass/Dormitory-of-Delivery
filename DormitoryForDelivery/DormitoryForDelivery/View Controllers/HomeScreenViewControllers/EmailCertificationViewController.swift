//
//  EmailCertificationViewController.swift
//  DormitoryForDelivery
//
//  Created by 김동현 on 2021/09/06.
//

import UIKit
import FirebaseAuth

class EmailCertificationViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailCertificationButton: UIButton!
    @IBOutlet weak var checkButton: UIButton!
    
    var emailText:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailCertificationButton.layer.cornerRadius = 6
        checkButton.layer.cornerRadius = 6
        emailTextField.text = emailText
    }
    
    @IBAction func emailCertificationButtonTapped(_ sender: Any) {
        Auth.auth().currentUser?.sendEmailVerification() { (error) in
            if error == nil {
                let alertController = UIAlertController(title: "이메일로 인증 메세지가 발송되었습니다.", message: nil, preferredStyle: .alert)
                let checkAction = UIAlertAction(title: "확인", style: .default, handler: nil)
                alertController.addAction(checkAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func checkButtonTapped(_ sender: Any) {
        Auth.auth().currentUser?.reload { _ in
            if Auth.auth().currentUser?.isEmailVerified == true {
                let firebaseAuth = Auth.auth()
                do {
                  try firebaseAuth.signOut()
                } catch let signOutError as NSError {
                  print("Error signing out: %@", signOutError)
                }
                
                self.dismiss(animated: true, completion: nil)

            } else {
                let alertController = UIAlertController(title: "이메일인증을 해주세요.", message: nil, preferredStyle: .alert)
                let checkAction = UIAlertAction(title: "확인", style: .default, handler: nil)
                alertController.addAction(checkAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
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
