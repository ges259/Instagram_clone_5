//
//  SearchResultVC.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/13.
//

import UIKit

private let reuserIdentifier = "SearchUserCell"

final class SearchResultVC: UITableViewController {
    
    
    var searchTerm: String?
    var inSearchMode: Bool = false
    var filteredUsers = [User]()

    
    var users = [User]() {
        didSet {
            tableView.reloadData()
        }
    }

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // register cell classes
        self.tableView?.register(SearchUserCell.self, forCellReuseIdentifier: reuserIdentifier)
        // separator insets
        self.tableView?.separatorInset = UIEdgeInsets(top: 0, left: 64, bottom: 0, right: 0)
    }
    
    
    
    
    
    // MARK: - TabelView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if inSearchMode {
            print("filteredUsers.count - \(filteredUsers.count)")
            return self.filteredUsers.count
        } else {
            print("users.count - \(users.count)")
            return users.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuserIdentifier, for: indexPath) as! SearchUserCell

        var user: User!

        if self.inSearchMode {
            user = self.filteredUsers[indexPath.row]
        } else {
            user = users[indexPath.row]
        }
        cell.user = user
//
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        var user: User!

        if self.inSearchMode {
            user = self.filteredUsers[indexPath.row]
            tableView.reloadData()
        } else {
            user = users[indexPath.row]
            tableView.reloadData()
        }


        // create instance of user profile vc
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())

        // passes user from searchVC to userProfileVC
        userProfileVC.user = user
//        userProfileVC.title = "Followers"
        // push view controller
        navigationController?.pushViewController(userProfileVC, animated: true)

    }
    
    
    
    
}


