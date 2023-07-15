//
//  FeedVC.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/05.
//

import UIKit
import Firebase
import ActiveLabel

private let reuseIdentifier = "Cell"


final class FeedVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    
    // MARK: - properties
    
    
    
    
    
    var posts = [Post]()
    
    var viewSinglePost: Bool = false
    var post: Post?
    
    var currentKey: String?
    
    var userProfileController: UserProfileVC?
    
    
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
    // MARK: - collection view
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if posts.count > 4 {
            if indexPath.item == posts.count - 1 {
                fetchPosts()
            }
        }
    }

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
        
        self.handleHashtagTapped(forCell: cell)
        self.handleUserNameLabelTapped(forCell: cell)
        self.handleMentionTapped(forCell: cell)
        
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
        let messagesVC = MessagesVC()
        self.navigationController?.pushViewController(messagesVC, animated: true)
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
        self.currentKey = nil
        fetchPosts()
        collectionView.reloadData()
    }
    
    private func handleHashtagTapped(forCell cell: FeedCell) {
        cell.captionLabel.handleHashtagTap { hashtag in
            let hashtagVC = HashtagVC(collectionViewLayout: UICollectionViewFlowLayout())
            hashtagVC.hashtag = hashtag
            self.navigationController?.pushViewController(hashtagVC, animated: true)
        }
    }
    
    private func handleUserNameLabelTapped(forCell cell: FeedCell) {
        
        guard let user = cell.post?.user else { return }
        guard let userName = user.userName else { return }
        
        let customType = ActiveType.custom(pattern: "^\(userName)\\b")

        
        cell.captionLabel.handleCustomTap(for: customType) { _ in
            let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
            userProfileVC.user = user
            userProfileVC.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(userProfileVC, animated: true)
        }
    }
    
    private func handleMentionTapped(forCell cell: FeedCell) {
        cell.captionLabel.handleMentionTap { userName in
            self.getMentionUser(withuserName: userName)
        }
    }
    
    
    
    
    
    
    
    
    
    // MARK: - API
    private func updateUserFeeds() {
        
        guard let currentId = Auth.auth().currentUser?.uid else { return }
        
        USER_FOLLOWING_REF.child(currentId).observe(.childAdded) { snapshot in
            
            let followingUserId = snapshot.key
            // followingUserId: 자신이 follow한 사람들
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
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        // cueernetKey가 nil이면 -> 처음 화면은 무조건 nil.
        // 첫 시작은 if문으로 시작되고 그 이후에 fetchPosts가 불리면 else로 빠짐
        if currentKey == nil {
            // 일단 5개만 받아오기
            USER_FEED_REF.child(currentUid).queryLimited(toLast: 5).observeSingleEvent(of: .value) { snapshot in
                self.collectionView.refreshControl?.endRefreshing()
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                allObjects.forEach { snapshot in
                    let postId = snapshot.key
                    self.fetchPost(withPostId: postId)
                }
                self.currentKey = first.key
            }
            // 2번째 fetchPosts부터
        } else {
            // 중복이 있을 수 있으므로 5개보다 많은 6개 불러오기
            USER_FEED_REF.child(currentUid).queryOrderedByKey().queryEnding(atValue: self.currentKey).queryLimited(toLast: 6).observeSingleEvent(of: .value) { snapshot in
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                allObjects.forEach { snapshot in
                    let postId = snapshot.key
                    
                    if postId != self.currentKey {
                        self.fetchPost(withPostId: postId)
                    }
                }
                self.currentKey = first.key
            }
        }
    }
    
    private func fetchPost(withPostId postId: String) {
        Database.fetchPost(with: postId) { post in
            self.posts.append(post)
            
            self.posts.sort { post1, post2 -> Bool in
                return post1.creationDate > post2.creationDate
            }
            self.collectionView.reloadData()
        }
    }
    
    
}





// MARK: - FeedCell - Delegate
extension FeedVC: FeedCellDelegate {
    // User Name Button Tapped
    func handleUserNameTapped(for cell: FeedCell) {
        
        guard let post = cell.post else { return }
        
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        
        userProfileVC.user = post.user
        self.navigationController?.pushViewController(userProfileVC, animated: true)
    }
    
    
    
    func handleOptionsTapped(for cell: FeedCell) {
        guard let post = cell.post else { return }
        
        if post.ownerUid == Auth.auth().currentUser?.uid {
            let alertController = UIAlertController(title: "Options", message: nil, preferredStyle: .actionSheet)
            
            alertController.addAction(UIAlertAction(title: "Delete Post", style: .destructive, handler: { _ in
                post.deletePost()
                
                if !self.viewSinglePost {
                    self.handleRefresh()
                } else {
                    if let userProfileController = self.userProfileController {
                        self.navigationController?.popViewController(animated: true)
                        userProfileController.handleRefresh()
                    }
                }
            }))
            
            alertController.addAction(UIAlertAction(title: "Edit Post", style: .default, handler: { _ in
                let uploadPostVC = UploadPostVC()
                let navigationController = UINavigationController(rootViewController: uploadPostVC)
                navigationController.modalPresentationStyle = .fullScreen
                uploadPostVC.postToEdit = post
                uploadPostVC.uploadAction = UploadPostVC.UploadAction(index: 1)
                self.present(navigationController, animated: true)
                
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                print("Handle cancel post..")
            }))
            
            present(alertController, animated: true, completion: nil)
        }
    }
    
    // Like Button Tapped
    func handleLikeTapped(for cell: FeedCell, isDoubleTapped: Bool) {
        
        guard let post = cell.post else { return }
        
        // post.didLike가 true이면,
            // -> 기본값이 false임
        if post.didLike {
            // handle unlike post
            if !isDoubleTapped {
                post.adjustLikes(addLike: false) { likes in
                    cell.likesLabel.text = "\(likes) likes"
                    cell.likeButton.setImage(#imageLiteral(resourceName: "like_unselected"), for: .normal)
                }
            }
        } else {
            // handle like post
            post.adjustLikes(addLike: true) { likes in
                cell.likesLabel.text = "\(likes) likes"
                cell.likeButton.setImage(#imageLiteral(resourceName: "like_selected"), for: .normal)
            }
        }
    }
    
    func handleConfigureLikeButton(for cell: FeedCell) {
        
        guard let post = cell.post else { return }
        guard let postId = post.postId else { return }
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        USER_LIKES_REF.child(currentUid).observeSingleEvent(of: .value) { snapshot in
            
            // check if post id exists in user-like sturcture
            if snapshot.hasChild(postId) {
                post.didLike = true
                cell.likeButton.setImage(#imageLiteral(resourceName: "like_selected"), for: .normal)
            } else {
                post.didLike = false
                cell.likeButton.setImage(#imageLiteral(resourceName: "like_unselected"), for: .normal)
            }
        }
    }
    
    // add gesture
    func handleShowLikes(for cell: FeedCell) {
        guard let post = cell.post else { return }
        guard let postId = post.postId else { return }
        
        let followLikeVC = FollowLikeVC()
        followLikeVC.viewingMode = FollowLikeVC.ViewingMode(index: 2)
        followLikeVC.postId = postId
        
        navigationController?.pushViewController(followLikeVC, animated: true)
    }
    
    
    
    
    
    func handleCommentTapped(for cell: FeedCell) {
        
        guard let post = cell.post else { return }

        let commentVC = CommentVC(collectionViewLayout: UICollectionViewFlowLayout())
        
        commentVC.post = post
        
        self.navigationController?.pushViewController(commentVC, animated: true)
    }
}
