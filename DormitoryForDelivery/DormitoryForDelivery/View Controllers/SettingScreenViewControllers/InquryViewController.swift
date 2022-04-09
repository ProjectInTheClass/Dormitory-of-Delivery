//
//  InquryViewController.swift
//  DormitoryForDelivery
//
//  Created by 이태영 on 2022/04/08.
//

import UIKit
import WebKit

class InquryViewController: UIViewController {

    @IBOutlet weak var inquryWebView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = .white
        
        let url = URL(string: "https://glittery-column-32f.notion.site/580c6f19899b40f3a5af105b1f0f4703")
        let requestInquryWebView = URLRequest(url: url!)
        inquryWebView.load(requestInquryWebView)

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
