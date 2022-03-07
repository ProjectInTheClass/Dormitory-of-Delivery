//
//  ChatMessageRightTimeAndUserCell.swift
//  DormitoryForDelivery
//
//  Created by 김동현 on 2021/10/05.
//

import UIKit

class ChatMessageRightTimeAndUserCell: UICollectionViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var containerViewWidthAnchor: NSLayoutConstraint?
    var containerViewRightAnchor: NSLayoutConstraint?
    var containerViewLeftAnchor: NSLayoutConstraint?
    var containerViewHeightAnchor: NSLayoutConstraint?
    var textLabelHeightAnchor: NSLayoutConstraint?
    var nameLabelRightAnchor: NSLayoutConstraint?
    var nameLabelLeftAnchor: NSLayoutConstraint?
    
    func setUITraits() {
        containerView.layer.cornerRadius = 15
        textLabel.numberOfLines = 0
        textLabel.lineBreakMode = .byWordWrapping
    }
    
    func setAnchors() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 1).isActive = true
        nameLabelLeftAnchor = nameLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 6)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5).isActive = true
        containerView.leftAnchor.constraint(equalTo: leftAnchor, constant: 6).isActive = true
        
        containerViewWidthAnchor = containerView.widthAnchor.constraint(equalToConstant: 200)
        containerViewHeightAnchor = containerView.heightAnchor.constraint(equalToConstant: frame.height - 16 )
        containerViewWidthAnchor?.isActive = true
        containerViewHeightAnchor?.isActive = true
        
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 16).isActive = true
        textLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10).isActive = true
        textLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 11).isActive = true
        textLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -10).isActive = true
        textLabelHeightAnchor = textLabel.heightAnchor.constraint(equalToConstant: frame.height - 16)
        
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.leftAnchor.constraint(equalTo: containerView.rightAnchor, constant: 5).isActive = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setAnchors()
        setUITraits()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func measuredFrameHeightForEachMessage(message: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: message).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)], context: nil)
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        let height = measuredFrameHeightForEachMessage(message: textLabel.text!).height + 20
        var newFrame = layoutAttributes.frame
        newFrame.size.width = CGFloat(ceilf(Float(size.width)))
        newFrame.size.height = height + 22 + 5
        containerViewHeightAnchor?.constant = height
        textLabelHeightAnchor?.constant = height
        layoutAttributes.frame = newFrame
        return layoutAttributes
    }
}
