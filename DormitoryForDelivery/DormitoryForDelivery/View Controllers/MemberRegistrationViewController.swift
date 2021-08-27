//
//  MemberRegistrationViewController.swift
//  DormitoryForDelivery
//
//  Created by 김동현 on 2021/08/15.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class MemberRegistrationViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!{ didSet {
        emailTextField.delegate = self
    }}
    @IBOutlet weak var passwordTextField: UITextField! { didSet {
        passwordTextField.delegate = self
    }}
    @IBOutlet weak var checkPasswordTextField: UITextField! { didSet {
        checkPasswordTextField.delegate = self
    }}
    @IBOutlet weak var memberRegistrationButton: UIButton!
    @IBOutlet weak var emailCertificationStateLabel: UILabel!
    
    let db:Firestore = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        emailCertificationStateLabel.isHidden = true
    }
    
    @IBAction func didTapEmailCertification(_ sender: Any) {
        let email = emailTextField.text!
        
        
        //ToDo: 버튼을 누르면 코드상 회원가입부터된다. 따라서 이메일만 인증 누르고 앱의 실행을 중단했을때. 현재 생성된 계정을 삭제시킬 방법 생각하기.
        
        db.collection("users").whereField("email", isEqualTo: emailTextField.text!).getDocuments { (snapshot: QuerySnapshot?, error) in
            if snapshot!.documents.count == 0 {
                Auth.auth().createUser(withEmail: email, password: "password") { (user, error) in
                    if error == nil {
                        Auth.auth().currentUser?.sendEmailVerification()
                        let alertController = UIAlertController(title: "이메일에 메세지가 발송되었습니다.", message: nil, preferredStyle: .alert)
                        let checkAction = UIAlertAction(title: "확인", style: .default, handler: nil)
                        alertController.addAction(checkAction)
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        let alertController = UIAlertController(title: "이메일 형식이 옳지않습니다.", message: nil, preferredStyle: .alert)
                        let checkAction = UIAlertAction(title: "확인", style: .default, handler: nil)
                        alertController.addAction(checkAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            } else {
                let alertController = UIAlertController(title: "이미 존재하는 이메일입니다.", message: nil, preferredStyle: .alert)
                let checkAction = UIAlertAction(title: "확인", style: .default, handler: nil)
                alertController.addAction(checkAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    
    @IBAction func memberRegistrationButtonTapped(_ sender: Any) {
        guard emailTextField.text?.isEmpty == false, passwordTextField.text?.isEmpty == false, checkPasswordTextField.text?.isEmpty == false else {
            let alertController = UIAlertController(title: "이메일과 비밀번호를 작성해주세요.", message: nil, preferredStyle: .alert)
            let checkAction = UIAlertAction(title: "확인", style: .default, handler: nil)
            alertController.addAction(checkAction)
            present(alertController, animated: true, completion: nil)
            return
        }
        
        guard passwordTextField.text == checkPasswordTextField.text else {
            let alertController = UIAlertController(title: "비밀번호가 일치하지 않습니다.", message: nil, preferredStyle: .alert)
            let checkAction = UIAlertAction(title: "확인", style: .default, handler: nil)
            alertController.addAction(checkAction)
            present(alertController, animated: true, completion: nil)
            return
        }
        
        guard Auth.auth().currentUser != nil else {
            let alertController = UIAlertController(title: "이메일인증을 해주세요.", message: nil, preferredStyle: .alert)
            let checkAction = UIAlertAction(title: "확인", style: .default, handler: nil)
            alertController.addAction(checkAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        let password = passwordTextField.text!
        let email = emailTextField.text!
        
        Auth.auth().currentUser?.reload { _ in
            if Auth.auth().currentUser?.isEmailVerified == true {
                Auth.auth().currentUser?.updatePassword(to: password, completion: nil)
                
                let newUser = ["email":email, "password":password]
                self.db.collection("users").document(Auth.auth().currentUser!.uid).setData(newUser) { _ in
                    
                    if let uid = FirebaseDataService.instance.currentUserUid {
                        FirebaseDataService.instance.userRef.child(uid).child("email").setValue(email)
                    }
                    
                    let firebaseAuth = Auth.auth()
                    do {
                      try firebaseAuth.signOut()
                    } catch let signOutError as NSError {
                      print("Error signing out: %@", signOutError)
                    }
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
    
    
    @IBAction func dismissButtonTapped(_ sender: Any) {
        Auth.auth().currentUser?.delete()
        dismiss(animated: true, completion: nil)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        checkPasswordTextField.resignFirstResponder()
        return true
    }
    
    //ToDo: 이메일인증 후 화면에 다시 들어올 때 작동해야함.
    func updateUI(){
        Auth.auth().currentUser?.reload() { _ in
            if Auth.auth().currentUser?.isEmailVerified == true{
                self.emailCertificationStateLabel.isHidden = false
            } else {
                self.emailCertificationStateLabel.isHidden = true
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
