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
    @IBOutlet weak var NextToPage: UIButton!
    var slides: [TutotialSlide] = []
    
    var currentPage = 0 {
        didSet{
            PageController.currentPage = currentPage
            if currentPage == slides.count - 1{
                NextButton.setTitle("시작합니다!", for: .normal)
            } else {
                NextButton.setTitle("다음", for: .normal)
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NextButton.layer.cornerRadius = 10
        NextToPage.layer.cornerRadius = 10
        
        slides = [
            TutotialSlide(title: "메인화면 입니다.", description: "먹고 싶은 메뉴또는 마음에 드는 채팅방을 고를 수 있습니다.", image: UIImage(named: "HomeView")!),
            TutotialSlide(title: "채팅방 생성화면 입니다.", description: "주문시간과 내용을 입력합니다.", image: UIImage(named: "GroupCreateView")!),
            TutotialSlide(title: "채팅방 생성된 화면입니다.", description: "사용자들과 원활한 소통후 즐거운 식사 시간이 되길 바랍니다.", image: UIImage(named: "CreateView")!)
        ]
        PageController.numberOfPages = slides.count

    }
    
    @IBAction func NextToButton(_ sender: Any) {
        let controller = storyboard?.instantiateViewController(identifier: "MainTableViewController") as! UITabBarController
            controller.modalPresentationStyle = .fullScreen
            controller.modalTransitionStyle = .coverVertical
            present(controller, animated: true, completion: nil)
        
    }
    
    
    @IBAction func NextButtonClicked(_ sender: Any) {
        if currentPage == slides.count - 1{
        let controller = storyboard?.instantiateViewController(identifier: "MainTableViewController") as! UITabBarController
            controller.modalPresentationStyle = .fullScreen
            controller.modalTransitionStyle = .coverVertical
            present(controller, animated: true, completion: nil)
            
        }else{
            currentPage += 1
            let indexPath = IndexPath(item: currentPage, section: 0)
            CollectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
        }
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
