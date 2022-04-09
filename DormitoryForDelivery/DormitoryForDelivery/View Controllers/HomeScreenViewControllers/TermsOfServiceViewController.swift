//
//  TermsOfServiceViewController.swift
//  DormitoryForDelivery
//
//  Created by 이태영 on 2022/04/09.
//

import UIKit

class TermsOfServiceViewController: UIViewController {

    @IBOutlet weak var nextStepButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editNavigationUI()
//        self.nextStepButton.layer.cornerRadius = 6
        // Do any additional setup after loading the view.
    }
    
    @IBAction func dismissButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    private func editNavigationUI() {
        navigationController?.navigationBar.tintColor = UIColor.white
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
