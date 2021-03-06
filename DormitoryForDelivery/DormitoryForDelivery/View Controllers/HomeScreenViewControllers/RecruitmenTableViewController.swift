//
//  RecruitmenTableViewController.swift
//  DormitoryForDelivery
//
//  Created by κΉλν on 2021/08/01.
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
    
    var selectedCategoryNumber: Int?
    
    var mainPostInformation: RecruitingText?
    
    var delegate: SendEditDataDelegate?
    
    let postActivityIndicator = UIActivityIndicatorView()
    
    let postActivityIndicatorLoadingView = UIView()
    
    var titleComponentArray: [String]?
    
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
    
    // tableViewμμ νΉμ Cellμ μ ννμλ λμνλ ν¨μ
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // meetingTimeDataPickerCellμ νμ λμ
        switch indexPath {
        case meetingTimeDateLabelCellIndexPath:
            if isMeetingTimeDatePickerShown {
                isMeetingTimeDatePickerShown = false
            } else {
                isMeetingTimeDatePickerShown = true
            }
            //tableView.beginUpdates()
            //tableView.endUpdates()
            tableView.reloadData()
        default:
            break
        }
        
    }
    
    func noteTextViewPlaceholderSetting() {
        noteTextView.text = "κ°μ΄ μμΌλ¨Ήμ λ°°λ¬μμμ λν μ€λͺκ³Ό μλ Ή λ°©μ λ± λ°°λ¬ κ³΅μ μ λν μ λ³΄λ₯Ό μμ±ν΄ μ£ΌμΈμ."
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
            textView.text = "κ°μ΄ μμΌλ¨Ήμ λ°°λ¬μμμ λν μ€λͺκ³Ό μλ Ή λ°©μ λ± λ°°λ¬ κ³΅μ μ λν μ λ³΄λ₯Ό μμ±ν΄ μ£ΌμΈμ."
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        updateDoneButtonUI()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // νμ€νΈ νλ λ¦¬ν΄ ν€ λΈλ¦¬κ²μ΄νΈ μ²λ¦¬
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        titleTextField.resignFirstResponder()
        return true
    }
    // νμ€νΈ λ·° λ¦¬ν΄ ν€ λΈλ¦¬κ²μ΄νΈ μ²λ¦¬
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
        self.writingDoneButton.isEnabled = false // λ²νΌ λλ²λλ₯Ό λ κΈμ΄ λκ° μμ±λλκ±Έ λ°©μ§νλ μ½λ
        if self.mainPostInformation != nil {
            creatSelectedCategoriesNumber()
            changeTitleToArray(sender: self.titleTextField.text!)
            self.editMainPostInformation()
            self.delegate?.sendData(mainPostInformation: self.mainPostInformation!)
            dismiss(animated: true) {
                let doc = self.db.collection("recruitTables").document(self.mainPostInformation!.documentId)
                let data: [String : AnyObject] = ["category" : self.categoriesLabel.text as AnyObject, "currentNumber" : self.mainPostInformation?.currentNumber as AnyObject, "maximumNumber" : self.recruitmentCountStepper.value as AnyObject, "meetingTime" : NSNumber(value: self.meetingDatePicker.date.timeIntervalSince1970) as AnyObject, "noteText" : self.noteTextView.text as AnyObject, "timestamp" : NSNumber(value: Date().timeIntervalSince1970) as AnyObject, "title" : self.titleTextField.text as AnyObject, "categoryNumber" : self.selectedCategoryNumber as AnyObject, "titleComponentArray" : self.titleComponentArray as AnyObject]
                doc.setData(data, merge: true) { (error) in
                    guard error == nil else { return }
                }
            }
        } else {
                setLoadingScreen()
                creatSelectedCategoriesNumber()
                changeTitleToArray(sender: self.titleTextField.text!)
                //ToDo: Type catingμΌλ‘ κ²½κ³  μμ , λμ€μ μ μ κ° κ·Έλ£Ήμ°Έκ°λ₯Ό νλ©΄ currentNumberλ₯Ό updateνλ μ½λκ΅¬ν
                let currentNumber = 1
                let currentUserUid = Auth.auth().currentUser!.uid
            guard let title = self.titleTextField.text, let category = self.categoriesLabel.text, let noteText = self.noteTextView.text, let categoryNumber = self.selectedCategoryNumber, let titleComponentArray = self.titleComponentArray else { return }
            let newRecruitTable:Dictionary<String, Any> = ["uid" : currentUserUid, "title" : title, "category" : category, "noteText" : noteText, "maximumNumber" : self.recruitmentCountStepper.value,"currentNumber" : currentNumber,"timestamp" : NSNumber(value: Date().timeIntervalSince1970),"meetingTime" : NSNumber(value:self.meetingDatePicker.date.timeIntervalSince1970), "categoryNumber" :          categoryNumber, "titleComponentArray" : titleComponentArray, "mamberUid" : [currentUserUid]]
        
                //fireStore - tablesμ μμ±
                let newRecruitTableRef = self.db.collection("recruitTables").document()
                newRecruitTableRef.setData(newRecruitTable)
                
                //fireStore - users-tableμ μμ±
                self.db.collection("users").document(Auth.auth().currentUser!.uid).collection("table").document(newRecruitTableRef.documentID).setData(newRecruitTable)
                
                let messageMember: [String : [String]] = ["users" : [Auth.auth().currentUser!.uid]]
                //fireStore - messageGroup μ¬μ©μ μΆκ°
                self.db.collection("messageGroup").document(newRecruitTableRef.documentID).setData(messageMember)
                
                //RealtimeDBμ user-group & groupμ μΆκ°
                if let uid = FirebaseDataService.instance.currentUserUid {
                    let userRef = FirebaseDataService.instance.userRef.child(uid)
                    userRef.child("groups").updateChildValues(([newRecruitTableRef.documentID: NSNumber(value: Date().timeIntervalSince1970)])) { (error, ref) in
                        let groupRef = FirebaseDataService.instance.groupRef.child(newRecruitTableRef.documentID)
                        groupRef.setValue(["name":title, "to":uid, "currentNumber":1, "lastMessage":""])
                        return
                    }
                }
//            let time = DispatchTime.now() + .seconds(1)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
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
            meetingDateLabel.text = "λ΄μΌ " + dateFormatter.string(from: meetingDatePicker.date)
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
              noteTextView.text != "κ°μ΄ μμΌλ¨Ήμ λ°°λ¬μμμ λν μ€λͺκ³Ό μλ Ή λ°©μ λ± λ°°λ¬ κ³΅μ μ λν μ λ³΄λ₯Ό μμ±ν΄ μ£ΌμΈμ.",
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
        navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    func setLoadingScreen() {

            let width: CGFloat = 30
            let height: CGFloat = 30
            let x = (tableView.frame.width / 2) - (width / 2)
        let y = (tableView.frame.height / 3.0)
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
    // μΉ΄νκ³ λ¦¬ νκΈμ΄ μΏΌλ¦¬λ‘ μλ³΄λ΄μ Έμ λ²νΈμ΄μ© ν΄λ΄
    private func creatSelectedCategoriesNumber() {
        if selectedCategories == "μ»€νΌ" {
            self.selectedCategoryNumber = 1
        } else if selectedCategories == "λμ νΈ" {
            self.selectedCategoryNumber = 2
        } else if selectedCategories == "νλ²κ±°" {
            self.selectedCategoryNumber = 3
        } else if selectedCategories == "λκΉμ€" {
            self.selectedCategoryNumber = 4
        } else if selectedCategories == "μ΄λ°₯" {
            self.selectedCategoryNumber = 5
        } else if selectedCategories == "μλ¬λ" {
            self.selectedCategoryNumber = 6
        } else if selectedCategories == "μ€κ΅­μ§" {
            self.selectedCategoryNumber = 7
        } else if selectedCategories == "νμ" {
            self.selectedCategoryNumber = 8
        } else if selectedCategories == "λΆμ" {
            self.selectedCategoryNumber = 9
        }
    }
    // κ²μ κΈ°λ₯μμν΄ μ λͺ©μ νλμ© μͺΌκ°μ λ°°μ΄μ λ΄λ ν¨μ
    private func changeTitleToArray(sender: String) {
        // νμ΄μ΄λ² μ΄μ€κ° Characterνμμ μ½μ μ μλ κ² κ°μ κ·Έλμ StringμΌλ‘ λ³ν μ μ΄μ μͺΌκ°€ λ StringμΌλ‘ λ³κ²½ν  λ°©λ² μ°ΎμΌλ©΄ μμ 
        var titleArray: [String] = []
        for titleComponent in sender {
            titleArray.append(String(titleComponent))
        }
        self.titleComponentArray = titleArray
        print(titleArray)
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
//            //ToDo: Type catingμΌλ‘ κ²½κ³  μμ , λμ€μ μ μ κ° κ·Έλ£Ήμ°Έκ°λ₯Ό νλ©΄ currentNumberλ₯Ό updateνλ μ½λκ΅¬ν
//            let currentNumber = 1
//            guard let title = titleTextField.text, let category = categoriesLabel.text, let noteText = noteTextView.text else { return }
//
//            let newRecruitTable:Dictionary<String, Any> = ["uid":Auth.auth().currentUser!.uid, "title": title, "category":category, "noteText":noteText, "maximumNumber":recruitmentCountStepper.value,"currentNumber":currentNumber,"timestamp":NSNumber(value: Date().timeIntervalSince1970),"meetingTime":NSNumber(value:meetingDatePicker.date.timeIntervalSince1970)]
//
//            //fireStore - tablesμ μμ±
//            let newRecruitTableRef = db.collection("recruitTables").document()
//            newRecruitTableRef.setData(newRecruitTable)
//
//            //fireStore - users-tableμ μμ±
//            db.collection("users").document(Auth.auth().currentUser!.uid).collection("table").document(newRecruitTableRef.documentID).setData(newRecruitTable)
//
//            //RealtimeDBμ user-group & gropuμ μΆκ°
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


