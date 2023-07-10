//
//  CommentVC.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/10.
//

import UIKit
import Firebase

private let reuseIdentifier = "CommentCell"

final class CommentVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    
    
    // MARK: - Properties
    
    
    
    
    
    
    
    // MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        
        // backgrounc color
        self.collectionView.backgroundColor = .white
        
        // navigation title
        self.navigationItem.title = "Comments"
        
        // register cell class
        self.collectionView!.register(CommentCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        
        
        
    }
    
    
    
    // MARK: - UICollectionView
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = self.view.frame.width
        

        
        
        return CGSize(width: width, height: 40)
    }
    // collectionView item
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CommentCell
        
        return cell
    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 1
//    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 1
//    }
    
    
    
    
    
    
    
}
