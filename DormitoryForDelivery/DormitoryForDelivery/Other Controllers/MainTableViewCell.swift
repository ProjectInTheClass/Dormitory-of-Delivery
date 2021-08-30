//
//  MainTableViewCell.swift
//  DormitoryForDelivery
//
//  Created by 이태영 on 2021/08/02.
//

import UIKit

class MainTableViewCell: UITableViewCell {

    //@IBOutlet weak var circularProgressBarView: CircleProgressViewController!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var catagoryImage: UIImageView!
    @IBOutlet weak var postTitleLabel: UILabel!
   // @IBOutlet weak var categoriesLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func update(with main: RecruitingText) {
        catagoryImage.image = UIImage(named: main.categories)
        postTitleLabel.text = main.postTitle
        //categoriesLabel.text = main.categories
        progressLabel.text = "\(main.currentNumber)/\(main.maximumNumber)"
        
//        let progressValue = Float(Float(main.currentNumber) / Float(main.maximumNumber))
//        circularProgressBarView.trackColor = UIColor.gray
//        circularProgressBarView.progressColor = UIColor.blue
//        circularProgressBarView.setProgressWithAnimation(duration: 1.0, value: progressValue)
    }
    
    
}
