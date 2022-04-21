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
    
    var reasonForReport: String?
    
    var reportInformation: ReportForm = ReportForm(reasonForReport: "", reportPostWriterName: "", reportPostTitle: "", reportPostNoteText: "", reportPostWriterEmail: "", reportPostWriterStudentNumber: "", reporterName: "", reporterStudentNumber: "", reporterEmail: "", reportTime: "")

    override func viewDidLoad() {
        super.viewDidLoad()
//        moreOptionButtonUpdateUI()
        participateButtonUpdateUI()
//        navigationBar.title = mainPostInformation?.postTitle
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
                
                // 그룹추가 #1.realtimeDB - user - groups에 추가,  #2.db - messageGroup에 추가
                // #1
                if let uid = FirebaseDataService.instance.currentUserUid {
                    let nowTime = NSNumber(value: Date().timeIntervalSince1970)
                    let userRef = FirebaseDataService.instance.userRef.child(uid)
                    let data = [self.mainPostInformation?.documentId : nowTime]
                    userRef.child("groups").updateChildValues(data)
                    
                    // realDB - group - message: 들어가는 메세지 저장
                    FirebaseDataService.instance.userRef.child(uid).child("userID").getData { (error,snapshot) in
                        guard error == nil else { return }
                        let userID = snapshot.value as! String
                        let data: Dictionary<String, AnyObject> = [
                            "fromUserId" : "System" as AnyObject,
                            "userID" : userID as AnyObject,
                            "text" : "/In/ \(userID)" as AnyObject,
                            "timestamp" : nowTime
                        ]
                        
                        if let documentId = self.mainPostInformation?.documentId {
                            let ref = FirebaseDataService.instance.groupRef.child(documentId).child("messages").childByAutoId()
                            ref.updateChildValues(data) { (error, ref) in
                                guard error == nil else { return }
                            }
                        }
                    }
                    
                }
                // #2
                let doc = self.db.collection("messageGroup").document(self.mainPostInformation!.documentId)
                doc.getDocument { (snapshot: DocumentSnapshot?, error: Error?) in
                    guard error == nil else { return }
                    var memberData: [String: [String]] = snapshot!.data() as! [String: [String]]
                    if var memberData1 = memberData["users"] {
                        memberData1.append(Auth.auth().currentUser!.uid)
                        memberData.updateValue(memberData1, forKey: "users")
                        doc.setData(memberData)
                    }
                }
                
                let announceDeleteAlertController = UIAlertController(title: nil, message: "참여되었습니다.", preferredStyle: .alert)
                self.present(announceDeleteAlertController, animated: true) {
                    self.dismiss(animated: true) {
                    self.performSegue(withIdentifier: "unwindMainView", sender: nil)
                    }
                }
            }
            participateAlertController.addAction(alertCancelAction)
            participateAlertController.addAction(alertOkayAction)
            present(participateAlertController, animated: true, completion: nil)
        }
        
        
        
    }
    @IBAction func moreOptionBarButtonTapped(_ sender: Any) {
        if mainPostInformation?.WriteUid == Auth.auth().currentUser?.uid {
            let moreOptionAlertController = UIAlertController(title: "메뉴", message: nil, preferredStyle: .actionSheet)
            let alertEditPostAction = UIAlertAction(title: "수정하기", style: .default) { action in
                self.performSegue(withIdentifier: "editPostInformation", sender: nil)
            }
            let alertDeletePostAction = UIAlertAction(title: "삭제하기", style: .destructive) { action in
                self.creatConfirmDeleteAlertController()
            }
            let alertCancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            
            moreOptionAlertController.addAction(alertDeletePostAction)
            moreOptionAlertController.addAction(alertEditPostAction)
            moreOptionAlertController.addAction(alertCancelAction)
            present(moreOptionAlertController, animated: true, completion: nil)
        } else {
            let moreOptionAlertController = UIAlertController(title: "메뉴", message: nil, preferredStyle: .actionSheet)
            let alertReportPostAction = UIAlertAction(title: "신고하기", style: .destructive) { action in
                self.choiceReasonForReport()
            }
            let alertBlockAbusiveUserAction = UIAlertAction(title: "차단하기", style: .destructive) { action in
                self.blockAbusiveUserButtonTapped()
            }
            let alertCancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            moreOptionAlertController.addAction(alertReportPostAction)
            moreOptionAlertController.addAction(alertBlockAbusiveUserAction)
            moreOptionAlertController.addAction(alertCancelAction)
            present(moreOptionAlertController, animated: true, completion: nil)
        }

    }
    
    func creatConfirmDeleteAlertController() {
        let confirmDeleteAlertController = UIAlertController(title: "삭제하시겠습니까?", message: nil, preferredStyle: .alert)
        let alertDeleteConfirmAction = UIAlertAction(title: "확인", style: .default) { action in
            // 파이어스토어 "recruitTables" 데이터 삭제
            
            self.db.collection("recruitTables").document(self.mainPostInformation!.documentId).delete { (error) in
                guard error == nil else { return }
             }
            
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
                                    return
                                }
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
            let announceDeleteAlertController = UIAlertController(title: nil, message: "삭제 되었습니다.", preferredStyle: .alert)
            self.present(announceDeleteAlertController, animated: true) {
                self.dismiss(animated: true) {
                self.performSegue(withIdentifier: "unwindMainView", sender: nil)
                }
            }
        }
        let alertDeleteCancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        confirmDeleteAlertController.addAction(alertDeleteCancelAction)
        confirmDeleteAlertController.addAction(alertDeleteConfirmAction)
        present(confirmDeleteAlertController, animated: true, completion: nil)
    }
    
    // 차단하기 버튼이 눌렸을 때 호출
    private func blockAbusiveUserButtonTapped() {
        let blockAbusiveUserAlertController = UIAlertController(title: "차단하기", message: "해당 사용자의 글이 모두 차단됩니다.", preferredStyle: .alert)
        let blockAbusiveUserAction = UIAlertAction(title: "확인", style: .default) { action in
            self.sendBlockAbusiveUserListToServer()
            let announceBlockAlertController = UIAlertController(title: nil, message: "차단되었습니다.", preferredStyle: .alert)
            self.present(announceBlockAlertController, animated: true) {
                self.dismiss(animated: true) {
                self.performSegue(withIdentifier: "unwindMainView", sender: nil)
                }
            }
        }
        let blockAbusiveUserCancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        blockAbusiveUserAlertController.addAction(blockAbusiveUserCancelAction)
        blockAbusiveUserAlertController.addAction(blockAbusiveUserAction)
        self.present(blockAbusiveUserAlertController, animated: true, completion: nil)
    }
    
    // 차단하는 메소드 -> firestore user 컬렉션에 차단리스트를 업데이트
    private func sendBlockAbusiveUserListToServer() {
        let userRef = self.db.collection("users").document(Auth.auth().currentUser!.uid)
        userRef.getDocument { (snapShot, error) in
            if error != nil {
                print("error")
            } else {
                guard var blockAbusiveUserList: [String] = snapShot?["blockAbusiveUserList"] as? [String] else {
                    userRef.updateData(["blockAbusiveUserList" : [self.mainPostInformation?.WriteUid]])
                    return
                }
                    blockAbusiveUserList.append(self.mainPostInformation?.WriteUid ?? "")
                    userRef.updateData(["blockAbusiveUserList" : blockAbusiveUserList])
            }
        }
    }
    
    // 신고사유 선택하는 메소드
    private func choiceReasonForReport() {
        let reasonForReportAlertController = UIAlertController(title: "신고사유", message: nil, preferredStyle: .actionSheet)
        let firstReasonForReportAction = UIAlertAction(title: "욕설/비하", style: .default) { action in
            let confirmReportAlertController = UIAlertController(title: "욕설/비하", message: "관리자가 확인 후 해당 글 삭제 및 작성자 제재조치 합니다.", preferredStyle: .alert)
            let reportCancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            let reportConfirmAction = UIAlertAction(title: "확인", style: .default) { action in
                self.reasonForReport = "욕설/비하"
                self.updateReportInformation()
                let announceReportAlertController = UIAlertController(title: nil, message: "신고 접수 되었습니다.", preferredStyle: .alert)
                self.present(announceReportAlertController, animated: true) {
                    self.dismiss(animated: true, completion: nil)
                }
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                    self.saveInappositePostToServer()
                    }
            }
            confirmReportAlertController.addAction(reportCancelAction)
            confirmReportAlertController.addAction(reportConfirmAction)
            self.present(confirmReportAlertController, animated: true, completion: nil)
        }
        let secondReasonForReportAction = UIAlertAction(title: "정치적 발언", style: .default) { action in
            let confirmReportAlertController = UIAlertController(title: "정치적 발언", message: "관리자가 확인 후 해당 글 삭제 및 작성자 제재조치 합니다.", preferredStyle: .alert)
            let reportCancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            let reportConfirmAction = UIAlertAction(title: "확인", style: .default) { action in
                self.reasonForReport = "정치적 발언"
                self.updateReportInformation()
                let announceReportAlertController = UIAlertController(title: nil, message: "신고 접수 되었습니다.", preferredStyle: .alert)
                self.present(announceReportAlertController, animated: true) {
                    self.dismiss(animated: true, completion: nil)
                }
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                    self.saveInappositePostToServer()
                    }
            }
            confirmReportAlertController.addAction(reportCancelAction)
            confirmReportAlertController.addAction(reportConfirmAction)
            self.present(confirmReportAlertController, animated: true, completion: nil)
        }
        let thirdReasonForReportAction = UIAlertAction(title: "음란물/불건전한 만남 및 대화", style: .default) { action in
            let confirmReportAlertController = UIAlertController(title: "음란물/불건전한 만남 및 대화", message: "관리자가 확인 후 해당 글 삭제 및 작성자 제재조치 합니다.", preferredStyle: .alert)
            let reportCancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            let reportConfirmAction = UIAlertAction(title: "확인", style: .default) { action in
                self.reasonForReport = "음란물/불건전한 만남 및 대화"
                self.updateReportInformation()
                let announceReportAlertController = UIAlertController(title: nil, message: "신고 접수 되었습니다.", preferredStyle: .alert)
                self.present(announceReportAlertController, animated: true) {
                    self.dismiss(animated: true, completion: nil)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                    self.saveInappositePostToServer()
                    }
                    }
            }
            confirmReportAlertController.addAction(reportCancelAction)
            confirmReportAlertController.addAction(reportConfirmAction)
            self.present(confirmReportAlertController, animated: true, completion: nil)
        }
        let fourthReasonForReportAction = UIAlertAction(title: "사기/낚시", style: .default) { action in
            let confirmReportAlertController = UIAlertController(title: "사기/낚시", message: "관리자가 확인 후 해당 글 삭제 및 작성자 제재조치 합니다.", preferredStyle: .alert)
            let reportCancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            let reportConfirmAction = UIAlertAction(title: "확인", style: .default) { action in
                self.reasonForReport = "사기/낚시"
                self.updateReportInformation()
                let announceReportAlertController = UIAlertController(title: nil, message: "신고 접수 되었습니다.", preferredStyle: .alert)
                self.present(announceReportAlertController, animated: true) {
                    self.dismiss(animated: true, completion: nil)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                    self.saveInappositePostToServer()
                    }
                    }
            }
            confirmReportAlertController.addAction(reportCancelAction)
            confirmReportAlertController.addAction(reportConfirmAction)
            self.present(confirmReportAlertController, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        reasonForReportAlertController.addAction(firstReasonForReportAction)
        reasonForReportAlertController.addAction(secondReasonForReportAction)
        reasonForReportAlertController.addAction(thirdReasonForReportAction)
        reasonForReportAlertController.addAction(fourthReasonForReportAction)
        reasonForReportAlertController.addAction(cancelAction)
        present(reasonForReportAlertController, animated: true, completion: nil)
    }
    
    // 신고된 게시글을 서버에 저장하는 메소드
    private func saveInappositePostToServer() {
        let reportDocumentRef = db.collection("reportList").document()
        let reportData: [String : Any] = ["신고자이름" : self.reportInformation.reporterName, "신고자학번" : self.reportInformation.reporterStudentNumber, "신고자이메일" : self.reportInformation.reporterEmail, "신고사유" : self.reportInformation.reasonForReport, "신고시간" : self.reportInformation.reportTime, "신고된게시글작성자" : self.reportInformation.reportPostWriterName, "신고된게시글작성자학번" : self.reportInformation.reportPostWriterStudentNumber, "신고된게시글작성자이메일" : self.reportInformation.reportPostWriterEmail, "신고된게시글제목" : self.reportInformation.reportPostTitle, "신고된게시글내용" : self.reportInformation.reportPostNoteText]
        reportDocumentRef.setData(reportData)
    }
    
    // 신고된 게시글을 서버에 저장하기 전 해당 게시글의 정보를 수집하는 메소드
    private func updateReportInformation() {
        updateReporterInformationFromServer()
        updateReportPostWriterInformation()
        updateReportDate()
        self.reportInformation.reportPostTitle = self.mainPostInformation?.postTitle ?? ""
        self.reportInformation.reportPostNoteText = self.mainPostInformation?.postNoteText ?? ""
        self.reportInformation.reasonForReport = self.reasonForReport!
        

    }
    
    // 신고 시간 계산하는 메소드
    private func updateReportDate() {
        let reportDateInformation = Date(timeIntervalSince1970: NSNumber(value: Date().timeIntervalSince1970) as! TimeInterval)
        let calender = Calendar.current
        let reportYear = calender.component(.year, from: reportDateInformation)
        let reportMonth = calender.component(.month, from: reportDateInformation)
        let reportDay = calender.component(.day, from: reportDateInformation)
        let reportHour = calender.component(.hour, from: reportDateInformation)
        let reportMinute = calender.component(.minute, from: reportDateInformation)
        self.reportInformation.reportTime = "\(reportYear)년 \(reportMonth)월 \(reportDay)일 \(reportHour):\(reportMinute)"
    }
    
    // 신고자의 정보를 불러오는 메소드
    private func updateReporterInformationFromServer() {
        self.db.collection("users").document(Auth.auth().currentUser?.uid ?? "").getDocument { (snapShot, error) in
            if error != nil {
                print("error")
            } else {
                guard let snapShot = snapShot?.data() else { return }
                let reporterName = snapShot["userName"] as! String
                let reporterStudentNumber = snapShot["studentNumber"] as! String
                let reporterEmail = snapShot["email"] as! String
                self.reportInformation.reporterName = reporterName
                self.reportInformation.reporterStudentNumber = reporterStudentNumber
                self.reportInformation.reporterEmail = reporterEmail
            }
        }
    }
    
    // 신고된 게시글의 작성자의 정보를 불러오는 메소드
    private func updateReportPostWriterInformation() {
        self.db.collection("users").document(self.mainPostInformation?.WriteUid ?? "").getDocument { (snapShot, error) in
            if error != nil {
                print("error")
            } else {
                guard let snapShot = snapShot?.data() else { return }
                let reportPostWriterName = snapShot["userName"] as! String
                let reportPostWriterStudentNumber = snapShot["studentNumber"] as! String
                let reportPostWriterEmail = snapShot["email"] as! String
                self.reportInformation.reportPostWriterName = reportPostWriterName
                self.reportInformation.reportPostWriterStudentNumber = reportPostWriterStudentNumber
                self.reportInformation.reportPostWriterEmail = reportPostWriterEmail
            }
        }
    }
    
    func participateButtonUpdateUI() {
        
        participateButton.layer.cornerRadius = 6

        participateButton.layer.backgroundColor = UIColor(displayP3Red: 142/255, green: 160/255, blue: 207/255, alpha: 1).cgColor
        
        participateButton.layer.borderColor = UIColor(displayP3Red: 142/255, green: 160/255, blue: 207/255, alpha: 1).cgColor
        
        participateButton.layer.borderWidth = 1.0
        
        includeParticipateButtonView.layer.cornerRadius = 6

        guard let currentUid = FirebaseDataService.instance.currentUserUid else {return}
        var array:[String] = []

        // 사용자 or 작성자 -> 버튼 비활성화
        FirebaseDataService.instance.userRef.child(currentUid).child("groups").getData(completion: { (error,snapshot) in
            if let dict = snapshot.value as? Dictionary<String,AnyObject>{
                for (key, _) in dict{
                    array.append(key)

                    if array.contains(self.mainPostInformation!.documentId) == true {
                        self.participateButton.backgroundColor = .gray
                        self.participateButton.setTitle("참여중", for: .normal)
                        self.participateButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
                        self.participateButton.isEnabled = false
                    }
                }
            }
        })
        
//            self.mainPostInformation!.WriteUid == FirebaseDataService.instance.currentUserUid{
//            self.participateButton.backgroundColor = .gray
//            self.participateButton.setTitle("작성자", for: .normal)
//            self.participateButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
//            self.participateButton.isEnabled = false
//        }



    }
    
    func sendData(mainPostInformation: RecruitingText) {
        self.mainPostInformation = mainPostInformation
        navigationBar.title = mainPostInformation.postTitle
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "send"), object: mainPostInformation)
    }
    
//    func moreOptionButtonUpdateUI() {
//        if mainPostInformation?.WriteUid != Auth.auth().currentUser?.uid {
//            moreOptionButton.isEnabled = false
//        }
//    }
    
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


