//
//  UserProfileVC.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/05.
//

import UIKit
import Firebase
import FirebaseAuth

private let reuseIdentifier = "Cell"
private let headerIdentifier = "UserProfileHeader"

final class UserProfileVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // MARK: - properties
    var posts = [Post]()
    
    var user: User?
    
    var currentKey: String?

    
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureCollectionView()
        
        // configure refresh controller
        self.configureRefreshControl()
        
        // fetch user data
        // 프로필을 직접 눌렀을 때만 fetch
            // 직접 누르면 user에 데이터가 들어감
            // 테이블뷰에서 넘어가면 user는 nil
        if self.user == nil {
            self.fetchCurrentUserData()
        }
        // fetch post
        self.fetchPosts()
    }
    
    
    
    // MARK: - FlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (view.frame.width - 2) / 3
        
        return CGSize(width: width, height: width)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: view.frame.width, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    
    
    // MARK: - Header
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        // declare header
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! UserProfileHeader
        
            // set delegate
            header.delegate = self
        
            // set the user in header
                // 유저가 있으면 ( 직접 profile로 들어가면 ) 유저의 정보로 이동
            header.user = user
        self.navigationItem.title = user?.userName

//        if let user = self.user {
//            header.user = user
//            // searchVC를 통해서 들어가면 -> 해당 유저의 정보로 이도
//        } else if let userToLoadFromSearchVC = self.user {
//            header.user = userToLoadFromSearchVC
//            self.navigationItem.title = userToLoadFromSearchVC.userName
//        }
        
        // return header
        return header
    }
    
    
    // MARK: - Collection view
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if posts.count > 9 {
            // indexPath는 0부터 시작하기 때문에 -1을 해줌.
            // 포스트 셀의 개수와 포스트의 개수가 같으면
            if indexPath.item == posts.count - 1 {
                self.fetchPosts()
            }
        }
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    // dataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! UserPostCell
    
        // Configure the cell
            // date순으로 해야함
            cell.post = posts[indexPath.item]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let feedVC = FeedVC(collectionViewLayout: UICollectionViewFlowLayout())
        
            feedVC.userProfileController = self
        
            feedVC.viewSinglePost = true
            feedVC.post = self.posts[indexPath.item]
        
        self.navigationController?.pushViewController(feedVC, animated: true)
    }

    
    
    // MARK: - API
    private func fetchPosts() {
        var uid: String!
        
        // 사용자가 올린 게시글과 다른 사람이 올린 게시글을 분리
        if let user = self.user {
            uid = user.uid
        } else {
            uid = Auth.auth().currentUser?.uid
        }
        
        if currentKey == nil {
            USER_POSTS_REF.child(uid).queryLimited(toLast: 10).observeSingleEvent(of: .value) { snapshot in
                
                self.collectionView.refreshControl?.endRefreshing()
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                allObjects.forEach { snapshot in
                    let postId = snapshot.key
                    self.fetchPost(withPostId: postId)
                }
                self.currentKey = first.key
            }
        } else {
            // queryOrderedByKey : 하위 키에 따라 결과를 정렬한다.
            // queryEnding : 선택한 정렬 기준 메소드에 따라 지정된 키 또는 값보다 작거나 같은 항목을 반환한다.
            USER_POSTS_REF.child(uid).queryOrderedByKey().queryEnding(atValue: self.currentKey).queryLimited(toLast: 7).observeSingleEvent(of: .value) { snapshot in
                
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
    
    private func fetchPost(withPostId postid: String) {
        Database.fetchPost(with: postid) { post in
            self.posts.append(post)
            
            self.posts.sort { post1, post2 in
                return post1.creationDate > post2.creationDate
            }
            self.collectionView.reloadData()
        }
    }
    
    func fetchCurrentUserData() {
        // set user in header
        guard let currentUid = Auth.auth().currentUser?.uid else { return}
        
        Database.database().reference().child("users").child(currentUid).observeSingleEvent(of: .value) { snapshot in
            
            guard let userDictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
            
            let uid = snapshot.key
            
            let user = User(uid: uid, dictionary: userDictionary)
            
            self.user = user
            
            self.navigationItem.title = user.userName
            
            self.collectionView.reloadData()
        }
    }
    
    
    
    // MARK: - Helper Functions
    private func configureRefreshControl() {
        let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        self.collectionView.refreshControl = refreshControl
        
    }
    private func configureCollectionView() {
        self.collectionView!.register(UserPostCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)

        self.collectionView.backgroundColor = .white
    }
    
    
    
    // MARK: - Selectors
    @objc func handleRefresh() {
        self.posts.removeAll(keepingCapacity: false)
        self.currentKey = nil
        self.fetchPosts()
        self.collectionView.reloadData()
    }
}



// MARK: - UserProfileHeaderDelegate
extension UserProfileVC: UserProfileHeaderDelegate {
    
    func handleFollowersTapped(for header: UserProfileHeader) {
        let followLikeVC = FollowLikeVC()
            followLikeVC.viewingMode = FollowLikeVC.ViewingMode(index: 1)
            followLikeVC.uid = user?.uid
        self.navigationController?.pushViewController(followLikeVC, animated: true)
    }
    
    func handleFollowingTapped(for header: UserProfileHeader) {
        let followLikeVC = FollowLikeVC()
            followLikeVC.viewingMode = FollowLikeVC.ViewingMode(index: 0)
            followLikeVC.uid = user?.uid
        self.navigationController?.pushViewController(followLikeVC, animated: true)
    }
    
    func handleEditFollowTapped(for header: UserProfileHeader) {
        guard let user = header.user else { return }

        if header.editProfileFollowButton.titleLabel?.text == "Edit Profile" {
            let editProfileController = EditProfileController()
                editProfileController.user = user
                editProfileController.userProfileController = self
            
            let navigationController = UINavigationController(rootViewController: editProfileController)
                navigationController.modalPresentationStyle = .fullScreen
            self.present(navigationController, animated: true, completion: nil)
            
        } else {
            if header.editProfileFollowButton.titleLabel?.text == "Follow" {
                header.editProfileFollowButton.setTitle("Following", for: .normal)
                user.follow()
            }
            else {
                header.editProfileFollowButton.setTitle("Follow", for: .normal)
                user.unfollow()
            }
        }
    }
    
    func setUserStats(for header: UserProfileHeader) {
        guard let uid = header.user?.uid else { return }
        
        var numberOfFollowers: Int!
        var numberOfFollowing: Int!
        
        // get number of followers
        USER_FOLLOWER_REF.child(uid).observe(.value) { snapshot in
            
            if let snapshot = snapshot.value as? Dictionary<String, AnyObject> {
                numberOfFollowers = snapshot.count
            } else {
                numberOfFollowers = 0
            }
            
            
            let attributedText = NSMutableAttributedString().mutableAttributedText(type1TextString: "\(numberOfFollowers!)\n",
                                                                         type1FontName: .bold,
                                                                         type1FontSize: 14,
                                                                         type1Foreground: UIColor.black,
                                                                         
                                                                         type2TextString: "followers",
                                                                         type2FontName: .system,
                                                                         type2FontSize: 14,
                                                                         type2Foreground: UIColor.lightGray)
            header.followersLabel.attributedText = attributedText
        }

        // get number of following
        USER_FOLLOWING_REF.child(uid).observe(.value) { snapshot in
            if let snapshot = snapshot.value as? Dictionary<String, AnyObject> {
                numberOfFollowing = snapshot.count
            } else {
                numberOfFollowing = 0
            }
            
            let attributedText = NSMutableAttributedString().mutableAttributedText(type1TextString: "\(numberOfFollowing!)\n",
                                                                          type1FontName: .bold,
                                                                          type1FontSize: 14,
                                                                          type1Foreground: UIColor.black,
                                                                          
                                                                          type2TextString: "following",
                                                                          type2FontName: .bold,
                                                                          type2FontSize: 14,
                                                                          type2Foreground: UIColor.lightGray)
            header.followingLabel.attributedText = attributedText
        }
    }
}
