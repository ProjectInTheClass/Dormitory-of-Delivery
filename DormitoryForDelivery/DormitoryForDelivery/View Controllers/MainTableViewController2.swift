//
//  MainTableViewController2.swift
//  DormitoryForDelivery
//
//  Created by 이태영 on 2021/08/07.
//

import UIKit

class MainTableViewController2: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var mainTableView: UITableView!
    
    var mainPosts: [RecruitingText] = [
        RecruitingText(symbol: "🍔", postTitle: "7시 30분에 햄버거 먹을 사람 5동만", categories: "#햄버거, #맥날", totalNumber: 2),
        RecruitingText(symbol: "🍕", postTitle: "피자 시켜먹을 분", categories: "#피자", totalNumber: 2),
        RecruitingText(symbol: "🧇", postTitle: "와플 같이먹을 분", categories: "#디저트", totalNumber: 3),
        RecruitingText(symbol: "🍣", postTitle: "7시에 초밥 같이먹을 분", categories: "#일식", totalNumber: 2)]

    override func viewDidLoad() {
        super.viewDidLoad()
        checkDeviceNetworkStatus() 
        mainTableView.dataSource = self
        mainTableView.delegate = self
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
