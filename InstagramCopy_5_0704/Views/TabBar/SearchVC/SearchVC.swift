//
//  SearchVC.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/05.
//

import UIKit
import Firebase

private let reuserIdentifier = "SearchUserCell"

final class SearchVC: UITableViewController {
    
    
    // MARK: - Properties
    var users = [User]()
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("SearchVC")
        
        // register cell classes
        self.tableView.register(SearchUserCell.self, forCellReuseIdentifier: reuserIdentifier)
        // separator insets
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 64, bottom: 0, right: 0)
        
        
        configreNavController()
        
        

        
        // fetch users
        fetchUsers()
    }
    
    
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuserIdentifier, for: indexPath) as! SearchUserCell
        
        cell.user = users[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

                let user = users[indexPath.row]
        
//        let user = User!
        
        

        
        // create instance of user profile vc
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        
        // passes user from searchVC to userProfileVC
        userProfileVC.user = user
        userProfileVC.title = "Followers"
        // push view controller
        navigationController?.pushViewController(userProfileVC, animated: true)
        
    }
    
    
    
    
    
    
    
    // MARK: - handler
    private func configreNavController() {
        self.navigationItem.title = "Explore"
    }
    
    
    
    
    
    
    
    
    
    // MARK: - API
    func fetchUsers() {
        // childAdded = 목록 가져오기
        Database.database().reference().child("users").observe(.childAdded) { snapshot in
            
            // uid
            let uid = snapshot.key
            
//            // snapshot value cast as dictionary
//            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
//
//            // construct user
//            let user = User(uid: uid, dictionary: dictionary)
//
//            // append user to data source
//            self.users.append(user)
//
//            // reload our table view
//            self.tableView.reloadData()
            
            Database.fetchUser(with: uid) { user in
                
                self.users.append(user)
                
                self.tableView.reloadData()
                
            }
            
            
            
        }
    }
    
    
    
    
    
    
}
