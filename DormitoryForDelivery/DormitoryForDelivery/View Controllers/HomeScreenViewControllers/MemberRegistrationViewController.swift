//
//  MemberRegistrationViewController.swift
//  DormitoryForDelivery
//
//  Created by 김동현 on 2021/08/15.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class MemberRegistrationViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate {
  
    let db:Firestore = Firestore.firestore()
    
    @IBOutlet weak var emailTextField: UITextField!{ didSet {
        emailTextField.delegate = self
    }}
    @IBOutlet weak var passwordTextField: UITextField! { didSet {
        passwordTextField.delegate = self
    }}
    @IBOutlet weak var checkPasswordTextField: UITextField! { didSet {
        checkPasswordTextField.delegate = self
    }}
    @IBOutlet weak var studentNumberTextField: UITextField! { didSet {
        studentNumberTextField.delegate = self
    }}
    @IBOutlet weak var userNameTextField: UITextField! { didSet {
        userNameTextField.delegate = self
    }}
    @IBOutlet weak var memberRegistrationButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    var contentViewheight: CGFloat?
    
    @IBAction func emailTextDidChanged(_ sender: Any) {
        checkMaxLength(textField: emailTextField, maxLength: 25)
    }
    @IBAction func contentViewTapped(_ sender: Any) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        checkPasswordTextField.resignFirstResponder()
        studentNumberTextField.resignFirstResponder()
        userNameTextField.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationUI()
        memberRegistrationButton.layer.cornerRadius = 6
        scrollView.delegate = self
        contentViewheight = contentView.frame.height
        try! Auth.auth().signOut()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    @IBAction func memberRegistrationButtonTapped(_ sender: Any) {
        let password = passwordTextField.text!
        let email = emailTextField.text! + "@gs.cwnu.ac.kr" //20165157@gs.cwnu.ac.kr
        let studentNumber = studentNumberTextField.text!
        let userName = userNameTextField.text!
        let userID = emailTextField.text! + " " + userName
        let newUser = ["email":email, "studentNumber":studentNumber, "userName":userName, "userID":userID]
        
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
        
        guard userNameTextField.text?.isEmpty == false, studentNumberTextField.text?.isEmpty == false else {
            let alertController = UIAlertController(title: "학번과 이름을 작성해주세요", message: nil, preferredStyle: .alert)
            let checkAction = UIAlertAction(title: "확인", style: .default, handler: nil)
            alertController.addAction(checkAction)
            present(alertController, animated: true, completion: nil)
            return
        }
        
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { (snapshot: QuerySnapshot?, error) in
            // 중복된 이메일이 없을경우
            if snapshot!.documents.count == 0 {
                Auth.auth().createUser(withEmail: email, password: password, completion: { (snapshot,error) in
                    // 이메일과 비밀번호로 계정을 생성한후 오류가 없을시 데이터베이스에 정보도 입력
                    if error == nil {
                        self.db.collection("users").document(Auth.auth().currentUser!.uid).setData(newUser)
                        FirebaseDataService.instance.userRef.child(Auth.auth().currentUser!.uid).child("userID").setValue(userID)
                        
                        self.performSegue(withIdentifier: "emailCertification", sender: nil)
                    // 계정생성시 오류발생
                    } else {
                        let alertController = UIAlertController(title: "이메일 형식이 올바르지 않습니다.", message: nil, preferredStyle: .alert)
                        let checkAction = UIAlertAction(title: "확인", style: .default, handler: nil)
                        alertController.addAction(checkAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                })
            // 중복된 이메일이 존재할 경우  OR  이메일인증화면에서 뒤로왔을 경우
            } else {
                guard let uid = Auth.auth().currentUser?.uid else {
                    //중복된 이메일이 존재할경우
                    let alertController = UIAlertController(title: "이미 존재하는 이메일입니다.", message: nil, preferredStyle: .alert)
                    let checkAction = UIAlertAction(title: "확인", style: .default, handler: nil)
                    alertController.addAction(checkAction)
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
                // 이메일인증화면에서 뒤로왔을 경우
                let ref = self.db.collection("users").document(uid)
                ref.getDocument { (document, error) in
                    guard let document = document else { return }
                    let value = document.data()!["email"] as! String
                    if value == email {
                        self.performSegue(withIdentifier: "emailCertification", sender: nil)
                    }
                }
            }
        }
    }
    
    @IBAction func dismissButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        checkPasswordTextField.resignFirstResponder()
        studentNumberTextField.resignFirstResponder()
        userNameTextField.resignFirstResponder()
        return true
    }
    
    // MARK: - KEYBOARD notification
    
    @objc func keyboardWillShow(_ notification: Notification) {
        let height = getKeyboardHeight(notification)
        
        view.frame.origin.y = -height
        scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: self.contentViewheight!)
        scrollView.contentInset.top = height
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
        scrollView.contentInset.top = 0
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func checkMaxLength(textField: UITextField!, maxLength: Int) {
        if (textField.text?.count ?? 0 > maxLength) {
                textField.deleteBackward()
            }
    }
    
    private func navigationUI() {
        navigationController?.navigationBar.tintColor = .white
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "emailCertification" {
            let destinationViewController = segue.destination as? EmailCertificationViewController
            destinationViewController?.emailText = emailTextField.text! + "@gs.cwnu.ac.kr"
        }
    }
}
