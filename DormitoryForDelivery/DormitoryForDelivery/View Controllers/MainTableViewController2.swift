//
//  MainTableViewController2.swift
//  DormitoryForDelivery
//
//  Created by 이태영 on 2021/08/07.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class MainTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PostViewControllerDelegate {
    
    @IBOutlet weak var mainTableView: UITableView!
    
    let db: Firestore = Firestore.firestore()
    
    var mainPosts: [RecruitingText] = []
    
    var filteredMainPost: [RecruitingText]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //checkDeviceNetworkStatus()
        mainTableView.dataSource = self
        mainTableView.delegate = self
     //   fetchRecruitmentTableList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.filteredMainPost = nil
//        updateCurrentNumberToServer()
        fetchRecruitmentTableList()
    }
    
    @IBAction func unwindFromRecruitmentTableView(_ unwindSegue: UIStoryboardSegue) {
        
    }
    
    @IBAction func filterButtonTapped(_ sender: UIButton) {
        let selectedButtonTitle = sender.title(for: .normal)
        self.filteredMainPost = self.mainPosts.filter { (element) -> Bool in
            return element.categories == selectedButtonTitle!
        }
        self.mainTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let filteredMainPost = filteredMainPost else { return mainPosts.count }
            return filteredMainPost.count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MainTableViewCell
        guard let filteredMainPost = filteredMainPost else {let mainPost = mainPosts[indexPath.row]
            cell.update(with: mainPost)
            return cell
        }
        let filterPost = filteredMainPost[indexPath.row]
        cell.update(with: filterPost)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        performSegue(withIdentifier: "sendPostSegue", sender: indexPath.row)
    }

    
//    func checkDeviceNetworkStatus() {
//            if(DeviceManager.shared.networkStatus) == false {
//                let alert: UIAlertController = UIAlertController(title: "네트워크 상태 확인", message: "네트워크가 불안정 합니다.", preferredStyle: .alert)
//                let action: UIAlertAction = UIAlertAction(title: "다시 시도", style: .default, handler: { (ACTION) in
//                    self.checkDeviceNetworkStatus()
//                })
//                alert.addAction(action)
//                present(alert, animated: true, completion: nil)
//            }
//        }
    
    func fetchRecruitmentTableList(){
        //질문: 이런식으로 동작하면 속도에 영향은 안가나?, firestore에 하루에 읽을수 있는 정도가 정해있는데 for문을 돌때마다 그럼 데이터를 읽는걸로 치나?
        db.collection("recruitTables").getDocuments(){ (querySnapshot, error) in
            if  error == nil  {
                self.mainPosts.removeAll()
                for document in querySnapshot!.documents{
                    let title = document.data()["title"] as! String
                    let uid = document.data()["uid"] as! String
                    let category = document.data()["category"] as! String
                    let noteText = document.data()["noteText"] as! String
                    let maximumNumber = document.data()["maximumNumber"] as! Int
                    let currentNumber = document.data()["currentNumber"] as! Int
                    let timestamp = document.data()["timestamp"] as! NSNumber
                    let documentId = document.documentID
                    
                    let mainpost:RecruitingText = RecruitingText(postTitle: title, categories: category,        postNoteText: noteText, maximumNumber: maximumNumber, currentNumber: currentNumber, WriteUid: uid, timestamp: timestamp, documentId: documentId)
                    self.mainPosts.append(mainpost)
                    
                    //수정 pageNation으로
                    DispatchQueue.main.async(execute: {
                        self.mainTableView.reloadData()
                    })
                }
            } else {
                print("Error getting documents: ")
            }
        }
    }
    
    func currentNumberChanged(currentNumber: Int, selectedIndexPath: Int) {
        self.mainPosts[selectedIndexPath].currentNumber = currentNumber
        
        db.collection("recruitTables").getDocuments() { (snapshot, error) in
            if error == nil {
                guard let snapshot = snapshot else { return }
                for document in snapshot.documents {
                    let title = document.get("title") as! String
                    if title == self.mainPosts[selectedIndexPath].postTitle {
                        let documentID = document.documentID
                        let data: [String : AnyObject] = ["currentNumber" : self.mainPosts[selectedIndexPath].currentNumber as AnyObject]
                        self.db.collection("recruitTables").document(documentID).updateData(data)
                        self.mainTableView.reloadData()
                    }
                }
            }
        }
    }



    // MARK: - Navigation
    
    
    @IBAction func unwindToMainViewController(unwindSegue: UIStoryboardSegue){
        
    }
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sendPostSegue" {
            let destinationViewController = segue.destination as? PostViewController
            destinationViewController?.delegate = self
            if let indexPath = sender as? Int {
            destinationViewController?.mainPostInformation = mainPosts[indexPath]
            destinationViewController?.selectedIndexPath = indexPath
            }
        }
    }
}

