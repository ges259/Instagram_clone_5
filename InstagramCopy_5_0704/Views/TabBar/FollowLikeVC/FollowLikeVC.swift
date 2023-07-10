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
    
    
    
    
    
    
    
    // MARK: - LifeSycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(FollowLikeCell.self, forCellReuseIdentifier: reuseIdentifer)
        
        
        // configure nav titles
        configureNavigationTitle()
        
        // fetch users
        fetchUsers()
        
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
        case .Followers: self.navigationItem.title = "Follower"
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
    
    private func fetchUser(with userId: String) {
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
           
            ref.child(uid).observeSingleEvent(of: .value) { snapshot in

                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                allObjects.forEach { snapshot in
                    
                    let userId = snapshot.key
                    self.fetchUser(with: userId)
                }
            }
        case .Likes:
            
            guard let postId = self.postId else { return }
            
            ref.child(postId).observe(.childAdded) { snapshot in
                
                let uid = snapshot.key
                self.fetchUser(with: uid)
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

