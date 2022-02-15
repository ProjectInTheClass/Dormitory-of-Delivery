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
    @IBOutlet var filterLabelCollection: [UILabel]!
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var button: UIButton!
    
    let db: Firestore = Firestore.firestore()
    
    var mainPosts: [RecruitingText] = []
    
    var filteredButtonMainPost: [RecruitingText]? = nil
    
    var searchMainPost: [RecruitingText]?
    
    let searchController = UISearchController(searchResultsController: nil)
    
    let navigationApperance = UINavigationBarAppearance()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainTableView.dataSource = self
        mainTableView.delegate = self
        setUpSearchController()
        initRefresh()
        navigationUI()
        
        button.tintColor = UIColor(red:142/255 , green: 160/255, blue: 207/255, alpha: 1)
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = button.layer.frame.size.width/2

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Auth.auth().currentUser?.uid == nil || Auth.auth().currentUser?.isEmailVerified == false {
            performSegue(withIdentifier: "login", sender: self)
            
        } else {
            self.searchMainPost = nil
            self.filteredButtonMainPost = nil
    //        updateCurrentNumberToServer()
            fetchRecruitmentTableList()
        }
        
        print("viewWillAppear")
    }
    
    @IBAction func unwindFromRecruitmentTableView(_ unwindSegue: UIStoryboardSegue) {
        
    }
    

    @IBAction func showAllPostButtonTapped(_ sender: UIButton) {
        self.searchMainPost = nil
        self.filteredButtonMainPost = nil
        self.mainTableView.reloadData()
        
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

    func fetchRecruitmentTableList(){
        var mainPosts: [RecruitingText] = []
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
                    
                    let mainpost:RecruitingText = RecruitingText(postTitle: title, categories: category, postNoteText: noteText, maximumNumber: maximumNumber, currentNumber: currentNumber, WriteUid: uid, timestamp: timestamp, documentId: documentId, meetingTime: meetingTimeLabel)
                    mainPosts.append(mainpost)
                    
                    //수정 pageNation으로
                }
            } else {
                print("Error getting documents: ")
            }
            
            
            mainPosts.sort(by: {(first, second) in
                    return first.meetingTime > second.meetingTime
                })

            let myPosts = mainPosts.filter { (element) -> Bool in
                return element.WriteUid == Auth.auth().currentUser?.uid
            }
            
            let differentUserPosts = mainPosts.filter { (element) -> Bool in
                return element.WriteUid != Auth.auth().currentUser?.uid
            }

            self.mainPosts = myPosts + differentUserPosts
            
            DispatchQueue.main.async(execute: {
                self.mainTableView.reloadData()
            })
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
    
    func setUpSearchController() {
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
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//    // 화면을 누르면 키보드 내려가게 하는 것
//        self.searchController.searchBar.endEditing(true)
//    }

    func fetchMeetingTime(meetingTime:NSNumber) -> String {
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
    
    private func navigationUI() {
        navigationBar.backButtonTitle = ""
        navigationController?.navigationBar.tintColor = .white
    }
    
    private func initRefresh() {
        mainTableView.refreshControl = UIRefreshControl()
        mainTableView.refreshControl?.addTarget(self, action: #selector(pullToRefreshTableView(sender: )), for: .valueChanged)
    }

    @objc private func pullToRefreshTableView(sender: Any) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.fetchRecruitmentTableList()
            self.mainTableView.reloadData()
            self.mainTableView.refreshControl?.endRefreshing()
        }

    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maximumOffset < currentOffset {
            
        }
    }
    // MARK: - Navigation
    
    
    @IBAction func unwindToMainViewController(unwindSegue: UIStoryboardSegue){
        //self.fetchRecruitmentTableList()
        if unwindSegue.identifier == "LogOut" {
            performSegue(withIdentifier: "login", sender: nil)
        }
        
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


