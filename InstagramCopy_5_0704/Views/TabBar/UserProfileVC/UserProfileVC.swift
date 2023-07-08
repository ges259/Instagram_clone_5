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
//
//    var currentUser: User?
//
//
//    var userToLoadFromSearchVC: User?
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView!.register(UserPostCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)

        self.collectionView.backgroundColor = .white
        
        // fetch user data
        // 프로필을 직접 눌렀을 때만 fetch
            // 직접 누르면 user에 데이터가 들어감
            // 테이블뷰에서 넘어가면 user는 nil
        if self.user == nil {
            fetchCurrentUserData()
        }
        
        
    }
        
        
    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    // dataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 0
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
        
        
        
    
        return cell
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
        self.navigationItem.title = self.user?.userName

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
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    
    
    
    
    
    
    
    
    // MARK: - API
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
    
    
    
    
    
    
    
}




// MARK: - Delegate
extension UserProfileVC: UserProfileHeaderDelegate {
    
    func handleFollowersTapped(for header: UserProfileHeader) {
        let followVC = FollowLikeVC()
        followVC.viewFollowers = true
        followVC.uid = user?.uid
        self.navigationController?.pushViewController(followVC, animated: true)
    }
    func handleFollowingTapped(for header: UserProfileHeader) {
        let followVC = FollowLikeVC()
        followVC.viewFollowing = true
        followVC.uid = user?.uid
        self.navigationController?.pushViewController(followVC, animated: true)
    }
    func handleEditFollowTapped(for header: UserProfileHeader) {
        
        guard let user = header.user else { return }

        if header.editProfileFollowButton.titleLabel?.text == "Edit Profile" {
            
            let editProfileController = EditProfileController()
            editProfileController.user = user
            editProfileController.userProfileController = self
            let navigationController = UINavigationController(rootViewController: editProfileController)
            present(navigationController, animated: true, completion: nil)
        }
        else {
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
            let attributedText = NSMutableAttributedString(string: "\(numberOfFollowers!)\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSAttributedString(string: "followers", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
            
            header.followersLabel.attributedText = attributedText
        }

        // get number of following
        USER_FOLLOWING_REF.child(uid).observe(.value) { snapshot in
            if let snapshot = snapshot.value as? Dictionary<String, AnyObject> {
                numberOfFollowing = snapshot.count
            } else {
                numberOfFollowing = 0
            }
            
            let attributedText = NSMutableAttributedString(string: "\(numberOfFollowing!)\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSAttributedString(string: "following", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
            
            header.followingLabel.attributedText = attributedText
        }
        
        
        
        
//        let followVC = FollowLikeVC()
//
//        self.navigationController?.pushViewController(followVC, animated: true)
    }
    

    

}
