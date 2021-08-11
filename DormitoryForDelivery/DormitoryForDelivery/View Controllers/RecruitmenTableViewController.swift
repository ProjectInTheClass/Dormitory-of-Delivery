//
//  RecruitmenTableViewController.swift
//  DormitoryForDelivery
//
//  Created by 김동현 on 2021/08/01.
//

import UIKit

class RecruitmenTableViewController: UITableViewController, UITextViewDelegate, SelectCategoriesTableViewControllerDelegate {
    
    var selectCategories: String?
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var recruitmentCountStepper: UIStepper!
    @IBOutlet weak var numberOfRecruitmentLabel: UILabel!
    
    
       override func viewDidLoad() {
        super.viewDidLoad()
        noteTextViewPlaceholderSetting()
        updateNumberOfRecruitmentMember()
    }
    
    func noteTextViewPlaceholderSetting() {
        noteTextView.delegate = self // 유저가 선언한 outlet
        noteTextView.text = "같이 시켜먹을 배달음식에 대한 설명과 수령 방식 등 배달 공유에 대한 정보를 작성해 주세요."
        noteTextView.textColor = UIColor.lightGray
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "같이 시켜먹을 배달음식에 대한 설명과 수령 방식 등 배달 공유에 대한 정보를 작성해 주세요."
            textView.textColor = UIColor.lightGray
        }
    }
    
    @IBAction func doneBarButtonTapped(_ sender: UIBarButtonItem) {
        let titleText = titleTextField.text ?? ""
        let noteText = noteTextView.text ?? ""
        let recruitNumber = Int(recruitmentCountStepper.value)
        
        
        print("\(titleText)")
        print("\(noteText)")
        print("\(recruitNumber)")
    }
    
    @IBAction func stepperValueChanged(_ sender: Any) {
        updateNumberOfRecruitmentMember()
    }
    
    func updateNumberOfRecruitmentMember() {
        numberOfRecruitmentLabel.text = "\(Int(recruitmentCountStepper.value))"
    }
    

    
    func didSelect(selectCategories: String) {
        self.selectCategories = selectCategories
        categoriesLabel.text = "#" + selectCategories
    }


    
    
    // MARK: - Table view data source

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


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectCategories" {
            let destinationViewController = segue.destination as? SelectCategoriesTableViewController
            destinationViewController?.delegate = self
            destinationViewController?.selectCategories = selectCategories
        }
        
    }

}
