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
        
        if Auth.auth().currentUser?.uid != nil{
            performSegue(withIdentifier: "login", sender: self)
        }
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
                //ToDo: 로그인 성공 user객체에서 정보 사용
                self.performSegue(withIdentifier: "login", sender: self)
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
    
    @IBAction func unwindToLogInViewController(unwindSegue: UIStoryboardSegue){
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
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
