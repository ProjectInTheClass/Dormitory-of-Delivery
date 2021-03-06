//
//  MemberRegistrationViewController.swift
//  DormitoryForDelivery
//
//  Created by κΉλν on 2021/08/15.
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
        let userID = studentNumberTextField.text! + " " + userName
        let newUser = ["email" : email, "studentNumber" : studentNumber, "userName" : userName, "userID" : userID, "AgreetoTermsofUse" : "true"]
        
        guard emailTextField.text?.isEmpty == false, passwordTextField.text?.isEmpty == false, checkPasswordTextField.text?.isEmpty == false else {
            let alertController = UIAlertController(title: "μ΄λ©μΌκ³Ό λΉλ°λ²νΈλ₯Ό μμ±ν΄μ£ΌμΈμ.", message: nil, preferredStyle: .alert)
            let checkAction = UIAlertAction(title: "νμΈ", style: .default, handler: nil)
            alertController.addAction(checkAction)
            present(alertController, animated: true, completion: nil)
            return
        }
        
        guard passwordTextField.text == checkPasswordTextField.text else {
            let alertController = UIAlertController(title: "λΉλ°λ²νΈκ° μΌμΉνμ§ μμ΅λλ€.", message: nil, preferredStyle: .alert)
            let checkAction = UIAlertAction(title: "νμΈ", style: .default, handler: nil)
            alertController.addAction(checkAction)
            present(alertController, animated: true, completion: nil)
            return
        }
        
        guard userNameTextField.text?.isEmpty == false, studentNumberTextField.text?.isEmpty == false else {
            let alertController = UIAlertController(title: "νλ²κ³Ό μ΄λ¦μ μμ±ν΄μ£ΌμΈμ", message: nil, preferredStyle: .alert)
            let checkAction = UIAlertAction(title: "νμΈ", style: .default, handler: nil)
            alertController.addAction(checkAction)
            present(alertController, animated: true, completion: nil)
            return
        }
        
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { (snapshot: QuerySnapshot?, error) in
            // μ€λ³΅λ μ΄λ©μΌμ΄ μμκ²½μ°
            if snapshot!.documents.count == 0 {
                Auth.auth().createUser(withEmail: email, password: password, completion: { (snapshot,error) in
                    // μ΄λ©μΌκ³Ό λΉλ°λ²νΈλ‘ κ³μ μ μμ±νν μ€λ₯κ° μμμ λ°μ΄ν°λ² μ΄μ€μ μ λ³΄λ μλ ₯
                    if error == nil {
                        self.db.collection("users").document(Auth.auth().currentUser!.uid).setData(newUser)
                        FirebaseDataService.instance.userRef.child(Auth.auth().currentUser!.uid).child("userID").setValue(userID)
                        
                        self.performSegue(withIdentifier: "emailCertification", sender: nil)
                    // κ³μ μμ±μ μ€λ₯λ°μ
                    } else {
                        let alertController = UIAlertController(title: "μ΄λ©μΌ νμμ΄ μ¬λ°λ₯΄μ§ μμ΅λλ€.", message: nil, preferredStyle: .alert)
                        let checkAction = UIAlertAction(title: "νμΈ", style: .default, handler: nil)
                        alertController.addAction(checkAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                })
            // μ€λ³΅λ μ΄λ©μΌμ΄ μ‘΄μ¬ν  κ²½μ°  OR  μ΄λ©μΌμΈμ¦νλ©΄μμ λ€λ‘μμ κ²½μ°
            } else {
                guard let uid = Auth.auth().currentUser?.uid else {
                    //μ€λ³΅λ μ΄λ©μΌμ΄ μ‘΄μ¬ν κ²½μ°
                    let alertController = UIAlertController(title: "μ΄λ―Έ μ‘΄μ¬νλ μ΄λ©μΌμλλ€.", message: nil, preferredStyle: .alert)
                    let checkAction = UIAlertAction(title: "νμΈ", style: .default, handler: nil)
                    alertController.addAction(checkAction)
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
                // μ΄λ©μΌμΈμ¦νλ©΄μμ λ€λ‘μμ κ²½μ°
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
