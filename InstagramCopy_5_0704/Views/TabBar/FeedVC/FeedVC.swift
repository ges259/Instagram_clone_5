//
//  FeedVC.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/05.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"


final class FeedVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    
    // MARK: - properties
    
    var posts = [Post]()
    
    var viewSinglePost: Bool = false
    var post: Post?
    
    
    
    
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.backgroundColor = .white
        
        
        self.collectionView!.register(FeedCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        

        // configure refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        configureNavigationBar()
        
        if !viewSinglePost {
            fetchPosts()
        }
        
        updateUserFeeds()
        
        
    }
    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items

        if viewSinglePost {
            return 1
        }
        return self.posts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FeedCell
        
        cell.delegate = self
        
        if viewSinglePost {
            if let post = self.post {
                cell.post = post
            }
        } else {
            cell.post = posts[indexPath.row]
        }
        
        
        
        // Configure the cell
//        cell.post = posts[indexPath.row]
        
        return cell
    }
    
    
    // MARK: - FlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = self.view.frame.width
        var height = width + 8 + 40 + 8
        height += 50
        height += 60
        
        
        return CGSize(width: width, height: height)
    }
    
    
    
    
    
    
    
    
    
    // MARK: - Handlers
    func configureNavigationBar() {
        
        if !viewSinglePost {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        }
        
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "send2"), style: .plain, target: self, action: #selector(handleShowMessages))
        self.navigationItem.title = "Feed"
        
        
    }
    @objc private func handleShowMessages() {
        print("handleShowMessages")
    }
    
    @objc func handleLogout() {
        // declare alert controller
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // add alert logout action
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { _ in
            
            do {
                // attempt sign out
                try Auth.auth().signOut()
                
                // present login controller
                let loginVC = LoginVC()
                let navController = UINavigationController(rootViewController: loginVC)
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true, completion: nil)
            } catch {
                // handle error
                print("Failed to sign out")
            }
        }))
        
        // add cancel action
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    @objc private func handleRefresh() {
        posts.removeAll(keepingCapacity: false)
        fetchPosts()
        collectionView.reloadData()
    }
    
    
    
    // MARK: - API
    private func updateUserFeeds() {
        
        guard let currentId = Auth.auth().currentUser?.uid else { return }
        
        USER_FOLLOWING_REF.child(currentId).observe(.childAdded) { snapshot in
            
            print("Follower ----- \(snapshot)")
            let followingUserId = snapshot.key
            
            USER_POSTS_REF.child(followingUserId).observe(.childAdded) { snapshot in
                // snapshot : current-user를 follow한 사람들
                
                let postId = snapshot.key
                
                USER_FEED_REF.child(currentId).updateChildValues([postId: 1])
                
                
            }
        }
        
        USER_POSTS_REF.child(currentId).observe(.childAdded) { snapshot in
            let postId = snapshot.key
            
            USER_FEED_REF.child(currentId).updateChildValues([postId: 1])
            
        }
        
        
        
    }
    
    
    
    private func fetchPosts() {
        print("FeedVC - fetchPosts")
        
        guard let currentId = Auth.auth().currentUser?.uid else { return }
        
        USER_FEED_REF.child(currentId).observe(.childAdded) { snapshot in
            // post id
            let postId = snapshot.key
            
            Database.fetchPost(with: postId) { post in
                
                self.posts.append(post)
                
                self.posts.sort { post1, post2 in
                    return post1.creationDate > post2.creationDate
                }
                // stop refreshing
                self.collectionView.refreshControl?.endRefreshing()
                
                
                
                self.collectionView.reloadData()
            }
        }
    }
}





// MARK: - FeedCell - Delegate
extension FeedVC: FeedCellDelegate {
    func handleUserNameTapped(for cell: FeedCell) {
        
        guard let post = cell.post else { return }
        
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        
        userProfileVC.user = post.user
        self.navigationController?.pushViewController(userProfileVC, animated: true)
    }
    
    func handleOptionsTapped(for cel: FeedCell) {
        print("handle Options Tapped")
    }
    
    func handleLikeTapped(for cel: FeedCell) {
        print("handle likes Tapped")
    }
    
    func handleCommentTapped(for cel: FeedCell) {
        print("handle comment Tapped")
    }
    
    
}
