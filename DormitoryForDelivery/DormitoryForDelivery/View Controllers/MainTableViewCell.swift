//
//  MainTableViewCell.swift
//  DormitoryForDelivery
//
//  Created by 이태영 on 2021/08/02.
//

import UIKit

class MainTableViewCell: UITableViewCell {

    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func update(with main: RecruitingText) {
        symbolLabel.text = main.symbol
        postTitleLabel.text = main.postTitle
        categoriesLabel.text = main.categories
    }
    
    
}
