//
//  ChatRoomViewController.swift
//  DormitoryForDelivery
//
//  Created by 김동현 on 2021/08/23.
//

import UIKit

class ChatRoomViewController: UIViewController, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var item: UINavigationItem!
    @IBOutlet weak var chatCollectionView: UICollectionView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var chatTextField: UITextField!
    var height: CGFloat = 0.0
    var messages: [ChatMessage] = [ChatMessage(fromUserId: "", text: "", timestamp: 0)]
    
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
    
    // MARK: - CellForItemAt
    // cellForItemAt
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let chatMessageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "chatMessageCell", for: indexPath) as! ChatMessageCell
        let chatMessageLeftTimeCell = collectionView.dequeueReusableCell(withReuseIdentifier: "chatLeftTimeCell", for: indexPath) as! ChatMessageLeftTimeCell
        let chatMessageRightTimeCell = collectionView.dequeueReusableCell(withReuseIdentifier: "chatRightTimeCell", for: indexPath) as! ChatMessageRightTimeCell
        let chatMessageAndUserCell = collectionView.dequeueReusableCell(withReuseIdentifier: "chatMessageAndUserCell", for: indexPath) as! ChatMessageAndUserCell
        let chatMessageRightTimeAndUserCell = collectionView.dequeueReusableCell(withReuseIdentifier: "chatRightTimeAndUserCell", for: indexPath) as! ChatMessageRightTimeAndUserCell
        
        let message = messages[indexPath.item]
        let messagesCount = messages.count
        
        chatMessageCell.textLabel.text = message.text
        chatMessageLeftTimeCell.textLabel.text = message.text
        chatMessageRightTimeCell.textLabel.text = message.text
        chatMessageAndUserCell.textLabel.text = message.text
        chatMessageRightTimeAndUserCell.textLabel.text = message.text
        
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
                                setupChatCell(cell: chatMessageCell, message: message)
                                return chatMessageCell
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
    
    // sizeForItemAt
    func setupChatCell(cell: ChatMessageCell, message: ChatMessage) {
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
    
    func setupChatLeftTimeCell(cell: ChatMessageLeftTimeCell, message: ChatMessage){
        cell.containerView.backgroundColor = UIColor(red: 69/255, green: 141/255, blue: 245/255, alpha: 1)
        cell.textLabel.textColor = UIColor.white
    }
    
    func setupChatRightTimeCell(cell: ChatMessageRightTimeCell, message: ChatMessage){
        cell.containerView.backgroundColor = UIColor.white
        cell.textLabel.textColor = UIColor.black
    }
    
    func setupChatAndUserCell(cell: ChatMessageAndUserCell, message: ChatMessage) {
        cell.containerView.backgroundColor = UIColor.white
        cell.textLabel.textColor = UIColor.black
    }
    
    func setupChatRightTimeAndUserCell(cell: ChatMessageRightTimeAndUserCell, message: ChatMessage){
        cell.containerView.backgroundColor = UIColor.white
        cell.textLabel.textColor = UIColor.black
    }
   
    
    func fetchMeetingTime(meetingTime: NSNumber) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_kr")
        dateFormatter.dateFormat = "a h:mm"
        
        return dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(truncating: meetingTime)))
    }
    // MARK: - SetupCell
    
    // 텍스트 줄변경시 메시지의 높이를 동적으로 변경해줌
    private func measuredFrameHeightForEachMessage(message: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: message).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    @IBAction func sendButtonTapped(_ sender: UIButton){
        guard let fromUserId = FirebaseDataService.instance.currentUserUid else {
            return
        }
        
        let data: Dictionary<String, AnyObject> = [
            "fromUserId" : fromUserId as AnyObject,
            "text" : chatTextField.text! as AnyObject,
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
        if let groupId = self.groupKey {
            let groupMessageRef = FirebaseDataService.instance.groupRef.child(groupId).child("messages")
           
            groupMessageRef.observe(.childAdded, with: { (snapshot) in
                if let dict = snapshot.value as? Dictionary<String, AnyObject> {
                    let message = ChatMessage(
                        fromUserId: dict["fromUserId"] as! String,
                        text: dict["text"] as! String,
                        timestamp: dict["timestamp"] as! NSNumber
                    )
                    self.messages.insert(message, at: self.messages.count - 1)
                    self.chatCollectionView.reloadData()
                    self.chatCollectionView.layoutIfNeeded()
                    if self.messages.count >= 1 {
                        let indexPath = IndexPath(item: self.messages.count - 2, section: 0)
                        self.chatCollectionView.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.bottom, animated: true)
                    }
                    //self.chatCollectionView.frame.origin.y = self.height
                }
            })
        }
    }
    
    // get keyboard height and shift the view from bottom to higher
    @objc func keyboardWillShow(_ notification: Notification) {
        if chatTextField.isFirstResponder {
            height = getKeyboardHeight(notification)
            let tabBarHeight = self.tabBarController!.tabBar.frame.size.height
            view.frame.origin.y = -height + tabBarHeight
            chatCollectionView.contentInset.top = height - tabBarHeight
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if chatTextField.isFirstResponder {
            view.frame.origin.y = 0
            chatCollectionView.contentInset.top = 0
        }
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        print(keyboardSize.cgRectValue.height)
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
