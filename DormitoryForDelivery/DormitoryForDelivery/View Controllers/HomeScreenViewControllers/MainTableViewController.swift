//
//  MainTableViewController2.swift
//  DormitoryForDelivery
//
//  Created by 이태영 on 2021/08/07.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

final class MainTableViewController: UIViewController, PostViewControllerDelegate {
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet var filterButtonCollection: [UIButton]!
    @IBOutlet var filterLabelCollection: [UILabel]!
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var showAllButton: UIButton!
    @IBOutlet weak var showAllButtonLabel: UILabel!
    
    let db: Firestore = Firestore.firestore()
    var mainPosts: [RecruitingText] = []
    var filteredButtonMainPost: [RecruitingText]? = nil
    var filterCategoryNumber: Int?
    var tappedFilterButtonTitle: String?
    var searchMainPost: [RecruitingText]?
    let searchController = UISearchController(searchResultsController: nil)
    let navigationApperance = UINavigationBarAppearance()
    var mainPostsHasNextPage: Bool = false
    var lastDocumentSnapshot: DocumentSnapshot?
    var abusiveUserList: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainTableView.dataSource = self
        mainTableView.delegate = self
        initRefresh()
        navigationUI()
        button.tintColor = UIColor(red:142/255 , green: 160/255, blue: 207/255, alpha: 1)
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = button.layer.frame.size.width/2
        
    }
    
    func checkAndShowLoginOrIntro() -> Bool {
        let flag = UserDefaults.standard.hasTutorial
        
        if flag == false {
            let vc = TutorialViewController.instantiate()
            
            vc.modalPresentationStyle = .fullScreen
            
            self.present(vc, animated: false, completion: nil)
        }
        return flag
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if checkAndShowLoginOrIntro() == false {
            return
        }
        
        if Auth.auth().currentUser?.uid == nil || Auth.auth().currentUser?.isEmailVerified == false {
            performSegue(withIdentifier: "login", sender: self)
            
        } else {
            changeButtonColorViewDidAppear()
            self.searchMainPost = nil
            self.filteredButtonMainPost = nil
            self.mainPosts = []
            readAbusiveUserListFromServer()
            self.mainTableView.reloadData()
        }
        
    }
    
    @IBAction func unwindFromRecruitmentTableView(_ unwindSegue: UIStoryboardSegue) {
        
    }
    
    @IBAction func filterButtonTapped(_ sender: UIButton) {
        for selectedButton in filterButtonCollection {
            let index = filterButtonCollection.firstIndex {$0 == selectedButton}
            if selectedButton.currentTitle == sender.currentTitle {
                selectedButton.setImage(UIImage(named: selectedButton.currentTitle!), for: .normal)
                filterLabelCollection[index!].textColor = UIColor(red: 142/255, green: 160/255, blue: 207/255, alpha: 1)
            } else {
                selectedButton.setImage(UIImage(named: "\(selectedButton.currentTitle!)라인"), for: .normal)
                filterLabelCollection[index!].textColor = UIColor.black
            }
        }
        if sender.currentTitle == "전체" {
            self.tappedFilterButtonTitle = nil
            self.mainPosts = []
            self.searchMainPost = nil
            self.filteredButtonMainPost = nil
            fetchRecruitmentTableList()
        } else {
            self.tappedFilterButtonTitle = sender.currentTitle
            creatSelectedCategoriesNumber(name: self.tappedFilterButtonTitle!)
            fetchRecruitmentTableList()
        }
    }
    
    func fetchRecruitmentTableList(){
        var mainPostQuery: Query!
        var filterPost: [RecruitingText] = []
        
        if self.mainPosts.isEmpty {
            mainPostQuery = self.db.collection("recruitTables")
                .order(by: "timestamp", descending: true)
                .limit(to: 10)
        } else if self.tappedFilterButtonTitle != nil {
            self.filteredButtonMainPost = []
            mainPostQuery = self.db.collection("recruitTables")
                .whereField("categoryNumber", isEqualTo: self.filterCategoryNumber)
                .order(by: "timestamp", descending: true)
                .limit(to: 10)
        } else {
            guard let lastDocumentSnapshot = lastDocumentSnapshot else { return }
            mainPostQuery = self.db.collection("recruitTables")
                .order(by: "timestamp", descending: true)
                .start(afterDocument: lastDocumentSnapshot)
                .limit(to: 10)
        }
        mainPostQuery.getDocuments() { (snapshot, error) in
            if error != nil {
                print("error")
            } else if snapshot!.isEmpty {
                print("Snapshot is empty")
                self.mainPostsHasNextPage = false
                self.mainTableView.reloadData()
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
                    let mainPost:RecruitingText = RecruitingText(postTitle: title, categories: category, categoryNumber: categoryNumber, postNoteText: noteText, maximumNumber: maximumNumber, currentNumber: currentNumber, WriteUid: uid, timestamp: timestamp, documentId: documentId, meetingTime: meetingTimeLabel, titleComponentArray: titleComponentArray)
                    if self.tappedFilterButtonTitle != nil {
                        filterPost.append(mainPost)
                        self.filteredButtonMainPost = filterPost
                    } else {
                        self.mainPosts.append(mainPost)
                    }
                }
                if self.filteredButtonMainPost != nil {
                    for abusiveUser in self.abusiveUserList {
                        guard var filteredButtonMainPost = self.filteredButtonMainPost else { return }
                        filteredButtonMainPost = filteredButtonMainPost.filter { $0.WriteUid != abusiveUser }
                        self.filteredButtonMainPost = filteredButtonMainPost
                    }
                } else {
                    print(self.abusiveUserList)
                    for abusiveUser in self.abusiveUserList {
                        self.mainPosts = self.mainPosts.filter { $0.WriteUid != abusiveUser }
                    }
                }
                self.mainTableView.reloadData()
                self.lastDocumentSnapshot = snapshot!.documents.last
            }
        }
    }
    
    func currentNumberChanged(currentNumber: Int, selectedIndexPath: Int) {
        self.mainPosts[selectedIndexPath].currentNumber = currentNumber
        
        let doc = db.collection("recruitTables").document(self.mainPosts[selectedIndexPath].documentId)
        let data: [String : AnyObject] = ["currentNumber" : self.mainPosts[selectedIndexPath].currentNumber as AnyObject]
        doc.setData(data, merge: true) { (error) in
            guard error == nil else { return }
        }
        self.mainTableView.reloadData()
    }
    
    func fetchMeetingTime(meetingTime:NSNumber) -> String {
        let today = Date().timeIntervalSince1970
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_kr")
        dateFormatter.dateFormat = "dd"
        
        let currentDay = Int(dateFormatter.string(from: Date(timeIntervalSince1970: today)))!
        let meetingDay = Int(dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(truncating: meetingTime))))!
        
        if currentDay == meetingDay {
            dateFormatter.dateFormat = "a hh:mm"
            return dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(truncating: meetingTime)))
            
        } else if currentDay + 1 == meetingDay {
            dateFormatter.dateFormat = "a hh:mm"
            return "내일 " + dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(truncating: meetingTime)))
        }
        
        return ""
        
    }
    
    private func navigationUI() {
        navigationBar.backButtonTitle = ""
        navigationController?.navigationBar.tintColor = .white
    }
    
    private func initRefresh() {
        mainTableView.refreshControl = UIRefreshControl()
        mainTableView.refreshControl?.addTarget(self, action: #selector(pullToRefreshTableView(sender: )), for: .valueChanged)
    }
    
    @objc private func pullToRefreshTableView(sender: Any) {
        if self.mainPosts.count >= 10 {
            self.mainPostsHasNextPage = true
        }
        if self.tappedFilterButtonTitle != nil {
            readAbusiveUserListFromServer()
            self.mainTableView.refreshControl?.endRefreshing()
        } else {
            self.mainPosts.removeAll()
            readAbusiveUserListFromServer()
            self.mainTableView.refreshControl?.endRefreshing()
        }
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.height
        if self.mainPosts.count >= 10 {
            self.mainPostsHasNextPage = true
        }
        if currentOffset > (contentHeight - height) {
            if mainPostsHasNextPage {
                beginpaginMainTableView()
            }
        }
    }
    
    private func beginpaginMainTableView() {
        DispatchQueue.main.async {
            self.mainTableView.reloadSections(IndexSet(integer: 1), with: .none)
            self.fetchRecruitmentTableList()
        }
    }
    
    private func creatSelectedCategoriesNumber( name: String) {
        if name == "커피" {
            self.filterCategoryNumber = 1
        } else if name == "디저트" {
            self.filterCategoryNumber = 2
        } else if name == "햄버거" {
            self.filterCategoryNumber = 3
        } else if name == "돈까스" {
            self.filterCategoryNumber = 4
        } else if name == "초밥" {
            self.filterCategoryNumber = 5
        } else if name == "샐러드" {
            self.filterCategoryNumber = 6
        } else if name == "중국집" {
            self.filterCategoryNumber = 7
        } else if name == "한식" {
            self.filterCategoryNumber = 8
        } else if name == "분식" {
            self.filterCategoryNumber = 9
        }
    }
    
    private func readAbusiveUserListFromServer() {
        db.collection("users").document(Auth.auth().currentUser!.uid).getDocument { (snapShot, error) in
            if error != nil {
                print("error")
            } else {
                guard let blockList = snapShot?.data()?["blockAbusiveUserList"] as? [String] else {
                    self.abusiveUserList.removeAll()
                    self.fetchRecruitmentTableList()
                    return
                }
                self.abusiveUserList = blockList
                self.fetchRecruitmentTableList()
            }
        }
    }
    
    private func changeButtonColorViewDidAppear() {
        for changeButton in filterButtonCollection {
            let index = filterButtonCollection.firstIndex {$0 == changeButton}
            changeButton.setImage(UIImage(named: "\(changeButton.currentTitle!)라인"), for: .normal)
            filterLabelCollection[index!].textColor = UIColor.black
        }
        showAllButton.setImage(UIImage(named: "전체"), for: .normal)
        showAllButtonLabel.textColor = UIColor(red: 142/255, green: 160/255, blue: 207/255, alpha: 1)
    }
    
    // MARK: - Navigation
    @IBAction func unwindToMainViewController(unwindSegue: UIStoryboardSegue){
        if unwindSegue.identifier == "LogOut" {
            performSegue(withIdentifier: "login", sender: nil)
        }
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sendPostSegue" {
            let destinationViewController = segue.destination as? PostViewController
            destinationViewController?.delegate = self
            if let indexPath = sender as? Int {
                destinationViewController?.mainPostInformation = mainPosts[indexPath]
                destinationViewController?.selectedIndexPath = indexPath
            }
        } else if segue.identifier == "searchView" {
            let destinationViewController = segue.destination as? SearchViewController
            destinationViewController?.abusiveUserList = abusiveUserList
        }
    }
}

// MARK: UITableViewDelegate
extension MainTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if filteredButtonMainPost != nil {
            self.mainPosts = filteredButtonMainPost!
        } else if searchMainPost != nil {
            self.mainPosts = searchMainPost!
        }
        performSegue(withIdentifier: "sendPostSegue", sender: indexPath.row)
    }
}

// MARK: UITableViewDataSource
extension MainTableViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            guard let filteredButtonMainPost = filteredButtonMainPost else { return self.mainPosts.count }
            return filteredButtonMainPost.count
        } else if section == 1 && mainPostsHasNextPage {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MainTableViewCell
            guard let filteredButtonMainPost = filteredButtonMainPost else { let mainPost = self.mainPosts[indexPath.row]
                cell.update(with: mainPost)
                return cell
            }
            let filterPost = filteredButtonMainPost[indexPath.row]
            cell.update(with: filterPost)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "IndicateCell", for: indexPath) as! LoadingCell
            cell.startNextPageLoadingIndicatior()
            return cell
        }
    }
}
