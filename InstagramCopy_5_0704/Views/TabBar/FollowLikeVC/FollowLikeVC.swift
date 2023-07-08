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
    var viewFollowers: Bool = false
    var viewFollowing: Bool = false
    
    
    var uid: String?
    
    var users = [User]()
    
    
    
    
    
    
    
    // MARK: - LifeSycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(FollowLikeCell.self, forCellReuseIdentifier: reuseIdentifer)
        
//        self.navigationItem.title = "Followers"
        
        // configure nav controller
        if viewFollowers {
            self.navigationItem.title = "Followers"
        } else {
            self.navigationItem.title = "Following"
        }
        
        
        // fetch users
        fetchUser()
        
        
        
        
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
    
    
    
    
    // MARK: - API
    func fetchUser() {
        
        guard let uid = self.uid else { return }
        var ref: DatabaseReference!
        
        // fetch Followers
        if viewFollowers {
            ref = USER_FOLLOWER_REF
        // fetch Following users
        } else {
            ref = USER_FOLLOWING_REF
        }
        
        ref.child(uid).observeSingleEvent(of: .value) { snapshot in

            guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            
            allObjects.forEach { snapshot in
                
                let userId = snapshot.key
                
                Database.fetchUser(with: userId) { user in
                    self.users.append(user)
                    self.tableView.reloadData()
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
//            cell.followButton.setTitle("Follow", for: .normal)
//            cell.followButton.setTitleColor(.white, for: .normal)
//            cell.followButton.layer.borderWidth = 0
//            cell.followButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
            
            cell.followButton.configure(didFollow: false)

            
            
        // isFollowed가 false이면 => unfollow상태
        } else {
            user.follow()
//            cell.followButton.setTitle("Following", for: .normal)
//            cell.followButton.setTitleColor(.black, for: .normal)
//            cell.followButton.layer.borderWidth = 0.5
//            cell.followButton.backgroundColor = .white
            
            
            cell.followButton.configure(didFollow: true)
        }
    }
}

