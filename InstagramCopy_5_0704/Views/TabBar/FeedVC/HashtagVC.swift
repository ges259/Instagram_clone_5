//
//  HashtagVC.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/14.
//

import UIKit
import Firebase

private let reuseIdentifier = "HashtagCell"
final class HashtagVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    
    // MARK: - Properties
    var posts = [Post]()
    var hashtag: String?
    
    
    
    
    
    
    
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.configureNavigationBar()
        
        self.collectionView.backgroundColor = .white
        self.collectionView.register(HashtagCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        
        // fetch post
        fetchPost()
        
        
    }
    
    
    
    
    
    
    // MARK: - FlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (view.frame.width - 2) / 3
        
        return CGSize(width: width, height: width)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: view.frame.width, height: 0)
    }
    
    
    
    // MARK: - DataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.posts.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HashtagCell
    
        // Configure the cell
        cell.post = posts[indexPath.item]
        
        
    
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let feedVC = FeedVC(collectionViewLayout: UICollectionViewFlowLayout())
        
        feedVC.viewSinglePost = true
        feedVC.post = self.posts[indexPath.item]
        
        self.navigationController?.pushViewController(feedVC, animated: true)
        
        
    }
    
    
    
    
    
    // MARK: - Handler
    private func configureNavigationBar() {
        guard let hashtag = hashtag else { return }
        
        self.navigationItem.title = hashtag

    }
    
    
    
    
    
    
    // MARK: - API
    private func fetchPost() {
        
        guard let hashtag = self.hashtag else { return }
        
        
        HASHTAG_POST_REF.child(hashtag).observe(.childAdded) { snapshot in
            let postId = snapshot.key
            
            Database.fetchPost(with: postId) { post in
                self.posts.append(post)
                self.collectionView.reloadData()
            }
        }
    }
    
}
