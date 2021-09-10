//
//  PostViewController.swift
//  DormitoryForDelivery
//
//  Created by 이태영 on 2021/08/15.
//

import UIKit

protocol PostViewControllerDelegate {
    func currentNumberChanged(currentNumber: Int, selectedIndexPath: Int)
}

class PostViewController: UIViewController {
    
    
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var includeParticipateButtonView: UIView!
    @IBOutlet weak var participateButton: UIButton!
    //@IBOutlet weak var currentNumberOfParticipants: UILabel!
    //@IBOutlet weak var currentParticipantsProgressView: UIProgressView!
    
    var mainPostInformation: RecruitingText?
    
    var selectedIndexPath: Int?
    
    var delegate: PostViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        participateButtonUpdateUI()
        setIncludeParticipateButtonView()
        setButtonStatus()
        
        navigationBar.title = mainPostInformation?.postTitle
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
        let alertDeletePostAction = UIAlertAction(title: "삭제하기", style: .destructive, handler: nil)
        let alertCancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        moreOptionAlertController.addAction(alertEditPostAction)
        moreOptionAlertController.addAction(alertDeletePostAction)
        moreOptionAlertController.addAction(alertCancelAction)
        present(moreOptionAlertController, animated: true, completion: nil)
    }
    
    func setButtonStatus() {
        participateButton.backgroundColor = .systemBlue
        participateButton.layer.cornerRadius = 6
    }
    
    func setIncludeParticipateButtonView() {
        includeParticipateButtonView.layer.addBorder([.top], color: UIColor.gray, width: 1.0)
    }
    
    func participateButtonUpdateUI() {
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
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sendPostInformation" {
            let destinationViewController = segue.destination as? PostTableViewController
            destinationViewController?.mainPostInformation = self.mainPostInformation
        }
    }
}
