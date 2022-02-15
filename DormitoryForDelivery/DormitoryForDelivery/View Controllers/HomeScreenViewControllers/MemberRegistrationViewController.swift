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
    
    let db:Firestore = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationUI()
        
        }
    
    @IBAction func memberRegistrationButtonTapped(_ sender: Any) {
        let password = passwordTextField.text!
        let email = emailTextField.text!
        let newUser = ["email":email]
        
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
        
//        guard Auth.auth().currentUser != nil else {
//            let alertController = UIAlertController(title: "이메일인증을 해주세요.", message: nil, preferredStyle: .alert)
//            let checkAction = UIAlertAction(title: "확인", style: .default, handler: nil)
//            alertController.addAction(checkAction)
//            self.present(alertController, animated: true, completion: nil)
//            return
//        }
        
        
        db.collection("users").whereField("email", isEqualTo: emailTextField.text!).getDocuments { (snapshot: QuerySnapshot?, error) in
            if snapshot!.documents.count == 0 {
                Auth.auth().createUser(withEmail: email, password: password, completion: { (snapshot,error) in
                    if error == nil {
                        self.db.collection("users").document(Auth.auth().currentUser!.uid).setData(newUser)
                        
                        if let uid = FirebaseDataService.instance.currentUserUid {
                            FirebaseDataService.instance.userRef.child(uid).child("email").setValue(email)
                        }
                        self.performSegue(withIdentifier: "emailCertification", sender: nil)
                        
                    } else {
                        let alertController = UIAlertController(title: "이메일 형식이 올바르지 않습니다.", message: nil, preferredStyle: .alert)
                        let checkAction = UIAlertAction(title: "확인", style: .default, handler: nil)
                        alertController.addAction(checkAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                })
            } else {
                let alertController = UIAlertController(title: "이미 존재하는 이메일입니다.", message: nil, preferredStyle: .alert)
                let checkAction = UIAlertAction(title: "확인", style: .default, handler: nil)
                alertController.addAction(checkAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    
    @IBAction func dismissButtonTapped(_ sender: Any) {
        //Auth.auth().currentUser?.delete()
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
    
    func navigationUI() {
        navigationController?.navigationBar.tintColor = .white
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "emailCertification" {
            let destinationViewController = segue.destination as? EmailCertificationViewController
            destinationViewController?.emailText = emailTextField.text
        }
    }
    

}
