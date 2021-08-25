//
//  PostViewController.swift
//  DormitoryForDelivery
//
//  Created by 이태영 on 2021/08/15.
//

import UIKit

class PostViewController: UIViewController {
    
    @IBOutlet weak var includeParticipateButtonView: UIView!
    @IBOutlet weak var participateButton: UIButton!
    @IBOutlet weak var currentNumberOfParticipants: UILabel!
    @IBOutlet weak var currentParticipantsProgressView: UIProgressView!
    
    var mainPostInformation: RecruitingText?


    override func viewDidLoad() {
        super.viewDidLoad()
        
        setIncludeParticipateButtonView()
        setNavigationDesign()
        setButtonStatus()
        setNumberOfParticipants()
        setCurrentParticipantsProgressView()
        
    }
    
    @IBAction func participateButtonTapped(_ sender: Any) {
        let participateAlertController = UIAlertController(title: "주문에 참여하시겠습니까?", message: "주문 참여 시 채팅방에 초대됩니다.", preferredStyle: .alert)
        let alertCancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        let alertOkayAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        participateAlertController.addAction(alertCancelAction)
        participateAlertController.addAction(alertOkayAction)
        present(participateAlertController, animated: true, completion: nil)
    }
    
    func setButtonStatus() {
        participateButton.backgroundColor = .systemBlue
        participateButton.layer.cornerRadius = 4
    }
    
    func setNavigationDesign() {
        // 네비게이션바 디자인 설정
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
    }
    
    func setIncludeParticipateButtonView() {
        includeParticipateButtonView.layer.addBorder([.top], color: UIColor.gray, width: 1.0)
    }
    
    func setNumberOfParticipants() {
        guard let mainPostInformation = mainPostInformation else { return }
        let currentParticipantsPercentage = Int(100 * Float(mainPostInformation.currentNumber) / Float(mainPostInformation.maximumNumber))
        currentNumberOfParticipants.text = "\(currentParticipantsPercentage)%"
    }
    
    func setCurrentParticipantsProgressView() {
        currentParticipantsProgressView.progressViewStyle = .default
        guard let mainPostInformation = mainPostInformation else { return }
        let currentParticipantsPercentage = 100 * Float(mainPostInformation.currentNumber) / Float(mainPostInformation.maximumNumber)
        self.currentParticipantsProgressView.(currentParticipantsPercentage, animated: true)
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(mainPostInformation)
        if segue.identifier == "sendPostInformation" {
            let destinationViewController = segue.destination as? PostTableViewController
            destinationViewController?.mainPostInformation = self.mainPostInformation
        }
    }


}
