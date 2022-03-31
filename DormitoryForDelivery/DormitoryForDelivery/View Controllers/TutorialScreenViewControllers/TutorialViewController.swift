//
//  TutorialViewController.swift
//  DormitoryForDelivery
//
//  Created by 김덕환 on 2022/02/16.
//

import UIKit

class TutorialViewController: UIViewController {

    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var PageController: UIPageControl!
    @IBOutlet weak var NextButton: UIButton!
    var slides: [TutotialSlide] = []
    
    var currentPage = 0 {
        didSet{
            PageController.currentPage = currentPage
            if currentPage == slides.count - 1{
                NextButton.setTitle("시작합니다!", for: .normal)
            } else {
                NextButton.setTitle("건너뛰기", for: .normal)
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NextButton.layer.cornerRadius = 10
        
        slides = [
            TutotialSlide(title: "main", description: "", image: UIImage(named: "home")!),
            TutotialSlide(title: "group", description: "", image: UIImage(named: "group1")!),
            TutotialSlide(title: "write", description: "", image: UIImage(named: "write1")!),
            TutotialSlide(title: "commu", description: "", image: UIImage(named: "commu")!),
            TutotialSlide(title: "chatting", description: "", image: UIImage(named: "chatting")!)
        ]
        PageController.numberOfPages = slides.count

    }
    
    
    
    @IBAction func NextButtonClicked(_ sender: Any) {
        
            UserDefaults.standard.hasTutorial = true
            
            self.dismiss(animated: true, completion: nil) // 화면을 치운다.
//        let controller = storyboard?.instantiateViewController(identifier: "MainTableViewController") as! UITabBarController
//            controller.modalPresentationStyle = .fullScreen
//            controller.modalTransitionStyle = .coverVertical
            
//            present(controller, animated: false, completion: nil)
            
        
    }
    

}

extension TutorialViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return slides.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TutorialCollectionViewCell.identifier, for: indexPath) as! TutorialCollectionViewCell
        cell.setup(slides[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        currentPage = Int(scrollView.contentOffset.x/width)
        
    }
    
}

 
