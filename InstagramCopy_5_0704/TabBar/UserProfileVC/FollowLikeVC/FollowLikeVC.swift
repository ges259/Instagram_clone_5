//
//  FollowLikeVC.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/06.
//

import UIKit
import Firebase
import FirebaseDatabase

private let reuseIdentifer = "FollowLikeCell"

final class FollowLikeVC: UITableViewController {
    
    // MARK: - Properties
    enum ViewingMode: Int {
        case Following
        case Followers
        case Likes
        init(index: Int) {
            switch index {
            case 0: self = .Following
            case 1: self = .Followers
            case 2: self = .Likes
            default: self = .Following
            }
        }
    }
    
    var postId: String?
    
    var viewingMode: ViewingMode!
    
    var uid: String?
    var users = [User]()
    
    var followCurrentKey: String?
    var likeCurrentKey: String?
    
    
    
    // MARK: - LifeSycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(FollowLikeCell.self, forCellReuseIdentifier: reuseIdentifer)
        
        // configure nav titles
        self.configureNavigationTitle()
        
        // fetch users
        self.fetchUsers()
    }
    
    
    
    
    // MARK: - tableView _ DataSource
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifer) as! FollowLikeCell
            cell.delegate = self
            cell.user = users[indexPath.row]
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // 처음 fetch르 4명으로 설정했으면 3명 이상이 될 때 새로 fetch를 시작
        if self.users.count > 3 {
            // 셀의 인덱스가 유저수와
            if indexPath.row == self.users.count - 1 {
                fetchUsers()
            }
        }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    // tableView _ Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = self.users[indexPath.row]
        
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
            userProfileVC.user = user
        self.navigationController?.pushViewController(userProfileVC, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
    
    // MARK: - Handler
    private func configureNavigationTitle() {
        guard let viewingMode = self.viewingMode else { return }

        // configure nav controller
        switch viewingMode {
        case .Following: self.navigationItem.title = "Following"
        case .Followers: self.navigationItem.title = "Followers"
        case .Likes: self.navigationItem.title = "Likes"
        }
    }
    
    
    
    // MARK: - API
    private func getDatabaseReference() -> DatabaseReference? {
        guard let viewingMode = self.viewingMode else { return nil }
        
        switch viewingMode {
        case .Following: return USER_FOLLOWING_REF
        case .Followers: return USER_FOLLOWER_REF
        case .Likes: return POST_LIKES_REF
        }
    }
    
    private func fetchUser(withUserId userId: String) {
        Database.fetchUser(with: userId) { user in
            self.users.append(user)
            self.tableView.reloadData()
        }
    }
    
    private func fetchUsers() {
        guard let viewingMode = self.viewingMode else { return }
        guard let ref = getDatabaseReference() else { return }
        
        switch viewingMode {
        case .Following, .Followers:
            guard let uid = self.uid else { return }
           
            if self.followCurrentKey == nil {
                ref.child(uid).queryLimited(toLast: 4).observeSingleEvent(of: .value) { snapshot in
                    
                    guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                    guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                    
                    allObjects.forEach { snapshot in
                        let followUid = snapshot.key
                        
                        self.fetchUser(withUserId: followUid)
                    }
                    self.followCurrentKey = first.key
                }
                
            } else {
                ref.child(uid).queryOrderedByKey().queryEnding(atValue: self.followCurrentKey).queryLimited(toLast: 5).observeSingleEvent(of: .value) { snapshot in
                    
                    guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                    guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                    
                    allObjects.forEach { snapshot in
                        let followUid = snapshot.key
                        
                        if followUid != self.followCurrentKey {
                            self.fetchUser(withUserId: followUid)
                        }
                    }
                    self.followCurrentKey = first.key
                }
            }
            
            
        case .Likes:
            guard let postId = self.postId else { return }
            
            if self.likeCurrentKey == nil {
                ref.child(postId).queryLimited(toLast: 4).observeSingleEvent(of: .value) { snapshot in
                    
                    guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                    guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                    
                    allObjects.forEach { snapshot in
                        let likeUid = snapshot.key
                        
                        self.fetchUser(withUserId: likeUid)
                    }
                    self.likeCurrentKey = first.key
                }
                
            } else {
                ref.child(postId).queryOrderedByKey().queryEnding(atValue: self.likeCurrentKey).queryLimited(toLast: 5).observeSingleEvent(of: .value) { snapshot in
                    
                    guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                    guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                    
                    allObjects.forEach { snapshot in
                        let likeUid = snapshot.key
                        
                        if likeUid != self.likeCurrentKey {
                            self.fetchUser(withUserId: likeUid)
                        }
                    }
                    self.likeCurrentKey = first.key
                }
            }
        }
    }
}



// MARK: - FollowCellDelegate
extension FollowLikeVC: FollowCellDelegate {
    
    func handleFollowTapped(for cell: FollowLikeCell) {
        guard let user = cell.user else { return }

        // isFollowed가 true이면 => follow상태
        if user.isFollowed {
            user.unfollow()
            cell.followButton.configure(didFollow: false)
            
        // isFollowed가 false이면 => unfollow상태
        } else {
            user.follow()
            cell.followButton.configure(didFollow: true)
        }
    }
}

