//
//  PostTableViewController.swift
//  DormitoryForDelivery
//
//  Created by 이태영 on 2021/08/15.
//

import UIKit
import Foundation
import FirebaseFirestore

class PostTableViewController: UITableViewController {
    
    let db: Firestore = Firestore.firestore()
    
    var mainPostInformation: RecruitingText?
    
    var rowHeight: CGFloat?
    
    var writerName: String = ""

    // 테두리 색변경
    @IBOutlet weak var recruitInformationView: UIView!
    // 모집 정보들 기입하는 뷰
    @IBOutlet weak var recruitInformationListVIew: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var postWriterNameLabel: UILabel!
    @IBOutlet weak var postCreatTimeLabel: UILabel!
    @IBOutlet weak var recruitMemberNumberLabel: UILabel!
    @IBOutlet weak var orderTimeLabel: UILabel!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        readWriterNameFromServer()
        tableView.allowsSelection = false
        postTextView.isScrollEnabled = false
        recruitInformationView.layer.addBorder([.top], color: UIColor.opaqueSeparator, width: 1.0)

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "send"), object: nil)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 77
    }
    
    // 수정 데이터 전달받기
    
    @objc func loadList(_ notification : NSNotification)
    {
        let data = notification.object as? RecruitingText ?? nil
        self.mainPostInformation = data
        updateUI()
        self.tableView.reloadData()
    }
    
    private func updateUI() {
        guard let mainPostInformation = mainPostInformation else { return }
        self.recruitInformationListVIew.layer.cornerRadius = 6
        updateWritingDate()
        print(mainPostInformation)
        titleLabel.text = mainPostInformation.postTitle
        orderTimeLabel.text = mainPostInformation.meetingTime
        recruitMemberNumberLabel.text = "\(mainPostInformation.currentNumber) / \(mainPostInformation.maximumNumber)"
        postTextView.text = mainPostInformation.postNoteText
        categoryLabel.text = mainPostInformation.categories
        postWriterNameLabel.text = self.writerName
        
    }
    
    private func updateWritingDate() {
        let writingDateInformation = Date(timeIntervalSince1970: self.mainPostInformation?.timestamp as! TimeInterval)
        let calender = Calendar.current
        let writingYear = calender.component(.year, from: writingDateInformation)
        let writingMonth = calender.component(.month, from: writingDateInformation)
        let writingDay = calender.component(.day, from: writingDateInformation)
        let writingHour = calender.component(.hour, from: writingDateInformation)
        let writingMinute = calender.component(.minute, from: writingDateInformation)
        self.postCreatTimeLabel.text = "\(writingYear)년 \(writingMonth)월 \(writingDay)일 \(writingHour):\(writingMinute)"
    }
    
    private func readWriterNameFromServer() {
        self.db.collection("users").document(self.mainPostInformation?.WriteUid ?? "").getDocument { (snapShot, error) in
            if error != nil {
                print("error")
            } else {
                guard let snapShot = snapShot?.data() else { return }
                let writerName = snapShot["userName"] as! String
                self.writerName = writerName
                self.updateUI()
            }
        }
    }

    // MARK: - Table view data source

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CALayer {
    func addBorder(_ arr_edge: [UIRectEdge], color: UIColor, width: CGFloat) {
        for edge in arr_edge {
            let border = CALayer()
            switch edge {
            case UIRectEdge.top:
                border.frame = CGRect.init(x: 0, y: 0, width: frame.width, height: width)
                break
            case UIRectEdge.bottom:
                border.frame = CGRect.init(x: 0, y: frame.height - width, width: frame.width, height: width)
                break
            case UIRectEdge.left:
                border.frame = CGRect.init(x: 0, y: 0, width: width, height: frame.height)
                break
            case UIRectEdge.right:
                border.frame = CGRect.init(x: frame.width - width, y: 0, width: width, height: frame.height)
                break
            default:
                break
            }
            border.backgroundColor = color.cgColor;
            self.addSublayer(border)
        }
    }
}
