//
//  SearchViewController.swift
//  DormitoryForDelivery
//
//  Created by 이태영 on 2022/02/23.
//

import UIKit
import FirebaseFirestore

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate {

    

    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet weak var searchTableView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var searchMainPost: [RecruitingText] = []
    
    let db: Firestore = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTableView.dataSource = self
        searchTableView.delegate = self
        searchController.searchBar.delegate = self
        setUpSearchController()

        // Do any additional setup after loading the view.
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchMainPost.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MainTableViewCell
        let searchMainPost = searchMainPost[indexPath.row]
            cell.update(with: searchMainPost)
            return cell
    }
    
    private func setUpSearchController() {
        self.searchBarView.addSubview(searchController.searchBar)
        searchController.searchBar.placeholder = "제목, 카테고리 등"
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.searchBarStyle = UISearchBar.Style.prominent
        searchController.searchBar.sizeToFit()
        searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
    }
    
    func updateSearchResults(for searchController: UISearchController) {
  
    }
    // 검색 확인 버튼을 눌렀을 때 서버에서 해당 데이터 가져오기
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        var searchQuery: Query!
        var searchPost: [RecruitingText] = []
        print(searchController.searchBar.text!)
        var findPostArray: [String] = []
        findPostArray.append(searchController.searchBar.text!)
        searchQuery = self.db.collection("recruitTables")
            .whereField("titleComponentArray", arrayContainsAny: findPostArray)
//            .order(by: "timestamp", descending: true)
        searchQuery.getDocuments { [self] (snapshot, error) in
            if error != nil {
                print("error")
            } else if snapshot!.isEmpty {
                print("Snapshot is empty")
                self.searchMainPost = []
                self.searchTableView.reloadData()
            } else {
                    for document in snapshot!.documents{
                        let title = document.data()["title"] as! String
                        let uid = document.data()["uid"] as! String
                        let category = document.data()["category"] as! String
                        let categoryNumber = document.data()["categoryNumber"] as! Int
                        let noteText = document.data()["noteText"] as! String
                        let maximumNumber = document.data()["maximumNumber"] as! Int
                        let currentNumber = document.data()["currentNumber"] as! Int
                        let timestamp = document.data()["timestamp"] as! NSNumber
                        let documentId = document.documentID
                        let meetingTime = document.data()["meetingTime"] as! NSNumber
                        let titleComponentArray = document.data()["titleComponentArray"] as! [String]
                        let meetingTimeLabel = self.fetchMeetingTime(meetingTime: meetingTime)
                        let searchingPost:RecruitingText = RecruitingText(postTitle: title, categories: category, categoryNumber: categoryNumber, postNoteText: noteText, maximumNumber: maximumNumber, currentNumber: currentNumber, WriteUid: uid, timestamp: timestamp, documentId: documentId, meetingTime: meetingTimeLabel, titleComponentArray: titleComponentArray)
                        self.searchMainPost.append(searchingPost)
                    }
                print(searchPost)
                self.searchTableView.reloadData()
                }
            }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchMainPost = []
        self.searchBarView.addSubview(searchController.searchBar)
        self.searchTableView.reloadData()
    }
    
    private func fetchMeetingTime(meetingTime:NSNumber) -> String {
        let today = Date().timeIntervalSince1970
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_kr")
        dateFormatter.dateFormat = "dd"
        
        let currentDay = Int(dateFormatter.string(from: Date(timeIntervalSince1970: today)))!
        let meetingDay = Int(dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(truncating: meetingTime))))!
        
        if currentDay == meetingDay {
            dateFormatter.dateFormat = "a hh:mm"
            return dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(truncating: meetingTime))) + " " + "까지"
            
        } else if currentDay + 1 == meetingDay {
            dateFormatter.dateFormat = "a hh:mm"
            return "내일 " + dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(truncating: meetingTime)))
        }
        
        return ""
       
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
