//
//  LogInViewController.swift
//  DormitoryForDelivery
//
//  Created by 서인규 on 2021/08/03.
//

import UIKit
import FirebaseAuth

class LogInViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField! { didSet{
        emailTextField.delegate = self
    }}
    
    @IBOutlet weak var passwordTextField: UITextField! { didSet{
        passwordTextField.delegate = self
    }}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        
        
    }
    
    @IBAction func logInButtonTapped(_ sender: Any) {
        guard emailTextField.text?.isEmpty == false else {
            let alertController = UIAlertController(title: "이메일을 작성해주세요.", message: nil, preferredStyle: .alert)
            let checkAction = UIAlertAction(title: "확인", style: .default, handler: nil)
            alertController.addAction(checkAction)
            present(alertController, animated: true, completion: nil)
            return
        }
        
        guard passwordTextField.text?.isEmpty == false else {
            let alertController = UIAlertController(title: "비밀번호를 작성해주세요.", message: nil, preferredStyle: .alert)
            let checkAction = UIAlertAction(title: "확인", style: .default, handler: nil)
            alertController.addAction(checkAction)
            present(alertController, animated: true, completion: nil)
            return
        }
        
        
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
       
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error == nil{
                if Auth.auth().currentUser?.isEmailVerified == true {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    
                    let alertController = UIAlertController(title: "해당 이메일은 이메일 인증을 하지 않았습니다.", message: nil, preferredStyle: .alert)
                    let checkAction = UIAlertAction(title: "인증하기", style: .default) { (action) in
                        self.performSegue(withIdentifier: "doEmailCertification", sender: nil)
                    }
                    alertController.addAction(checkAction)
                    self.present(alertController, animated: true, completion: nil)
                }
                
            } else {
                //ToDo: 로그인 실패 처리
                let alertController = UIAlertController(title: "이메일과 비밀번호가 올바르지 않습니다.", message: nil, preferredStyle: .alert)
                let checkAction = UIAlertAction(title: "확인", style: .default, handler: nil)
                alertController.addAction(checkAction)
                self.present(alertController, animated: true, completion: nil)
                return
            }
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "doEmailCertification" {
            let destinationViewController = segue.destination as? EmailCertificationViewController
            destinationViewController?.emailText = emailTextField.text
        }
    }
    
}
