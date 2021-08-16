//
//  LogInViewController.swift
//  DormitoryForDelivery
//
//  Created by 서인규 on 2021/08/03.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class LogInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let db:Firestore = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        // Do any additional setup after loading the view.
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
        
        //To do. 이메일, 비밀번호정보가 맞는지 확인하고 로그인을 할 수 있게한다.
        Auth.auth().signIn(withEmail: email, password: password, completion: nil)
        
        //To do. Firestore에 추가하기전에 좀더 명확한 인과관계를 확인한다.
        let newUser = ["email":email, "password":password]
        db.collection("users").document(Auth.auth().currentUser!.uid).setData(newUser)
        performSegue(withIdentifier: "login", sender: self)
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
