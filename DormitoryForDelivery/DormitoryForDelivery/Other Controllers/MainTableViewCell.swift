//
//  MainTableViewCell.swift
//  DormitoryForDelivery
//
//  Created by 이태영 on 2021/08/02.
//

import UIKit

class MainTableViewCell: UITableViewCell {

   
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var meetingTimeLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var catagoryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // 페이징할때 nil값이 발견 되길래 가드문으로 언랩해줬다.
        guard let containerView = containerView else { return }
        containerView.layer.cornerRadius = 8
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    func update(with main: RecruitingText) {
        postTitleLabel.text = main.postTitle
        meetingTimeLabel.text = main.meetingTime
        catagoryLabel.text = main.categories
        progressLabel.text = "\(main.currentNumber)/\(main.maximumNumber)"
    }
}

class LoadingCell: UITableViewCell {
    @IBOutlet weak var nextPageLoadingIndicatior: UIActivityIndicatorView!
    
    func startNextPageLoadingIndicatior() {
        nextPageLoadingIndicatior.startAnimating()
    }
}
