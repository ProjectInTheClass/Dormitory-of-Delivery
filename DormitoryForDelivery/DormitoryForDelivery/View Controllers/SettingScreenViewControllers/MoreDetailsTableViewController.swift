//
//  MoreDetailsTableViewController.swift
//  DormitoryForDelivery
//
//  Created by 김동현 on 2021/08/16.
//

import UIKit
import FirebaseAuth

class MoreDetailsTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationUI()
    }
    
    @IBAction func logOutButtonTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "로그아웃하시겠습니까?", message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        let checkAction = UIAlertAction(title: "확인", style: .default) { action in
            self.performSegue(withIdentifier: "logOut", sender: nil)
        }
        alertController.addAction(checkAction)
        present(alertController, animated: true, completion: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "logOut" {
            let firebaseAuth = Auth.auth()
            do {
              try firebaseAuth.signOut()
            } catch let signOutError as NSError {
              print("Error signing out: %@", signOutError)
            }
        }
    }
    
    func navigationUI() {
        
    }

}
