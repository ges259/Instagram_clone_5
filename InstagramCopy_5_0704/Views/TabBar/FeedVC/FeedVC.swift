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
    
    
    
    
    
    
    
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.backgroundColor = .white
        
        
        self.collectionView!.register(FeedCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        

         
        configureNavigationBar()
        
        fetchPosts()
        
    }
    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.posts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FeedCell
        
        cell.delegate = self
        
        // Configure the cell
        cell.post = posts[indexPath.row]
        
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
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        self.navigationItem.title = "Feed"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "send2"), style: .plain, target: self, action: #selector(handleShowMessages))
    }
    @objc private func handleShowMessages() {
        print("handleShowMessages")
    }
    
    @objc func handleLogout() {
        
        print("handleLogut pressed")
        
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
                
//
//                let loginVC = LoginVC()
//                loginVC.modalPresentationStyle = .fullScreen
//
//                self.present(loginVC, animated: true, completion: nil)
                
                
            } catch {
                // handle error
                print("Failed to sign out")
            }
        }))
        
        // add cancel action
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    
    // MARK: - API
    private func fetchPosts() {
        
        POSTS_REF.observe(.childAdded) { snapshot in
            // post id
            let postId = snapshot.key
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
            guard let ownerUid = dictionary["ownerUid"] as? String else { return }
            
            Database.fetchUser(with: ownerUid) { user in
                
                let post = Post(postId: postId, user: user, dictionary: dictionary)
                
                self.posts.append(post)
                
                self.posts.sort { post1, post2 in
                    return post1.creationDate > post2.creationDate
                }
                
                print("Post caption is \(post.caption)")
                self.collectionView.reloadData()
            }
        }
    }
}





// MARK: - FeedCell - Delegate
extension FeedVC: FeedCellDelegate {
    func handleUserNameTapped(for cell: FeedCell) {
        print("handle user name Tapped")
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
