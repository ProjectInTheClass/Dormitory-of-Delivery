//
//  TutorialCollectionViewCell.swift
//  DormitoryForDelivery
//
//  Created by κΉλν on 2022/02/16.
//

import UIKit

class TutorialCollectionViewCell: UICollectionViewCell {
    
    static let identifier = String(describing: TutorialCollectionViewCell.self)
    
    @IBOutlet weak var TutorialImage: UIImageView!
    
    func setup(_ slide: TutotialSlide){
        TutorialImage.image = slide.image

    }
}
