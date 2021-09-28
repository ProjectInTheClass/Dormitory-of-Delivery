//
//  RecruitmenTableViewController.swift
//  DormitoryForDelivery
//
//  Created by 김동현 on 2021/08/01.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

protocol SendEditDataDelegate {
    func sendData(mainPostInformation: RecruitingText)
}

class RecruitmenTableViewController: UITableViewController, UITextViewDelegate, SelectCategoriesTableViewControllerDelegate, UITextFieldDelegate {

    let db:Firestore = Firestore.firestore()
    
    var chatGroupVC: ChatGroupTableViewController?
    
    var selectedCategories: String?
    
    var mainPostInformation: RecruitingText?
    
    var delegate: SendEditDataDelegate?
    
    let postActivityIndicator = UIActivityIndicatorView()
    
    let postActivityIndicatorLoadingView = UIView()
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var recruitmentCountStepper: UIStepper!
    @IBOutlet weak var numberOfRecruitmentLabel: UILabel!
    @IBOutlet weak var writingDoneButton: UIBarButtonItem!
    
    @IBOutlet weak var meetingDatePicker: UIDatePicker!
    @IBOutlet weak var meetingDateLabel: UILabel!

    
    let meetingTimeDateLabelCellIndexPath = IndexPath(row: 1, section: 0)
    let meetingTimeDatePickerCellIndexPath = IndexPath(row: 2, section: 0)
    let noteTextViewCellIndexPath = IndexPath(row: 5, section: 0)
    var isMeetingTimeDatePickerShown: Bool = false{
        didSet{
            meetingDatePicker.isHidden = !isMeetingTimeDatePickerShown
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        modalPresentationStyle = .fullScreen
        meetingDateLabel.isHidden = true
        tableView.isScrollEnabled = false
        titleTextField.delegate = self
        noteTextView.delegate = self
        
        setInputKeyboardType()
        noteTextViewPlaceholderSetting()
        editModeUIUpdate()
        updateNumberOfRecruitmentMember()
        updateDoneButtonUI()
        setMinimumdateAndMaxmimumdate()
        navigationUI()
    }
    
    func setMinimumdateAndMaxmimumdate() {
        let todayDate = Calendar.current.date(byAdding: .day, value: 0, to: Date())
        
        let tomorrowDate = Calendar.current.date(byAdding: .day, value: +1, to: Date())
        meetingDatePicker.maximumDate = tomorrowDate
        meetingDatePicker.minimumDate = todayDate
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath {
        case meetingTimeDatePickerCellIndexPath:
            if isMeetingTimeDatePickerShown {
                return 216.0
            } else {
                return 0.0
            }
        case noteTextViewCellIndexPath:
            return 300.0
        default:
            return 60.0
        }
    }
    
    // tableView에서 특정Cell을 선택했을때 동작하는 함수
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // meetingTimeDataPickerCell선택시 동작
        switch indexPath {
        case meetingTimeDateLabelCellIndexPath:
            if isMeetingTimeDatePickerShown {
                isMeetingTimeDatePickerShown = false
            } else {
                isMeetingTimeDatePickerShown = true
            }
            tableView.beginUpdates()
            tableView.endUpdates()
        default:
            break
        }
        
    }
    
