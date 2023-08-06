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
    // 포스트들을 담아두는 배열
    var posts = [Post]()
    // norificationVC, userPorileVC, SearchVC, HashtagVC 등에서 포스트를 선택해서 들어가는 상황
        // -> 포스터가 하나만 필요한 상황에서 사용
    var post: Post?
    // post가 사용될 때 viewSinglePost를 true로 바꿔 해당 포스터 1개만 나오도록 함
    var viewSinglePost: Bool = false
    
    // 포스터를 5개씩 가져오는데 해당 키(currentKey)를 통해서 구별
    private var currentKey: String?
    //
    var userProfileController: UserProfileVC?
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // background Color
        self.collectionView.backgroundColor = .white
        // register cell
        self.collectionView!.register(FeedCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // refresh
        self.refreshController()
        // configure Nav
        self.configureNavigationBar()
        // viewSinglePost가 아닐 경우 -> 처음 feed에 들어올 때
            // 즉, 여러개의 포스터들을 가져오는 경우
        if !viewSinglePost {
            self.fetchPosts()
        }
    }
    
    
    
    // MARK: - collection view
    // posts의 개수가
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // 해당 함수의 작동 방식:
        // fetchPosts는 처음에 viewDidLoad()에서 5개가 불림.
            // 그 이후 사용자가 5번째 포스터를 보는 순간 fetchPosts()를 호출하여 6개를 더 가져옴.
        
        // fetchPosts를 하면 항상 4개 이상(처음 5개, 이후 6개씩)이지만
            // 처음 feed를 들어왔을 때를 대비하여 if문을 사용
        if self.posts.count > 4 {
            // 스크롤을 내리면서 cell을 그리다가 (indexPath.item이 1씩 증가함)
                // -1을 하는 이유 ====>>> indexPath는 0부터 시작하므로, posts의 개수에서 1을 빼주어야 한다.
            
            // 결론: 사용자가 마지막 포스트를 보는 순간 (indexPath.item <<- 마지막 셀이 그려지는 순간) 추가적으로 posts를 가져온다.s
            if indexPath.item == posts.count - 1 {
                self.fetchPosts()
            }
        }
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // viewSingPost가 true이면 1개
            // false이면 posts의 개수만큼 표시ß
        return self.viewSinglePost ? 1 : self.posts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FeedCell
            cell.delegate = self
        
        if self.viewSinglePost {
            // 포스트가 맞는지 확인
            if let post = self.post {
                cell.post = post
            }
        } else {
            cell.post = self.posts[indexPath.row]
        }
        
        // -> 셀에 있는 Layout에 기능을 넣어주는 코드
            // delegate를 사용할 수 있지만 이렇게도 사용할 수 있음
        // 해당 이름으로 해쉬태그 된 포스터들을 보여줌
        self.handleHashtagTapped(forCell: cell)
        // 해당 유저 이름의 userProfile로 이동
        self.handleUserNameLabelTapped(forCell: cell)
        // 해당 유저 이름의 userProfile로 이동
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
    
    
    
    // MARK: - Selectors
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
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc private func handleRefresh() {
        self.posts.removeAll(keepingCapacity: false)
        // currentKey를 nil로 설정하여 다시 5개의 post를 가져옴
        self.currentKey = nil
        self.fetchPosts()
        self.collectionView.reloadData()
    }
    
    
    
    // MARK: - Helper Functions
    private func configureNavigationBar() {
        if !viewSinglePost {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(self.handleLogout))
        }
        self.navigationItem.title = "Feed"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "send2"),
                                                                 style: .plain,
                                                                 target: self,
                                                                 action: #selector(self.handleShowMessages))
    }
    // refresh 설정
    private func refreshController() {
        // configure refresh control
        let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(self.handleRefresh), for: .valueChanged)
        self.collectionView.refreshControl = refreshControl
    }
    
    // 해당 이름으로 해쉬태그 된 포스터들을 보여줌
    private func handleHashtagTapped(forCell cell: FeedCell) {
        cell.captionLabel.handleHashtagTap { hashtag in
            let hashtagVC = HashtagVC(collectionViewLayout: UICollectionViewFlowLayout())
                hashtagVC.hashtag = hashtag
            self.navigationController?.pushViewController(hashtagVC, animated: true)
        }
    }
    // 해당 유저 이름의 userProfile로 이동
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
    // 해당 유저 이름의 userProfile로 이동
    private func handleMentionTapped(forCell cell: FeedCell) {
        cell.captionLabel.handleMentionTap { userName in
            self.getMentionUser(withuserName: userName)
        }
    }
    
    
    
    // MARK: - API
    // 모든 포스터들을 가져오는 코드
        // 하지만 모든 포스터들을 가져오는 것은 비효율적
            // -> 5개 -> 3개 등 나눠서 가져와야 하기 때문에
                // 해당 함수(updateUserFeeds) 대신 ===>>> fetchPosts()를 사용
    
