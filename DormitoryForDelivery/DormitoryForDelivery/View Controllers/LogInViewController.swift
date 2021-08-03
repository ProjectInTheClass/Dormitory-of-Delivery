//
//  LogInViewController.swift
//  DormitoryForDelivery
//
//  Created by 서인규 on 2021/08/03.
//

import UIKit

class LogInViewController: UIViewController {

    
    // MARK Outlet
    
    @IBOutlet weak var usernameTextView: UITextField!
    @IBOutlet weak var passwordTextView: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    
    @IBOutlet weak var registerationButton: UIButton!
    @IBOutlet weak var IdPasswordFindingButton: UIButton!
    @IBOutlet weak var browseButton: UIButton!
    
    
    
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func logInButton(_ sender: Any) {
        
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
