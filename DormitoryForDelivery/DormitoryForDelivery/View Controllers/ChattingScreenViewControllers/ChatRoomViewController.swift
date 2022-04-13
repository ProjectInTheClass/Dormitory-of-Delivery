//
//  ChatRoomViewController.swift
//  DormitoryForDelivery
//
//  Created by 김동현 on 2021/08/23.
//

import UIKit
import Firebase
import FirebaseFirestore

class ChatRoomViewController: UIViewController, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let db: Firestore = Firestore.firestore()
    @IBOutlet weak var item: UINavigationItem!
    @IBOutlet weak var chatCollectionView: UICollectionView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var chatTextField: UITextField!
    @IBOutlet weak var containView: UIView!
    
    var height: CGFloat = 0.0
    var messages: [ChatMessage] = [ChatMessage(fromUserId: "", userID: "", text: "", timestamp: 0)]
    
    // 신고하기에서 선택된 사람
    var selectedReportMemberUid: String = ""
    var reasonForReport: String = ""
    var reportInformation: ReportForm = ReportForm(reasonForReport: "", reportPostWriterName: "", reportPostTitle: "", reportPostNoteText: "", reportPostWriterEmail: "", reportPostWriterStudentNumber: "", reporterName: "", reporterStudentNumber: "", reporterEmail: "", reportTime: "")
    
    
    var groupKey: String? {
        didSet {
            if let key = groupKey {
                fetchMessages()
                FirebaseDataService.instance.groupRef.child(key).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let data = snapshot.value as? Dictionary<String, AnyObject> {
                        if let title = data["name"] as? String{
                            self.item.title = title
                        }
                        if let toId = data["to"] as? String {
                            self.participantId = toId
                        }
                    }
                })
            }
        }
    }
    
    var participantId: String?
    
    // numberOfItemsInSection
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count - 1
    }
    
    


    
    // MARK: - CellForItemAt
    // cellForItemAt
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let chatMessageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "chatMessageCell", for: indexPath) as! ChatMessageCell
        let chatMessageLeftTimeCell = collectionView.dequeueReusableCell(withReuseIdentifier: "chatLeftTimeCell", for: indexPath) as! ChatMessageLeftTimeCell
        let chatMessageRightTimeCell = collectionView.dequeueReusableCell(withReuseIdentifier: "chatRightTimeCell", for: indexPath) as! ChatMessageRightTimeCell
        let chatMessageAndUserCell = collectionView.dequeueReusableCell(withReuseIdentifier: "chatMessageAndUserCell", for: indexPath) as! ChatMessageAndUserCell
        let chatMessageRightTimeAndUserCell = collectionView.dequeueReusableCell(withReuseIdentifier: "chatRightTimeAndUserCell", for: indexPath) as! ChatMessageRightTimeAndUserCell
        let enterenceCell = collectionView.dequeueReusableCell(withReuseIdentifier: "enterenceCell", for: indexPath) as! EnterenceCell
        
        var message = messages[indexPath.item]
        let messagesCount = messages.count
        
        chatMessageCell.textLabel.text = message.text
        chatMessageLeftTimeCell.textLabel.text = message.text
        chatMessageRightTimeCell.textLabel.text = message.text
        chatMessageAndUserCell.textLabel.text = message.text
        chatMessageRightTimeAndUserCell.textLabel.text = message.text
        
        chatMessageAndUserCell.nameLabel.text = message.userID
        chatMessageRightTimeAndUserCell.nameLabel.text = message.userID
        
        chatMessageLeftTimeCell.timeLabel.text = fetchMeetingTime(meetingTime: message.timestamp)
        chatMessageRightTimeCell.timeLabel.text = fetchMeetingTime(meetingTime: message.timestamp)
        chatMessageRightTimeAndUserCell.timeLabel.text = fetchMeetingTime(meetingTime: message.timestamp)
        
        if message.text.count > 0 {
            chatMessageCell.containerViewWidthAnchor?.constant = measuredFrameHeightForEachMessage(message: message.text).width + 25
            chatMessageLeftTimeCell.containerViewWidthAnchor?.constant = measuredFrameHeightForEachMessage(message: message.text).width + 25
            chatMessageRightTimeCell.containerViewWidthAnchor?.constant = measuredFrameHeightForEachMessage(message: message.text).width + 25
            chatMessageAndUserCell.containerViewWidthAnchor?.constant = measuredFrameHeightForEachMessage(message: message.text).width + 25
            chatMessageRightTimeAndUserCell.containerViewWidthAnchor?.constant = measuredFrameHeightForEachMessage(message: message.text).width + 25
        }
        
        guard message.text.contains("/In/") == false else {
            message.text.removeFirst(4)
            enterenceCell.textLabel.text = message.text + "님이 참가했습니다."
            setupEnterenceCell(cell: enterenceCell, message: message)
            return enterenceCell
        }
        
        guard message.text.contains("/Out/") == false else {
            message.text.removeFirst(6)
            enterenceCell.textLabel.text = message.text + "님이 나갔습니다."
            setupEnterenceCell(cell: enterenceCell, message: message)
            return enterenceCell
        }
        
        //메세지가 한개밖에 없는경우 즉, 첫메세지 = 마지막메세지
        if indexPath.row == 0 && indexPath.row == messagesCount - 2{
            if message.fromUserId == FirebaseDataService.instance.currentUserUid {
                setupChatLeftTimeCell(cell: chatMessageLeftTimeCell, message: message)
                return chatMessageLeftTimeCell
            } else {
                return chatMessageRightTimeAndUserCell
            }
        //메세지가 두개이상일때, 마지막메세지가 아닐 경우
        } else if indexPath.row != messagesCount - 2 {
            if message.fromUserId == FirebaseDataService.instance.currentUserUid {
                if indexPath.row == 0{
                    if messages[indexPath.row].fromUserId == messages[indexPath.row + 1].fromUserId {
                        if fetchMeetingTime(meetingTime: messages[indexPath.row].timestamp) == fetchMeetingTime(meetingTime: messages[indexPath.row + 1].timestamp){
                            setupChatCell(cell: chatMessageCell, message: message)
                            return chatMessageCell
                        } else {
                            setupChatLeftTimeCell(cell: chatMessageLeftTimeCell, message: message)
                            return chatMessageLeftTimeCell
                        }
                    } else {
                        setupChatLeftTimeCell(cell: chatMessageLeftTimeCell, message: message)
                        return chatMessageLeftTimeCell
                    }
                } else {
                    if messages[indexPath.row].fromUserId == messages[indexPath.row - 1].fromUserId {
                        // 내가글쓰고 이전글이 내가쓴글
                        if messages[indexPath.row].fromUserId == messages[indexPath.row + 1].fromUserId {
                            if fetchMeetingTime(meetingTime: messages[indexPath.row].timestamp) == fetchMeetingTime(meetingTime: messages[indexPath.row + 1].timestamp) {
                                setupChatCell(cell: chatMessageCell, message: message)
                                return chatMessageCell
                            } else {
                                setupChatLeftTimeCell(cell: chatMessageLeftTimeCell, message: message)
                                return chatMessageLeftTimeCell
                            }
                        } else {
                            setupChatLeftTimeCell(cell: chatMessageLeftTimeCell, message: message)
                            return chatMessageLeftTimeCell
                        }
                    } else {
                        // 내가글쓰고 이전글이 상대방이쓴글
                        if messages[indexPath.row].fromUserId == messages[indexPath.row + 1].fromUserId {
                            // 다음글이 내가쓴글
                            if fetchMeetingTime(meetingTime: messages[indexPath.row].timestamp) == fetchMeetingTime(meetingTime: messages[indexPath.row + 1].timestamp) {
                                setupChatCell(cell: chatMessageCell, message: message)
                                return chatMessageCell
                            } else {
                                setupChatLeftTimeCell(cell: chatMessageLeftTimeCell, message: message)
                                return chatMessageLeftTimeCell
                            }
                        } else {
                            // 다음글이 상대방이쓴글
                            setupChatLeftTimeCell(cell: chatMessageLeftTimeCell, message: message)
                            return chatMessageLeftTimeCell
                        }
                    }
                }
            } else {
                //상대방(들)이 쓴글
                if indexPath.row == 0{
                    if messages[indexPath.row].fromUserId == messages[indexPath.row + 1].fromUserId {
                        if fetchMeetingTime(meetingTime: messages[indexPath.row].timestamp) == fetchMeetingTime(meetingTime: messages[indexPath.row + 1].timestamp) {
                            setupChatAndUserCell(cell: chatMessageAndUserCell, message: message)
                            return chatMessageAndUserCell
                        } else {
                            setupChatRightTimeAndUserCell(cell: chatMessageRightTimeAndUserCell, message: message)
                            return chatMessageRightTimeAndUserCell
                        }
                    } else {
                        setupChatRightTimeAndUserCell(cell: chatMessageRightTimeAndUserCell, message: message)
                        return chatMessageRightTimeAndUserCell
                    }
                } else {
                    if messages[indexPath.row].fromUserId == messages[indexPath.row - 1].fromUserId {
                        //상대방이 글쓰고 이전글이 같은사람
                        if messages[indexPath.row].fromUserId == messages[indexPath.row + 1].fromUserId {
                            if fetchMeetingTime(meetingTime: messages[indexPath.row].timestamp) == fetchMeetingTime(meetingTime: messages[indexPath.row + 1].timestamp) {
                                if messages[indexPath.row + 1].text.contains("/Out/"){
                                    setupChatRightTimeCell(cell: chatMessageRightTimeCell, message: message)
                                    return chatMessageRightTimeCell
                                } else {
                                    setupChatCell(cell: chatMessageCell, message: message)
                                    return chatMessageCell
                                }
                            } else {
                                setupChatRightTimeCell(cell: chatMessageRightTimeCell, message: message)
                                return chatMessageRightTimeCell
                            }
                        } else {
                            setupChatRightTimeCell(cell: chatMessageRightTimeCell, message: message)
                            return chatMessageRightTimeCell
                        }
                    } else {
                        //상대방이 글쓰고 이전글이 다른사람
                        if messages[indexPath.row].fromUserId == messages[indexPath.row + 1].fromUserId {
                            if fetchMeetingTime(meetingTime: messages[indexPath.row].timestamp) == fetchMeetingTime(meetingTime: messages[indexPath.row + 1].timestamp) {
                                setupChatAndUserCell(cell: chatMessageAndUserCell, message: message)
                                return chatMessageAndUserCell
                            } else {
                                setupChatRightTimeAndUserCell(cell: chatMessageRightTimeAndUserCell, message: message)
                                return chatMessageRightTimeAndUserCell
                            }
                        } else {
                            setupChatRightTimeAndUserCell(cell: chatMessageRightTimeAndUserCell, message: message)
                            return chatMessageRightTimeAndUserCell
                        }
                    }
                }
            }
        //메세지가 두개이상일때, 마지막메세지일 경우
        } else {
            if message.fromUserId == FirebaseDataService.instance.currentUserUid {
                setupChatLeftTimeCell(cell: chatMessageLeftTimeCell, message: message)
                return chatMessageLeftTimeCell
            } else {
                if messages[indexPath.row].fromUserId == messages[indexPath.row - 1].fromUserId{
                    return chatMessageRightTimeCell
                } else {
                    return chatMessageRightTimeAndUserCell
                }
            }
        }
    }
    // MARK: - SetupCell
    
    // 텍스트 줄변경시 메시지의 높이를 동적으로 변경해줌
    private func measuredFrameHeightForEachMessage(message: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: message).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)], context: nil)
    }
    
    
    @IBAction func sendButtonTapped(_ sender: UIButton){
        guard let fromUserId = FirebaseDataService.instance.currentUserUid else { return }
        
        //userID구해오기
        FirebaseDataService.instance.userRef.child(fromUserId).child("userID").getData { (error,snapshot) in
            guard error == nil else { return }
            let userID = snapshot.value as! String
            let data: Dictionary<String, AnyObject> = [
                "fromUserId" : fromUserId as AnyObject,
                "userID" : userID as AnyObject,
                "text" : self.chatTextField.text! as AnyObject,
                "timestamp" : NSNumber(value: Date().timeIntervalSince1970)
            ]
            
            if let groupId = self.groupKey {
                let ref = FirebaseDataService.instance.groupRef.child(groupId).child("messages").childByAutoId()
                ref.updateChildValues(data) { (error, ref) in
                    guard error == nil else {
                        print(error as Any)
                        return
                    }
                    
                    FirebaseDataService.instance.groupRef.child(groupId).child("lastMessage").setValue(self.chatTextField.text)
                    self.chatTextField.text = nil
                }
            }
            
        }
    }
    
    @IBAction func collectionViewTapped(_ sender: Any) {
        chatTextField.resignFirstResponder()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        chatCollectionView.delegate = self
        chatCollectionView.dataSource = self
        chatTextField.delegate = self
        let layout = chatCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.estimatedItemSize.width = view.frame.width
        chatCollectionView.alwaysBounceVertical = true
        sendButton.isEnabled = false
        layout.minimumLineSpacing = 1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationbarUI()
        subscribeToKeyboardNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func fetchMessages() {
        // enterenceTiemstemp initialize
        var enterenceTimestemp: NSNumber = 0
        let uid = FirebaseDataService.instance.currentUserUid!
        FirebaseDataService.instance.userRef.child(uid).child("groups").getData { (error, snapshot) in
            guard error == nil else { return }
            let item = snapshot.value as! [String: Any]
            enterenceTimestemp = item[self.groupKey!] as! NSNumber
        }
        
        if let groupId = self.groupKey {
            let groupMessageRef = FirebaseDataService.instance.groupRef.child(groupId).child("messages")
            groupMessageRef.observe(.childAdded, with: { (snapshot) in
                if let dict = snapshot.value as? Dictionary<String, AnyObject> {
                    let message = ChatMessage(
                        fromUserId: dict["fromUserId"] as! String,
                        userID: dict["userID"] as! String,
                        text: dict["text"] as! String,
                        timestamp: dict["timestamp"] as! NSNumber
                    )
                    // 채팅방 참가시간보다 이전메세지는 불러오지않음
                    self.compareTimestamp(message: message, fromUserId: dict["fromUserId"] as! String, enterenceTimestemp: enterenceTimestemp)
                    
                    if self.messages.count >= 1 {
                        let indexPath = IndexPath(item: self.messages.count - 2, section: 0)
                        //화면이 제일 밑에서 3~4개정도 위에있을때만 제일 하단으로 스크롤되게 변경
                        // 추가사항 : 채팅방으로 첫진입시 젤밑으로 or 전에 읽었던데 까지  => 로컬로 위치데이터넣고 다른함수 추가로 사용해야 가능할
                        guard let navigationBarHeight = self.navigationController?.navigationBar.frame.height else { return }
                        if self.chatCollectionView.frame.height + 150 >= self.chatCollectionView.contentSize.height - self.chatCollectionView.contentOffset.y - navigationBarHeight {
                            self.chatCollectionView.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.bottom, animated: false)
                        }
                    }
                }
            })
        }
    }
    
    private func compareTimestamp(message: ChatMessage, fromUserId: String, enterenceTimestemp: NSNumber){
        let messageTimestamp = message.timestamp
        if Double(truncating: messageTimestamp) >= Double(truncating: enterenceTimestemp) {
            self.messages.insert(message, at: self.messages.count - 1)
            self.chatCollectionView.reloadData()
            self.chatCollectionView.layoutIfNeeded()
        }
    }
    
    // get keyboard height and shift the view from bottom to higher
    // MARK: - KEYBOARD Notification
    @objc func keyboardWillShow(_ notification: Notification) {
        height = getKeyboardHeight(notification)
        let tabBarHeight = self.tabBarController!.tabBar.frame.size.height
        view.frame.origin.y = -height + tabBarHeight
        containView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -tabBarHeight).isActive = true
        chatCollectionView.contentInset.top = height - tabBarHeight
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        height = getKeyboardHeight(notification)
        view.frame.origin.y = 0
        chatCollectionView.contentInset.top = 0
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        chatTextField.resignFirstResponder()
        return true
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        chatCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var newText: NSString = textField.text! as NSString
        newText = newText.replacingCharacters(in: range, with: string) as NSString
        
        if newText.length < 1 {
            sendButton.isEnabled = false
        } else {
            sendButton.isEnabled = true
        }
        return true
    }

    @IBAction func moreOptionBarButtonTapped(_ sender: Any) {
        let moreOptionAlertController = UIAlertController(title: "채팅방에서 나가기를 하면 대화내용 및 채팅목록에서 삭제됩니다. 채팅방을 나가시겠습니까?", message: nil, preferredStyle: .actionSheet)
        let alertReportChattingAction = UIAlertAction(title: "신고하기", style: .destructive) { action in
            self.reportChatButtonTapped()
        }
        let alertDeletePostAction = UIAlertAction(title: "나가기", style: .destructive) { action in
            self.deleteButtonTapped()
        }
        let alertCancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        moreOptionAlertController.addAction(alertReportChattingAction)
        moreOptionAlertController.addAction(alertDeletePostAction)
        moreOptionAlertController.addAction(alertCancelAction)
        present(moreOptionAlertController, animated: true, completion: nil)
    }
    
    func navigationbarUI() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(named:  "3"), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
    }
    
   
    // MARK: - Navigation
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }*/
}

