//
//  NewMessagesVC.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/13.
//

import UIKit
import Firebase

private let reuseIdentifier: String = "NewMessageCell"
final class NewMessageVC: UITableViewController {
    
    // MARK: - Properties
    
    
    var users = [User]()
    
    var messageVC = MessagesVC()
    
    
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.configureNavigationBar()
        
        self.tableView.register(NewMessageCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        
        // fetch user
        fetchUser()
    }
    
    
    
    
    
    
    
    // MARK: - Delegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    
    // MARK: - DataSource
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NewMessageCell
        
        cell.user = users[indexPath.row]
        
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true) {
            let chatPartnerUser = self.users[indexPath.row]
            self.messageVC.showChatController(withUser: chatPartnerUser)
        }
    }
    
    
    
    // MARK: - Handler
    func configureNavigationBar() {
        self.navigationItem.title = "New Message"
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        self.navigationItem.leftBarButtonItem?.tintColor = .black
    }
    @objc private func handleCancel() {
        self.dismiss(animated: true)
    }
    
    
    
    
    
    
    // MARK: - API
    private func fetchUser() {
        USER_REF.observe(.childAdded) { snapshot in
            let uid = snapshot.key
            
            if uid != Auth.auth().currentUser?.uid {
                Database.fetchUser(with: uid) { user in
                    self.users.append(user)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
}
