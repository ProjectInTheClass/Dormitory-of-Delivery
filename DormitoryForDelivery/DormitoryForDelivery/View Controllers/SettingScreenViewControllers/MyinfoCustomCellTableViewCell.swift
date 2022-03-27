//
//  MyinfoCustomCellTableViewCell.swift
//  DormitoryForDelivery
//
//  Created by 김덕환 on 2022/02/26.
//

import UIKit

class MyinfoCustomCellTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var RMail: UILabel!
    @IBOutlet weak var RNumber: UILabel!
    @IBOutlet weak var RName: UILabel!
    @IBOutlet weak var MailLabel: UILabel!
    @IBOutlet weak var NumberLabel: UILabel!
    @IBOutlet weak var NameLable: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
