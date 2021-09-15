//
//  PostTableViewController.swift
//  DormitoryForDelivery
//
//  Created by 이태영 on 2021/08/15.
//

import UIKit

class PostTableViewController: UITableViewController {
    
    @IBOutlet weak var userNickNameLabel:UILabel!
    @IBOutlet weak var postContentTextView: UITextView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var meetingTimeLabel: UILabel!
    
    var mainPostInformation: RecruitingText?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelection = false
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "send"), object: nil)
    }

    func updateUI() {
        guard let mainPostInformation = mainPostInformation else { return }
        
        //postCategoriesLabel.text = "#\(mainPostInformation.categories)"
        postContentTextView.text = mainPostInformation.postNoteText
        progressLabel.text = "\(mainPostInformation.currentNumber) / \(mainPostInformation.maximumNumber)"
        meetingTimeLabel.text = mainPostInformation.meetingTime
    }
    
    // 수정 데이터 전달받기
    
    @objc func loadList(_ notification : NSNotification)
    {
        let data = notification.object as? RecruitingText ?? nil
        print(data)
        self.mainPostInformation = data
        updateUI()
        self.tableView.reloadData()
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
