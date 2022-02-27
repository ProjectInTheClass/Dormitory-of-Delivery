//
//  PostViewController.swift
//  DormitoryForDelivery
//
//  Created by 이태영 on 2021/08/15.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

protocol PostViewControllerDelegate {
    func currentNumberChanged(currentNumber: Int, selectedIndexPath: Int)
}

class PostViewController: UIViewController, SendEditDataDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var participateButton: UIButton!
    @IBOutlet weak var includeParticipateButtonView: UIView!
    @IBOutlet weak var includePostInformationView: UIView!
    @IBOutlet weak var moreOptionButton: UIBarButtonItem!
    //@IBOutlet weak var currentNumberOfParticipants: UILabel!
    //@IBOutlet weak var currentParticipantsProgressView: UIProgressView!
    
    var mainPostInformation: RecruitingText?
    
    var selectedIndexPath: Int?
    
    var delegate: PostViewControllerDelegate?
    
    let db: Firestore = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        moreOptionButtonUpdateUI()
        participateButtonUpdateUI()
        navigationBar.title = mainPostInformation?.postTitle
        navigationUI()

    }
    
    @IBAction func participateButtonTapped(_ sender: Any) {
        
        // 최대인원에 도달하면 alert
        if Int(mainPostInformation!.currentNumber) >= Int(mainPostInformation!.maximumNumber) {
            let participateAlertController = UIAlertController(title: "현재 인원이 모두 찼습니다.", message: nil , preferredStyle: .alert)
            let alertOkayAction = UIAlertAction(title: "확인", style: .default, handler: nil)
            participateAlertController.addAction(alertOkayAction)
            present(participateAlertController, animated: true, completion: nil)
        } else {
            let participateAlertController = UIAlertController(title: "주문에 참여하시겠습니까?", message: "주문 참여 시 채팅방에 초대됩니다.", preferredStyle: .alert)
            let alertCancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            let alertOkayAction = UIAlertAction(title: "확인", style: .default) { action in
                self.delegate?.currentNumberChanged(currentNumber: self.mainPostInformation!.currentNumber + 1, selectedIndexPath: self.selectedIndexPath!)
                
                
                
                // 그룹 현재인원 +1
                FirebaseDataService.instance.groupRef.child(self.mainPostInformation!.documentId).updateChildValues(["currentNumber" : self.mainPostInformation!.currentNumber + 1])
                
                // 내가 속한그룹에 그룹추가
                if let uid = FirebaseDataService.instance.currentUserUid {
                    let userRef = FirebaseDataService.instance.userRef.child(uid)
                    let data = [self.mainPostInformation?.documentId : 1]
                    userRef.child("groups").updateChildValues(data)
                }
                let doc =  self.db.collection("messageGroup").document(self.mainPostInformation!.documentId)
                doc.getDocument { (snapshot: DocumentSnapshot?, error: Error?) in
                    guard error == nil else {
               return }
                    var memberData: [String: [String]] = snapshot!.data() as! [String: [String]]
                    if var memberData1 = memberData["users"] {
                        memberData1.append(Auth.auth().currentUser!.uid)
                        memberData.updateValue(memberData1, forKey: "users")
                        doc.setData(memberData)
                    }
                }
                self.performSegue(withIdentifier: "unwindMainView", sender: nil)
            }
            participateAlertController.addAction(alertCancelAction)
            participateAlertController.addAction(alertOkayAction)
            present(participateAlertController, animated: true, completion: nil)
        }
        
        
        
    }
    @IBAction func moreOptionBarButtonTapped(_ sender: Any) {
        let moreOptionAlertController = UIAlertController(title: "메뉴", message: nil, preferredStyle: .actionSheet)
        let alertEditPostAction = UIAlertAction(title: "수정하기", style: .default) { action in
            self.performSegue(withIdentifier: "editPostInformation", sender: nil)
        }
        let alertDeletePostAction = UIAlertAction(title: "삭제하기", style: .destructive) { action in
            self.creatConfirmDeleteAlertController()
        }
        let alertCancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        moreOptionAlertController.addAction(alertEditPostAction)
        moreOptionAlertController.addAction(alertDeletePostAction)
        moreOptionAlertController.addAction(alertCancelAction)
        present(moreOptionAlertController, animated: true, completion: nil)
    }
    
    func creatConfirmDeleteAlertController() {
        let confirmDeleteAlertController = UIAlertController(title: "삭제하시겠습니까?", message: nil, preferredStyle: .alert)
        let alertDeleteConfirmAction = UIAlertAction(title: "확인", style: .default) { action in
            // 파이어스토어 "recruitTables" 데이터 삭제
            
            self.db.collection("recruitTables").document(self.mainPostInformation!.documentId).delete { (error) in
                guard error == nil else { return }
             }
//            self.db.collection("recruitTables").getDocuments() { (snapshot, error) in
//                if error == nil {
//                    guard let snapshot = snapshot else { return }
//                    for document in snapshot.documents {
//                        let documentID = document.documentID
//                        if documentID == self.mainPostInformation?.documentId {
//                            self.db.collection("recruitTables").document(documentID).delete() { err in
//                                if let err = err {
//                                    print("Error removing document: \(err)")
//                                } else {
//                                    print("Document successfully removed!")
//                                }
//                            }
//                        }
//                    }
//                }
//            }
            // 리얼타임 데이터베이스 users 노드 데이터 삭제
            let doc =  self.db.collection("messageGroup").document(self.mainPostInformation!.documentId)
            doc.getDocument { (snapshot: DocumentSnapshot?, error: Error?) in
                guard error == nil else { return }
                let memberData: [String: [String]] = snapshot!.data() as! [String: [String]]
                if let memberData = memberData["users"] {
                    for users in memberData {
                        FirebaseDataService.instance.userRef.child(users).child("groups").observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
                            let userRef = FirebaseDataService.instance.userRef.child(users)
                            var item = snapshot.value as! [String: Any]
                            print(item)
                            item.removeValue(forKey: self.mainPostInformation!.documentId)
                            print(item)
                            userRef.child("groups").setValue(item) { (error, ref) in
                                guard error == nil else {
                                    print("Error :", error)
                            return }
                                print("Edit value success")
                            }
                        }
                    }
                }
                // 파이어스토어 "messageGroup" 데이터 삭제
                self.db.collection("messageGroup").document(self.mainPostInformation!.documentId).delete { (error) in
                    guard error == nil else { return }
                 }
            }
            // 리얼타임 데이터베이스 group 노드 데이터 삭제
            FirebaseDataService.instance.groupRef.child(self.mainPostInformation!.documentId).removeValue()

            self.performSegue(withIdentifier: "unwindMainView", sender: nil)
        }
        let alertDeleteCancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        confirmDeleteAlertController.addAction(alertDeleteCancelAction)
        confirmDeleteAlertController.addAction(alertDeleteConfirmAction)
        present(confirmDeleteAlertController, animated: true, completion: nil)
    }
    
    func participateButtonUpdateUI() {
        
        participateButton.layer.cornerRadius = 6

        participateButton.layer.backgroundColor = UIColor(displayP3Red: 142/255, green: 160/255, blue: 207/255, alpha: 1).cgColor
        
        participateButton.layer.borderColor = UIColor(displayP3Red: 142/255, green: 160/255, blue: 207/255, alpha: 1).cgColor
        
        participateButton.layer.borderWidth = 1.0
        
        includeParticipateButtonView.layer.cornerRadius = 6

        guard let currentUid = FirebaseDataService.instance.currentUserUid else {return}
        var array:[String] = []

        // 사용자 -> 버튼비활성화
        FirebaseDataService.instance.userRef.child(currentUid).child("groups").getData(completion: { (error,snapshot) in
            if let dict = snapshot.value as? Dictionary<String,AnyObject>{
                for (key, _) in dict{
                    array.append(key)

                    if array.contains(self.mainPostInformation!.documentId) == true {
                        self.participateButton.backgroundColor = .gray
                        self.participateButton.setTitle("참여중", for: .normal)
                        self.participateButton.isEnabled = false
                    }
                }
            }
        })

        // 작성자 -> 버튼없애기
        if mainPostInformation!.WriteUid == FirebaseDataService.instance.currentUserUid{
            self.participateButton.backgroundColor = .gray
            self.participateButton.setTitle("작성자", for: .normal)
            self.participateButton.isEnabled = false
        }


    }
    
    func sendData(mainPostInformation: RecruitingText) {
        self.mainPostInformation = mainPostInformation
        navigationBar.title = mainPostInformation.postTitle
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "send"), object: mainPostInformation)
    }
    
    func moreOptionButtonUpdateUI() {
        if mainPostInformation?.WriteUid != Auth.auth().currentUser?.uid {
            moreOptionButton.isEnabled = false
        }
    }
    
    func navigationUI() {
        navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sendPostInformation" {
            let destinationViewController = segue.destination as? PostTableViewController
            destinationViewController?.mainPostInformation = self.mainPostInformation
        }
        
        if segue.identifier == "editPostInformation" {
            let destination = segue.destination as? EditNavigationController
            destination?.editPost = self.mainPostInformation
            let childDestination = destination?.viewControllers.first as? RecruitmenTableViewController
            childDestination?.delegate = self
        }
    }
}
