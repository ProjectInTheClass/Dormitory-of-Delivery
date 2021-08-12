//
//  SelectCategoriesTableViewController.swift
//  DormitoryForDelivery
//
//  Created by 김동현 on 2021/08/01.
//

import UIKit

protocol SelectCategoriesTableViewControllerDelegate {
    func didSelect(categoriesArray: [String])
}

class SelectCategoriesTableViewController: UITableViewController {
    
    var selectCategories: String?
    
    var categoriesArray: [String] = []
    
    var delegate: SelectCategoriesTableViewControllerDelegate?
    
    var categories: [String] = ["한식","분식","커피","디저트","돈가스/일식","치킨","피자","양식","중국집","보쌈/족발","햄버거","기타"]
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categories.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        
        let category = categories[indexPath.row]
        cell.textLabel?.text = category
        
        for categories in categoriesArray {
            if category == categories {
                cell.accessoryType = .checkmark
            }
        }
        if !categoriesArray.contains(category) {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        selectCategories = categories[indexPath.row]
        
        guard let selectCategories = selectCategories else { return }
        
        if !categoriesArray.contains(selectCategories) {
            categoriesArray.append(selectCategories)
        } else if categoriesArray.contains(selectCategories) {
            if let firstIndex = categoriesArray.firstIndex(of: selectCategories) {
                print(firstIndex)
                categoriesArray.remove(at: firstIndex)
            }
        }
        
        delegate?.didSelect(categoriesArray: categoriesArray)
        tableView.reloadData()
    }
    


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