//    private func updateUserFeeds() {
//
//        guard let currentId = Auth.auth().currentUser?.uid else { return }
//
//        USER_FOLLOWING_REF.child(currentId).observe(.childAdded) { snapshot in
//
//            let followingUserId = snapshot.key
//            // followingUserId: 자신이 follow한 사람들
//            USER_POSTS_REF.child(followingUserId).observe(.childAdded) { snapshot in
//                // snapshot : current-user를 follow한 사람들
//                let postId = snapshot.key
//
//                USER_FEED_REF.child(currentId).updateChildValues([postId: 1])
//            }
//        }
//        USER_POSTS_REF.child(currentId).observe(.childAdded) { snapshot in
//            let postId = snapshot.key
//
//            USER_FEED_REF.child(currentId).updateChildValues([postId: 1])
//        }
//    }
//
    
    
    
    
    
    private func fetchPosts() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        // cueernetKey가 nil이면 -> 처음 화면은 무조건 nil.
        // 첫 시작은 if문으로 시작되고 그 이후에 fetchPosts가 불리면 else로 빠짐
        if self.currentKey == nil {
            // 일단 5개만 받아오기
            USER_FEED_REF.child(currentUid).queryLimited(toLast: 5).observeSingleEvent(of: .value) { snapshot in
                self.collectionView.refreshControl?.endRefreshing()
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                allObjects.forEach { snapshot in
                    let postId = snapshot.key
                    // post 데이터 가져오기
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
                        // post 데이터 가져오기
                        self.fetchPost(withPostId: postId)
                        self.fetchPost(withPostId: postId)
                    }
                }
                self.currentKey = first.key
            }
        }
    }
    // 포스터를 데이터베이스에서 가져오는 코드
        // 정렬까지 해줌
    private func fetchPost(withPostId postId: String) {
        Database.fetchPost(with: postId) { post in
            self.posts.append(post)
            // 날짜 순으로 정렬
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
        
        // 자신(사용자)가 올린 포스트에만 반응
        if post.ownerUid == Auth.auth().currentUser?.uid {
            let alertController = UIAlertController(title: "Options", message: nil, preferredStyle: .actionSheet)
            
            alertController.addAction(UIAlertAction(title: "Delete Post", style: .destructive, handler: { _ in
                post.deletePost()
                
                if !self.viewSinglePost {
                    self.handleRefresh()
                } else {
                    if let userProfileController = self.userProfileController {
                            userProfileController.handleRefresh()
                        self.navigationController?.popViewController(animated: true)
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
            
            self.present(alertController, animated: true, completion: nil)
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
        
        self.navigationController?.pushViewController(followLikeVC, animated: true)
    }
    
    func handleCommentTapped(for cell: FeedCell) {
        
        guard let post = cell.post else { return }

        let commentVC = CommentVC(collectionViewLayout: UICollectionViewFlowLayout())
            commentVC.post = post
        
        self.navigationController?.pushViewController(commentVC, animated: true)
    }
}