    func noteTextViewPlaceholderSetting() {
        noteTextView.text = "같이 시켜먹을 배달음식에 대한 설명과 수령 방식 등 배달 공유에 대한 정보를 작성해 주세요."
        noteTextView.textColor = UIColor.lightGray
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updateDoneButtonUI()
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
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        updateDoneButtonUI()
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
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        if self.mainPostInformation != nil {
            self.editMainPostInformation()
            self.delegate?.sendData(mainPostInformation: self.mainPostInformation!)
            dismiss(animated: true) {
                let doc = self.db.collection("recruitTables").document(self.mainPostInformation!.documentId)
                let data: [String : AnyObject] = ["category" : self.categoriesLabel.text as AnyObject, "currentNumber" : self.mainPostInformation?.currentNumber as AnyObject, "maximumNumber" : self.recruitmentCountStepper.value as AnyObject, "meetingTime" : NSNumber(value: self.meetingDatePicker.date.timeIntervalSince1970) as AnyObject, "noteText" : self.noteTextView.text as AnyObject, "timestamp" : NSNumber(value: Date().timeIntervalSince1970) as AnyObject, "title" : self.titleTextField.text as AnyObject]
                doc.setData(data, merge: true) { (error) in
                    guard error == nil else { return }
                }
            }
        } else {
                setLoadingScreen()
                //ToDo: Type cating으로 경고 수정, 나중에 유저가 그룹참가를 하면 currentNumber를 update하는 코드구현
                let currentNumber = 1
                guard let title = self.titleTextField.text, let category = self.categoriesLabel.text, let noteText = self.noteTextView.text else { return }
                
                let newRecruitTable:Dictionary<String, Any> = ["uid":Auth.auth().currentUser!.uid, "title": title, "category":category, "noteText":noteText, "maximumNumber":self.recruitmentCountStepper.value,"currentNumber":currentNumber,"timestamp":NSNumber(value: Date().timeIntervalSince1970),"meetingTime":NSNumber(value:self.meetingDatePicker.date.timeIntervalSince1970)]
        
                //fireStore - tables에 작성
                let newRecruitTableRef = self.db.collection("recruitTables").document()
                newRecruitTableRef.setData(newRecruitTable)
                
                //fireStore - users-table에 작성
                self.db.collection("users").document(Auth.auth().currentUser!.uid).collection("table").document(newRecruitTableRef.documentID).setData(newRecruitTable)
                
                let messageMember: [String : [String]] = ["users" : [Auth.auth().currentUser!.uid]]
                //fireStore - messageGroup 사용자 추가
                self.db.collection("messageGroup").document(newRecruitTableRef.documentID).setData(messageMember)
                
                //RealtimeDB에 user-group & group에 추가
                if let uid = FirebaseDataService.instance.currentUserUid {
                    let userRef = FirebaseDataService.instance.userRef.child(uid)
                    userRef.child("groups").updateChildValues(([newRecruitTableRef.documentID: 1])) { (error, ref) in
                        let groupRef = FirebaseDataService.instance.groupRef.child(newRecruitTableRef.documentID)
                        groupRef.setValue(["name":title, "to":uid, "currentNumber":1, "lastMessage":""])
                        return
                    }
                }
//            let time = DispatchTime.now() + .seconds(1)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 10) {
                self.dismiss(animated: true) {
                    self.removeLoadingScreen()
                }
            }
            
        }
    }
    

    @IBAction func stepperValueChanged(_ sender: Any) {
        updateNumberOfRecruitmentMember()
        updateDoneButtonUI()
    }
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        meetingDateLabel.isHidden = false
        updateDataViews()
        updateDoneButtonUI()
    }
    
    func updateDataViews() {
        let today = Date().timeIntervalSince1970
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_kr")
        dateFormatter.dateFormat = "dd"
        
        let currentDay = Int(dateFormatter.string(from: Date(timeIntervalSince1970: today)))!
        let meetingDay = Int(dateFormatter.string(from: meetingDatePicker.date))!
        
        if currentDay == meetingDay {
            dateFormatter.dateFormat = "a H:mm"
            meetingDateLabel.text = dateFormatter.string(from: meetingDatePicker.date)
        } else if currentDay + 1 == meetingDay {
            dateFormatter.dateFormat = "a H:mm"
            meetingDateLabel.text = "내일 " + dateFormatter.string(from: meetingDatePicker.date)
        }
    }
    
    func updateNumberOfRecruitmentMember() {
        numberOfRecruitmentLabel.text = "\(Int(recruitmentCountStepper.value))"
    }
    
    func didSelect(selectedCategories: String) {
        self.selectedCategories = selectedCategories
        categoriesLabel.text = selectedCategories
        updateDoneButtonUI()
    }
    
    func updateDoneButtonUI() {
        guard titleTextField.text != "",
              noteTextView.text != "같이 시켜먹을 배달음식에 대한 설명과 수령 방식 등 배달 공유에 대한 정보를 작성해 주세요.",
              noteTextView.text.count > 0,
              selectedCategories != nil,
              recruitmentCountStepper.value > 1,
              meetingDateLabel.text != ""
              else { return writingDoneButton.isEnabled = false }
        
        writingDoneButton.isEnabled = true
    }
    
    func editModeUIUpdate() {
        if mainPostInformation != nil {
            titleTextField.text = mainPostInformation?.postTitle
            noteTextView.textColor = UIColor.black
            noteTextView.text = mainPostInformation?.postNoteText
            categoriesLabel.text = mainPostInformation?.categories
            self.selectedCategories = mainPostInformation?.categories
            recruitmentCountStepper.value = Double(mainPostInformation!.maximumNumber)
            meetingDateLabel.isHidden = false
            meetingDateLabel.text = mainPostInformation?.meetingTime
            guard let datePickerValue = stringToDateType(string: meetingDateLabel.text!) else { return }
            print(datePickerValue)
            meetingDatePicker.date = datePickerValue
        }
    }
    
    func stringToDateType(string : String) -> Date? {
        let formatter = DateFormatter()
        
        formatter.locale = Locale(identifier: "ko_kr")
        formatter.dateFormat = "a H:mm"
        
        return formatter.date(from: string)
    }
    
    func editMainPostInformation() {
        guard let title = self.titleTextField.text, let category = self.categoriesLabel.text, let noteText = self.noteTextView.text, let meetingTime = self.meetingDateLabel.text else { return }
        self.mainPostInformation?.postTitle = title
        self.mainPostInformation?.categories = category
        self.mainPostInformation?.postNoteText = noteText
        self.mainPostInformation?.maximumNumber = Int(recruitmentCountStepper.value)
        self.mainPostInformation?.meetingTime = meetingTime
    }

    func navigationUI() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(named: "2"), for: UIBarMetrics.default)
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    func setLoadingScreen() {

            let width: CGFloat = 30
            let height: CGFloat = 30
            let x = (tableView.frame.width / 2) - (width / 2)
            let y = (tableView.frame.height / 2)
            postActivityIndicatorLoadingView.frame = CGRect(x: x, y: y, width: width, height: height)
//            postActivityIndicatorLoadingView.backgroundColor = .blue
        
            postActivityIndicator.style = .large
            postActivityIndicator.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            postActivityIndicator.startAnimating()

            postActivityIndicatorLoadingView.addSubview(postActivityIndicator)
            
            tableView.addSubview(postActivityIndicatorLoadingView)

        }
    
    func removeLoadingScreen() {

            // Hides and stops the text and the spinner
            postActivityIndicator.stopAnimating()
            postActivityIndicator.isHidden = true

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
        
//        if segue.identifier == "unwindToMainView"{
//            //ToDo: Type cating으로 경고 수정, 나중에 유저가 그룹참가를 하면 currentNumber를 update하는 코드구현
//            let currentNumber = 1
//            guard let title = titleTextField.text, let category = categoriesLabel.text, let noteText = noteTextView.text else { return }
//
//            let newRecruitTable:Dictionary<String, Any> = ["uid":Auth.auth().currentUser!.uid, "title": title, "category":category, "noteText":noteText, "maximumNumber":recruitmentCountStepper.value,"currentNumber":currentNumber,"timestamp":NSNumber(value: Date().timeIntervalSince1970),"meetingTime":NSNumber(value:meetingDatePicker.date.timeIntervalSince1970)]
//
//            //fireStore - tables에 작성
//            let newRecruitTableRef = db.collection("recruitTables").document()
//            newRecruitTableRef.setData(newRecruitTable)
//
//            //fireStore - users-table에 작성
//            db.collection("users").document(Auth.auth().currentUser!.uid).collection("table").document(newRecruitTableRef.documentID).setData(newRecruitTable)
//
//            //RealtimeDB에 user-group & gropu에 추가
//            if let uid = FirebaseDataService.instance.currentUserUid {
//                let userRef = FirebaseDataService.instance.userRef.child(uid)
//                userRef.child("groups").updateChildValues(([newRecruitTableRef.documentID: 1])) { (error, ref) in
//                    let groupRef = FirebaseDataService.instance.groupRef.child(newRecruitTableRef.documentID)
//                    groupRef.setValue(["name":title, "to":uid, "currentNumber":1, "lastMessage":""])
//                    return
//                }
//            }
//
//
//        }
        
    }
   
    
}