extension ChatRoomViewController {
    // sizeForItemAt
    private func setupChatCell(cell: ChatMessageCell, message: ChatMessage) {
        if message.fromUserId == FirebaseDataService.instance.currentUserUid {
            cell.containerView.backgroundColor = UIColor(red: 69/255, green: 141/255, blue: 245/255, alpha: 1)
            cell.textLabel.textColor = UIColor.white
            cell.containerViewRightAnchor?.isActive = true
            cell.containerViewLeftAnchor?.isActive = false
        } else {
            cell.containerView.backgroundColor = UIColor.white
            cell.textLabel.textColor = UIColor.black
            cell.containerViewRightAnchor?.isActive = false
            cell.containerViewLeftAnchor?.isActive = true
        }
    }
    
    private func setupChatLeftTimeCell(cell: ChatMessageLeftTimeCell, message: ChatMessage){
        cell.containerView.backgroundColor = UIColor(red: 69/255, green: 141/255, blue: 245/255, alpha: 1)
        cell.textLabel.textColor = UIColor.white
    }
    
    private func setupChatRightTimeCell(cell: ChatMessageRightTimeCell, message: ChatMessage){
        cell.containerView.backgroundColor = UIColor.white
        cell.textLabel.textColor = UIColor.black
    }
    
    private func setupChatAndUserCell(cell: ChatMessageAndUserCell, message: ChatMessage) {
        cell.containerView.backgroundColor = UIColor.white
        cell.textLabel.textColor = UIColor.black
    }
    
