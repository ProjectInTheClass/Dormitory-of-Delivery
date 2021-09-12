//
//  ChatGroupTableViewController.swift
//  DormitoryForDelivery
//
//  Created by 김동현 on 2021/08/22.
//

import UIKit
import FirebaseFirestore

class ChatGroupTableViewController: UITableViewController {

    @IBOutlet weak var navigationBar: UINavigationItem!
    let db:Firestore = Firestore.firestore()
    var groups: [Group] = []
    var messages: [ChatMessage] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.backButtonTitle = ""
        self.navigationController?.navigationBar.tintColor = UIColor.black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchChatGroupList()
        
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.layoutIfNeeded()
    }

    func fetchChatGroupList(){
        if let uid = FirebaseDataService.instance.currentUserUid{
            FirebaseDataService.instance.userRef.child(uid).child("groups").observeSingleEvent(of: .value, with: { (snapshot) in
                if let dict = snapshot.value as? Dictionary<String, Int>{
                    self.groups.removeAll()
                    for (key, _) in dict {
                        FirebaseDataService.instance.groupRef.child(key).observe(.value, with: { (snapshot) in
                           // print(snapshot.value)
                            if let data = snapshot.value as? Dictionary<String, AnyObject> {
                             //   print(data["lastMessage"])
                                let group = Group(key: key, data: data)
                             //   print(group)
                                self.groups.append(group)
                                
                            }
                            self.tableView.reloadData()
                        })
                    }
                    
                }
            })
        }
    }
    
    
    
    
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return groups.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "chatting", sender: groups[indexPath.row].key)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath) as! ChatGroupTableViewCell
        //print("cellForRowAt : \(indexPath)")
        
        cell.groupTitleLabel.text = groups[indexPath.row].name
        cell.currentNumber.text = String(groups[indexPath.row].currentNumber)
        cell.lastText.text = groups[indexPath.row].lastMessage
        return cell
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chatting"{
            let chatVC = segue.destination as! ChatRoomViewController
            chatVC.groupKey = sender as? String
        }
    }
    

}
