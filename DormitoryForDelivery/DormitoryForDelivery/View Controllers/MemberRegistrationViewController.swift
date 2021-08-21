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
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    let db:Firestore = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
            let alertController = UIAlertController(title: "비밀번호를 다시 확인해주세요.", message: nil, preferredStyle: .alert)
            let checkAction = UIAlertAction(title: "확인", style: .default, handler: nil)
            alertController.addAction(checkAction)
            present(alertController, animated: true, completion: nil)
            return
        }
        
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        // ToDo: 유저를 등록하기전에 이메일 인증을 하고 해야할것.
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error == nil {
                //회원가입성공 처리
                //ToDo: Firestore에 추가하기전에 좀더 명확한 인과관계를 확인한다.
                let newUser = ["email":email, "password":password]
                self.db.collection("users").document(Auth.auth().currentUser!.uid).setData(newUser) {_ in
                    //질문: createUser하면 바로 signin되기 때문에 회원가입성공시 바로 로그아웃시켜주는코드 사용해도 되는가
                    let firebaseAuth = Auth.auth()
                    do {
                      try firebaseAuth.signOut()
                    } catch let signOutError as NSError {
                      print("Error signing out: %@", signOutError)
                    }
                }
            } else {
                //ToDo: 회원가입실패 처리
                print("회원가입실패")
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func dismissButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapSendSignInLink(_ sender: AnyObject) {
      if let email = emailTextField.text {
          showSpinner()
          let actionCodeSettings = ActionCodeSettings()
          actionCodeSettings.url = URL(string: "https://www.example.com")
          // The sign-in operation has to always be completed in the app.
          actionCodeSettings.handleCodeInApp = true
          actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
          actionCodeSettings.setAndroidPackageName("com.example.android", installIfNotAvailable: false, minimumVersion: "12")
         
          Auth.auth().sendSignInLink(toEmail: email, actionCodeSettings: actionCodeSettings) { error in
              if error != nil {
                print(error?.localizedDescription)
                self.hideSpinner()
                return
              }
              // The link was successfully sent. Inform the user.
              // Save the email locally so you don't need to ask the user for it again
              // if they open the link on the same device.
              UserDefaults.standard.set(email, forKey: "Email")
              print("Check your email for link")
              self.hideSpinner()
            }
          } else {
            print("Email can't be empty")
          }
        }
    
    func showSpinner(){
        spinner.startAnimating()
    }
    
    func hideSpinner(){
        spinner.hidesWhenStopped = true
        spinner.stopAnimating()
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
