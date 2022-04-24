//
//  LicenseViewController.swift
//  DormitoryForDelivery
//
//  Created by 이태영 on 2022/04/24.
//

import UIKit
import WebKit

class LicenseViewController: UIViewController {

    @IBOutlet weak var licenseWebView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = .white
        
        let url = URL(string: "https://glittery-column-32f.notion.site/d1c9826f2ae042f59dc19972b5a96014")
        let requestLicenseWebView = URLRequest(url: url!)
        licenseWebView.load(requestLicenseWebView)
        
        // Do any additional setup after loading the view.
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
