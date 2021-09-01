//
//  MainTableViewController2.swift
//  DormitoryForDelivery
//
//  Created by 이태영 on 2021/08/07.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class MainTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PostViewControllerDelegate, UISearchResultsUpdating {

    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet var filterButtonCollection: [UIButton]!
    
    
    let db: Firestore = Firestore.firestore()
    
    var mainPosts: [RecruitingText] = []
    
    var filteredButtonMainPost: [RecruitingText]? = nil
    
    var searchMainPost: [RecruitingText]?
    
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        //checkDeviceNetworkStatus()
        mainTableView.dataSource = self
        mainTableView.delegate = self
        setUpSearchController()
     //   fetchRecruitmentTableList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.searchMainPost = nil
        self.filteredButtonMainPost = nil
//        updateCurrentNumberToServer()
        fetchRecruitmentTableList()
    }
    
    @IBAction func unwindFromRecruitmentTableView(_ unwindSegue: UIStoryboardSegue) {
        
    }
    

    @IBAction func showAllPostButtonTapped(_ sender: UIButton) {
        self.searchMainPost = nil
        self.filteredButtonMainPost = nil
//        for selectedButton in filterButtonCollection {
//            selectedButton.setImage(UIImage(named: "\(selectedButton.currentTitle!)라인"), for: .normal)
//        }
        self.mainTableView.reloadData()
    }
    
    @IBAction func filterButtonTapped(_ sender: UIButton) {
        for selectedButton in filterButtonCollection {
            if selectedButton.currentTitle == sender.currentTitle {
                selectedButton.setImage(UIImage(named: selectedButton.currentTitle!), for: .normal)
            } else {
                selectedButton.setImage(UIImage(named: "\(selectedButton.currentTitle!)라인"), for: .normal)
            }
        }

        self.searchMainPost = []
        let selectedButtonTitle = sender.title(for: .normal)
        self.filteredButtonMainPost = self.mainPosts.filter { (element) -> Bool in
            return element.categories == selectedButtonTitle!
        }
        self.mainTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let searchMainPost = searchMainPost else { return mainPosts.count }
        
        guard let filteredButtonMainPost = filteredButtonMainPost else { return searchMainPost.count }
            return filteredButtonMainPost.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MainTableViewCell
//
        guard let searchMainPost = searchMainPost else { let mainPost = mainPosts[indexPath.row]
            cell.update(with: mainPost)
            return cell
        }
        
        guard let filteredButtonMainPost = filteredButtonMainPost else { let mainPost = searchMainPost[indexPath.row]
            cell.update(with: mainPost)
            return cell
        }
        let filterPost = filteredButtonMainPost[indexPath.row]
        cell.update(with: filterPost)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if filteredButtonMainPost != nil {
            self.mainPosts = filteredButtonMainPost!
        } else if searchMainPost != nil {
            self.mainPosts = searchMainPost!
        }
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
                    
                    let meetingTime = document.data()["meetingTime"] as! NSNumber
                    let meetingTimeLabel = self.fetchMeetingTime(meetingTime: meetingTime)
                    
                    let mainpost:RecruitingText = RecruitingText(postTitle: title, categories: category,        postNoteText: noteText, maximumNumber: maximumNumber, currentNumber: currentNumber, WriteUid: uid, timestamp: timestamp, documentId: documentId, meetingTime: meetingTimeLabel)
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
    
    func setUpSearchController() {
//        self.mainTableView.tableHeaderView = searchController.searchBar
        self.searchBarView.addSubview(searchController.searchBar)
        searchController.searchBar.placeholder = "제목, 카테고리 등"
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.searchBarStyle = UISearchBar.Style.prominent
        searchController.searchBar.sizeToFit()
        definesPresentationContext = true
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        self.filteredButtonMainPost = nil
        if searchMainPost == nil || searchController.searchBar.text!.isEmpty {
            searchMainPost = mainPosts
        } else {
            self.searchMainPost = mainPosts.filter { (element) in
                return element.postTitle.contains(searchController.searchBar.text!) || element.categories.contains(searchController.searchBar.text!)
            }
        }
        self.mainTableView.reloadData()
    }



    // MARK: - Navigation
    
    
    @IBAction func unwindToMainViewController(unwindSegue: UIStoryboardSegue){
        //self.fetchRecruitmentTableList()
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
    
    func fetchMeetingTime(meetingTime:NSNumber) -> String {
        let today = Date().timeIntervalSince1970
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_kr")
        dateFormatter.dateFormat = "dd"
        
        let currentDay = dateFormatter.string(from: Date(timeIntervalSince1970: today))
        let meetingDay = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(truncating: meetingTime)))
        
        if currentDay == meetingDay {
            dateFormatter.dateFormat = "a HH:mm"
            
            return dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(truncating: meetingTime)))
        }
        return ""
       
    }
}


