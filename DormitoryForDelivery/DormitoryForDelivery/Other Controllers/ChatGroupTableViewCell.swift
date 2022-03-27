//
//  ChatGroupTableViewCell.swift
//  DormitoryForDelivery
//
//  Created by 김동현 on 2021/08/29.
//

import UIKit

class ChatGroupTableViewCell: UITableViewCell {

    @IBOutlet weak var groupTitleLabel: UILabel!
    @IBOutlet weak var currentNumber: UILabel!
    @IBOutlet weak var maximumNumber: UILabel!
    @IBOutlet weak var matchTime: UILabel!
    @IBOutlet weak var lastText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
