//
//  MyInfoTableViewCell.swift
//  DormitoryForDelivery
//
//  Created by 김덕환 on 2022/02/27.
//

import UIKit

class MyInfoTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var NumberLabel: UILabel!
    @IBOutlet weak var MailLabel: UILabel!
    
    @IBOutlet weak var RMail: UILabel!
    @IBOutlet weak var RNumber: UILabel!
    @IBOutlet weak var RName: UILabel!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
