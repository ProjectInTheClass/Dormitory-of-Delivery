//
//  TermsOfServiceTableViewController.swift
//  DormitoryForDelivery
//
//  Created by 이태영 on 2022/04/09.
//

import UIKit

class TermsOfServiceTableViewController: UITableViewController {
    
    @IBOutlet weak var nextStepButton: UIButton!
    
    @IBOutlet var acceptTermButton: [UIButton]!
    
    var acceptAllTerm: Bool = false
    var acceptFirstTerm: Bool = false
    var acceptSecondTerm: Bool = false
    var acceptThirdTerm: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingNextStepButton()
        settingNavigationBarItem()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    private func settingNextStepButton() {
        nextStepButton.layer.cornerRadius = 6
        nextStepButton.backgroundColor = .gray
        nextStepButton.isEnabled = false
    }
    
    private func settingNavigationBarItem() {
        self.navigationController?.navigationBar.tintColor = .white
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    @IBAction func acceptAllTermButtonTapped(_ sender: UIButton) {
        acceptAllTerm.toggle()
        if acceptAllTerm {
            acceptFirstTerm = true
            acceptSecondTerm = true
            acceptThirdTerm = true
            sender.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            for button in self.acceptTermButton {
                button.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            }
        } else {
            acceptFirstTerm = false
            acceptSecondTerm = false
            acceptThirdTerm = false
            sender.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
            for button in self.acceptTermButton {
                button.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
            }
        }
        checkUserAcceptAllTerms()
    }
    
    @IBAction func acceptFirstTermButtonTapped(_ sender: UIButton) {
        acceptFirstTerm.toggle()
        if acceptFirstTerm {
            sender.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        } else {
            sender.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        }
        checkUserAcceptAllTerms()
    }
    
    @IBAction func acceptSecondTermButtonTapped(_ sender: UIButton) {
        acceptSecondTerm.toggle()
        if acceptSecondTerm {
            sender.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        } else {
            sender.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        }
        checkUserAcceptAllTerms()
    }
    
    @IBAction func acceptThirdTermButtonTapped(_ sender: UIButton) {
        acceptThirdTerm.toggle()
        if acceptThirdTerm {
            sender.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        } else {
            sender.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        }
        checkUserAcceptAllTerms()
    }
    
    @IBAction func dismissButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    private func checkUserAcceptAllTerms() {
        if acceptFirstTerm && acceptSecondTerm && acceptThirdTerm {
            self.nextStepButton.backgroundColor = UIColor(displayP3Red: 142/255, green: 160/255, blue: 207/255, alpha: 1)
            self.nextStepButton.isEnabled = true
        } else {
            nextStepButton.backgroundColor = .gray
            nextStepButton.isEnabled = false
        }
    }
    
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
