//
//  MoreDetailsTableViewController.swift
//  DormitoryForDelivery
//
//  Created by 김덕환 on 2021/08/16.
//


/*
 초밥

 
 */


import UIKit
import FirebaseAuth
import FirebaseFirestore


class MoreDetailsTableViewController: UITableViewController {
    
    let db: Firestore = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SettingsTableView.backgroundColor = .systemGray6
        SettingsTableView.delegate = self
        SettingsTableView.dataSource = self
        navigationUI()
        SettingsTableView.rowHeight = UITableView.automaticDimension
        let nibName = UINib(nibName: "MyInfoTableViewCell", bundle: nil)
        SettingsTableView.register(nibName, forCellReuseIdentifier: "MyInfoTableViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        FetchData()
    }
    
    func FetchData(){
        guard let uid = FirebaseDataService.instance.currentUserUid else { return }
            let ref = self.db.collection("users").document(uid)
            ref.getDocument() { (snapshot, error) in
                if error == nil {
                    guard let snapshot = snapshot else {return}
                    let email = snapshot["email"] as! String
                    let studentNumber = snapshot["studentNumber"] as! String
                    let name = snapshot["userName"] as! String
                    
                    self.email = email
                    self.studentNumber = studentNumber
                    self.name = name
                    self.SettingsTableView.reloadData()
                    
                }
            }
    }
    
    let SectionName = ["","내 정보", "계정", "기타"]
    let AccInfo = ["비밀번호 변경", "로그아웃"]
    let EtcInfo = ["라이센스", "문의하기"]
    var email: String?
    var studentNumber: String?
    var name: String?
    
    
    @IBOutlet var SettingsTableView: UITableView!
    
    
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
    
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1{
            return 100
        }else{
            return UITableView.automaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let SectionView = UIView(frame: CGRect(x: 0, y: 0, width: SettingsTableView.frame.width, height: 20))
        
        let SectionLabel = UILabel(frame: CGRect(x: 10, y: -10, width: SectionView.frame.width, height: SectionView.frame.height))
        
        SectionLabel.text = SectionName[section]
        SectionView.addSubview(SectionLabel)
        
        return SectionView
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return SectionName.count
    }//섹션 갯수
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return 1
        }
        else if section == 2{
            return 2
        }
        else if section == 3{
            return 2
        }
        else{
            return 0
        }
    } // 섹션 셀 갯수
    

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 1 {
            let MyInfo = SettingsTableView.dequeueReusableCell(withIdentifier: "MyInfoTableViewCell", for: indexPath) as! MyInfoTableViewCell
            MyInfo.selectionStyle = .none
            MyInfo.RName.text = name
            MyInfo.RMail.text = email
            MyInfo.RNumber.text = studentNumber
    
            return MyInfo
        }else{
            let MyInfoCell = SettingsTableView.dequeueReusableCell(withIdentifier: "MyInfoCell", for: indexPath)
            
            MyInfoCell.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
            
            if indexPath.section == 2{
                MyInfoCell.textLabel?.text = "\(AccInfo[indexPath.row])"
            } else if indexPath.section == 3{
                MyInfoCell.textLabel?.text = "\(EtcInfo[indexPath.row])"
            } else {
                return UITableViewCell()
            }
            return MyInfoCell
        }
    }// 셀 설정
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedSection = indexPath.section
        if selectedSection == 2{
            if indexPath.row == 0{
                self.performSegue(withIdentifier: "ChangePassword", sender: nil)
            }
            
            if indexPath.row == 1{
                let alertController = UIAlertController(title: "로그아웃하시겠습니까?", message: nil, preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                let checkAction = UIAlertAction(title: "확인", style: .default) { action in
                    self.performSegue(withIdentifier: "logOut", sender: nil)
                }
                alertController.addAction(checkAction)
                present(alertController, animated: true, completion: nil)
                
            }
        } else {
            if indexPath.row == 1 {
                self.performSegue(withIdentifier: "Inqury", sender: nil)
            }
        }
        SettingsTableView.deselectRow(at: indexPath, animated: false)
    }

}