    private func setupChatRightTimeAndUserCell(cell: ChatMessageRightTimeAndUserCell, message: ChatMessage){
        cell.containerView.backgroundColor = UIColor.white
        cell.textLabel.textColor = UIColor.black
    }
   
    private func setupEnterenceCell(cell: EnterenceCell, message: ChatMessage){
        cell.containerView.backgroundColor = UIColor(red: 142/255, green: 154/255, blue: 163/255, alpha: 1)
        cell.textLabel.textColor = UIColor.white
    }
    
    private func fetchMeetingTime(meetingTime: NSNumber) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_kr")
        dateFormatter.dateFormat = "a h:mm"
        
        return dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(truncating: meetingTime)))
    }
}


extension ChatRoomViewController {
    // 채팅창 Alert로 채팅방 나갈때 실행
    func deleteButtonTapped() {
        guard let fromUserId = FirebaseDataService.instance.currentUserUid else { return }
        guard let groupId = self.groupKey else { return }
        
        FirebaseDataService.instance.groupRef.child(groupId).getData { (error, snapshot) in
            guard error == nil else { return }
            let item = snapshot.value as! [String: Any]
            let currentNumber = item["currentNumber"] as! Int
            if currentNumber == 1 {
                let doc =  self.db.collection("messageGroup").document(groupId)
                doc.getDocument { (snapshot: DocumentSnapshot?, error: Error?) in
                    guard error == nil else { return }
                    let memberData: [String: [String]] = snapshot!.data() as! [String: [String]]
                    if let memberData = memberData["users"] {
                        for users in memberData {
                            FirebaseDataService.instance.userRef.child(users).child("groups").observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
                                let userRef = FirebaseDataService.instance.userRef.child(users)
                                var item = snapshot.value as! [String: Any]
                                print(item)
                                item.removeValue(forKey: FirebaseDataService.instance.currentUserUid!)
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
                    self.db.collection("messageGroup").document(groupId).delete { (error) in
                        guard error == nil else { return }
                     }
                }
                self.db.collection("recruitTables").document(groupId).delete { (error) in
                    guard error == nil else { return }
                 }
                FirebaseDataService.instance.groupRef.child(groupId).removeValue()
            } else {
                // retimeDB - userRef 읽기
                FirebaseDataService.instance.userRef.child(fromUserId).getData { (error,snapshot) in
                    guard error == nil else { return }
                    let item = snapshot.value as! [String: Any]
                    
                    var groups = item["groups"] as! [String: Any]
                    let userID = item["userID"] as! String
                    
                    let data: Dictionary<String, AnyObject> = [
                        "fromUserId" : "System" as AnyObject,
                        "userID" : userID as AnyObject,
                        "text" : "/Out/ \(userID)" as AnyObject,
                        "timestamp" : NSNumber(value: Date().timeIntervalSince1970)
                    ]
                    
                    // 현재 접속중인 groupRef 읽기
                    let messagesRef = FirebaseDataService.instance.groupRef.child(groupId).child("messages").childByAutoId()
                    // ""/out/ \(userID)"" 메세지 전송
                    messagesRef.updateChildValues(data) { (error, snapshot) in
                        guard error == nil else { return }
                    }
                    
                // 삭제해야할 데이터 #1(groups에서 현재그룹 삭제), #2(db - messageGroup에서 user삭제)
                // 변경해야할 데이터 #3(group에서 현재그룹 currentNumber-1), #4(db - recruitTables - currentNumber-1)
                // #1
                    
                    groups.removeValue(forKey: groupId)
                    let groupsRef = FirebaseDataService.instance.userRef.child(fromUserId)
                    groupsRef.updateChildValues(["groups" : groups])
                }
                
                // #2
                let messageGroupDocument = self.db.collection("messageGroup").document(groupId)
                messageGroupDocument.getDocument { (snapshot: DocumentSnapshot?, error: Error?) in
                    guard error == nil else { return }
                    let item = snapshot!.data() as! [String: [String]]
                    var userDictionary: [String: [String]] = item
                    
                    if var userArray = userDictionary["users"] {
                        if let firstIndex = userArray.firstIndex(of: fromUserId) {
                            userArray.remove(at: firstIndex)
                        }
                        userDictionary.updateValue(userArray, forKey: "users")
                        messageGroupDocument.setData(userDictionary)
                    }
                }
                
                // #3
                FirebaseDataService.instance.groupRef.child(groupId).updateChildValues(["currentNumber" : currentNumber - 1])
                    // #4
                    let recruitTablesDocument = self.db.collection("recruitTables").document(groupId)
                    recruitTablesDocument.getDocument { (snapshot: DocumentSnapshot?, error: Error?) in
                        guard error == nil else { return }
                        var item = snapshot!.data()!
                        let currentNumber = item["currentNumber"] as! Int
                        
                        item.updateValue(currentNumber - 1, forKey: "currentNumber")
                        recruitTablesDocument.setData(item)
        //                }
                    }
                }
            }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func reportChatButtonTapped() {
        guard let groupId = self.groupKey else { return }
        
        let currentUser: String? = FirebaseDataService.instance.currentUserUid
        let groupMemberInformationAlertForReport = UIAlertController(title: "신고하기", message: nil, preferredStyle: .actionSheet)
        let chatGroupMemberDocument = Firestore.firestore().collection("messageGroup").document(groupId)
        let userInformationDocument = Firestore.firestore().collection("users")
        chatGroupMemberDocument.getDocument { (snapShot, error) in
            if error != nil {
                print("error")
            } else if snapShot!.data()?.isEmpty == nil {
                print("snapShot is empty")
            }
            
            else {
                let item = snapShot!.data()!
                guard var groupMembers = item["users"] as? [String] else { return }
                
                groupMembers = groupMembers.filter { $0 != currentUser }
                
                for member in groupMembers {
                    userInformationDocument.document(member).getDocument { (snapShot, error) in
                        if error != nil {
                            print("error")
                        } else {
                            let item = snapShot!.data()!
                            guard let groupMemberId = item["userID"] as? String else { return }
                            let reportGroupMemberAlertAction = UIAlertAction(title: groupMemberId, style: .default) { action in
                                self.reportInformation.reportPostWriterName = item["userName"] as! String
                                self.reportInformation.reportPostWriterStudentNumber = item["studentNumber"] as! String
                                self.reportInformation.reportPostWriterEmail = item["email"] as! String
                                self.choiceReasonForReport()
                            }
                            groupMemberInformationAlertForReport.addAction(reportGroupMemberAlertAction)
                        }

                    }
                }
                let cancelReportAlertAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
                groupMemberInformationAlertForReport.addAction(cancelReportAlertAction)
                self.present(groupMemberInformationAlertForReport, animated: true, completion: nil)
            }
        }
            
    }
    
    private func choiceReasonForReport() {
        let reasonForReportAlertController = UIAlertController(title: "신고사유", message: nil, preferredStyle: .actionSheet)
        let firstReasonForReportAction = UIAlertAction(title: "욕설/비하", style: .default) { action in
            let confirmReportAlertController = UIAlertController(title: "욕설/비하", message: "관리자가 확인 후 해당 글 삭제 및 작성자 제재조치 합니다.", preferredStyle: .alert)
            let reportCancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            let reportConfirmAction = UIAlertAction(title: "확인", style: .default) { action in
                self.reportInformation.reasonForReport = "욕설/비하"
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
                self.reportInformation.reasonForReport = "정치적 발언"
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
                self.reportInformation.reasonForReport = "음란물/불건전한 만남 및 대화"
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
                self.reportInformation.reasonForReport = "사기/낚시"
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

    private func saveInappositePostToServer() {
        let reportDocumentRef = db.collection("chatReportList").document()
        let reportData: [String : Any] = ["신고자이름" : self.reportInformation.reporterName, "신고자학번" : self.reportInformation.reporterStudentNumber, "신고자이메일" : self.reportInformation.reporterEmail, "신고사유" : self.reportInformation.reasonForReport, "신고시간" : self.reportInformation.reportTime, "신고된게시글작성자" : self.reportInformation.reportPostWriterName, "신고된게시글작성자학번" : self.reportInformation.reportPostWriterStudentNumber, "신고된게시글작성자이메일" : self.reportInformation.reportPostWriterEmail, "신고된게시글제목" : self.reportInformation.reportPostTitle, "신고된게시글내용" : self.reportInformation.reportPostNoteText]
        reportDocumentRef.setData(reportData)
    }

    private func updateReportInformation() {
        updateReporterInformationFromServer()
        updateReportPostInformation()
        updateReportDate()
    }

    private func updateReportPostInformation() {
        guard let groupId = self.groupKey else { return }
        self.db.collection("recruitTables").document(groupId).getDocument { (snapShot, error) in
            if error != nil {
                print("error")
            } else {
                guard let snapShot = snapShot?.data() else { return }
                let reportPostName = snapShot["title"] as! String
                let reportPostNoteText = snapShot["noteText"] as! String

                self.reportInformation.reportPostTitle = reportPostName
                self.reportInformation.reportPostNoteText = reportPostNoteText
            }
        }
    }

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
    
    // 신고된 게시글의 작성자의 정보를 불러오는 메소드
    private func updateReporterInformationFromServer() {
        let currentUser: String? = FirebaseDataService.instance.currentUserUid
        self.db.collection("users").document(currentUser!).getDocument { (snapShot, error) in
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
        
}


