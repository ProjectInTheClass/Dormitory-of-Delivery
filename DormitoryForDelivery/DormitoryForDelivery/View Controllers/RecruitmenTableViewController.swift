//
//  RecruitmenTableViewController.swift
//  DormitoryForDelivery
//
//  Created by 김동현 on 2021/08/01.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class RecruitmenTableViewController: UITableViewController, UITextViewDelegate, SelectCategoriesTableViewControllerDelegate, UITextFieldDelegate {
    
    let db:Firestore = Firestore.firestore()
    var chatGroupVC: ChatGroupTableViewController?
    
    var selectedCategories: String?
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var recruitmentCountStepper: UIStepper!
    @IBOutlet weak var numberOfRecruitmentLabel: UILabel!
    @IBOutlet weak var writingDoneButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextField.delegate = self
        noteTextView.delegate = self
        setInputKeyboardType()
        noteTextViewPlaceholderSetting()
        updateNumberOfRecruitmentMember()
        beginingWritingDoneButtonStatusSetting()
    }
    
    func noteTextViewPlaceholderSetting() {
        noteTextView.text = "같이 시켜먹을 배달음식에 대한 설명과 수령 방식 등 배달 공유에 대한 정보를 작성해 주세요."
        noteTextView.textColor = UIColor.lightGray
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if titleTextField.text != nil && noteTextView.text != "같이 시켜먹을 배달음식에 대한 설명과 수령 방식 등 배달 공유에 대한 정보를 작성해 주세요." && noteTextView.text.count > 0 && selectedCategories != nil && recruitmentCountStepper.value > 1 {
            writingDoneButton.isEnabled = true
        } else {
            writingDoneButton.isEnabled = false
        }
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
    
    func beginingWritingDoneButtonStatusSetting() {
        if noteTextView.text == nil || noteTextView.text == "같이 시켜먹을 배달음식에 대한 설명과 수령 방식 등 배달 공유에 대한 정보를 작성해 주세요." {
            writingDoneButton.isEnabled = false
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // 텍스트 필드 리턴 키 델리게이트 처리
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        titleTextField.resignFirstResponder()
        return true
    }
    // 텍스트 뷰 리턴 키 델리게이트 처리
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            noteTextView.resignFirstResponder()
        }
        return true
    }
    
    func setInputKeyboardType() {
        titleTextField.keyboardType = .default
        noteTextView.keyboardType = .default
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

    @IBAction func stepperValueChanged(_ sender: Any) {
        updateNumberOfRecruitmentMember()
    }
    
    
    
    func updateNumberOfRecruitmentMember() {
        numberOfRecruitmentLabel.text = "\(Int(recruitmentCountStepper.value))"
    }
    
    func didSelect(selectedCategories: String) {
        self.selectedCategories = selectedCategories
        categoriesLabel.text = selectedCategories
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
            destinationViewController?.selectedCategories = selectedCategories
        }
        
        if segue.identifier == "unwindToMainView"{
            //ToDo: Type cating으로 경고 수정, 나중에 유저가 그룹참가를 하면 currentNumber를 update하는 코드구현
            let currentNumber = 1
            guard let title = titleTextField.text, let category = categoriesLabel.text, let noteText = noteTextView.text else { return }
            
            let newRecruitTable:Dictionary<String, Any> = ["uid":Auth.auth().currentUser!.uid, "title": title, "category":category, "noteText":noteText, "maximumNumber":recruitmentCountStepper.value,"currentNumber":currentNumber,"timestamp":NSNumber(value: Date().timeIntervalSince1970)]
    
            //fireStore - tables에 작성
            let newRecruitTableRef = db.collection("recruitTables").document()
            newRecruitTableRef.setData(newRecruitTable)
            
            //fireStore - users-table에 작성
            db.collection("users").document(Auth.auth().currentUser!.uid).collection("table").document(newRecruitTableRef.documentID).setData(newRecruitTable)
            
            //RealtimeDB에 user-group & gropu에 추가
            if let uid = FirebaseDataService.instance.currentUserUid {
                let userRef = FirebaseDataService.instance.userRef.child(uid)
                userRef.child("groups").updateChildValues(([newRecruitTableRef.documentID: 1])) { (error, ref) in
                    let groupRef = FirebaseDataService.instance.groupRef.child(newRecruitTableRef.documentID)
                    groupRef.setValue(["name":title, "to":uid, "currentNumber":1, "lastMessage":""])
                    return
                }
            }
            
            
        }
        
    }
   
    
}
