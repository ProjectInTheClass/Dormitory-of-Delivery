//
//  MainTableViewController2.swift
//  DormitoryForDelivery
//
//  Created by 이태영 on 2021/08/07.
//

import UIKit
import FirebaseAuth

//protocol MainTableViewControllerDelegate {
//    func didSelect(sendMainPosts: RecruitingText)
//} //프로토콜로 시도

class MainTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var mainTableView: UITableView!
    
    var mainPosts: [RecruitingText] = []
    
//    var delegate: MainTableViewControllerDelegate? 프로토콜로 시도

    override func viewDidLoad() {
        super.viewDidLoad()
        checkDeviceNetworkStatus()
        mainTableView.dataSource = self
        mainTableView.delegate = self
    }
    
    @IBAction func unwindFromRecruitmentTableView(_ unwindSegue: UIStoryboardSegue) {
        guard let recruitMentTableViewController = unwindSegue.source as? RecruitmenTableViewController, let mainPostInformation = recruitMentTableViewController.mainPostInformation else { return }
        
        mainPosts.append(mainPostInformation)
        mainTableView.reloadData()
        // Use data from the view controller which initiated the unwind segue
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        mainPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MainTableViewCell

        let mainPost = mainPosts[indexPath.row]
        
        cell.update(with: mainPost)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "sendPostSegue", sender: indexPath.row)
    }
// 프로토콜로 시도
    
    func checkDeviceNetworkStatus() {
            if(DeviceManager.shared.networkStatus) == false {
                let alert: UIAlertController = UIAlertController(title: "네트워크 상태 확인", message: "네트워크가 불안정 합니다.", preferredStyle: .alert)
                let action: UIAlertAction = UIAlertAction(title: "다시 시도", style: .default, handler: { (ACTION) in
                    self.checkDeviceNetworkStatus()
                })
                alert.addAction(action)
                present(alert, animated: true, completion: nil)
            }
        }
    
//    func recruitmentTextInformation(mainPosts: RecruitingText) {
//        self.mainPosts.append(mainPosts)
//        print(self.mainPosts)
//        mainTableView.reloadData()
//    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sendPostSegue" {
            let destinationViewController = segue.destination as? PostViewController
            if let indexPath = sender as? Int {
            destinationViewController?.mainPostInformation = mainPosts[indexPath]
            }
        }
    }
}

