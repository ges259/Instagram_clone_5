//
//  MessagesVC.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/13.
//

import UIKit
import Firebase


private let reuseIdentifier: String = "MessagesCell"

final class MessagesVC: UITableViewController {
    
    // MARK: - Properties
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureNavigationBar()
        
        self.tableView.register(MessageCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        // fetch messages
        self.fetchMessages()
    }
    
    
    
    // MARK: - Delegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    
    
    // MARK: - DataSource
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! MessageCell
            cell.message = messages[indexPath.row]
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        let chatParnerId = message.getChatPartnerId()
        
        Database.fetchUser(with: chatParnerId) { user in
            self.showChatController(withUser: user)
        }
    }
    
    
    
    // MARK: - Helper Functions
    func configureNavigationBar() {
        self.navigationItem.title = "Message"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                                 target: self,
                                                                 action: #selector(self.handleNewMessage))
    }
    
    func showChatController(withUser chatPartnerUser: User) {
        let chatVC = ChatVC(collectionViewLayout: UICollectionViewFlowLayout())
            chatVC.chatPartnerUser = chatPartnerUser
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    
    // MARK: - Selectors
    @objc private func handleNewMessage() {
        let newMessageVC = NewMessageVC()
            newMessageVC.messageVC = self
        let navigationController = UINavigationController(rootViewController: newMessageVC)
            navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true)
    }
    
    
    
    // MARK: - API
    private func fetchMessages() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        // 중복되지 않게 정리
        self.messages.removeAll()
        self.messagesDictionary.removeAll()
        self.tableView.reloadData()
        
        USER_MESSAGES_REF.child(currentUid).observe(.childAdded) { snapshot in
            let uid = snapshot.key
            
            USER_MESSAGES_REF.child(currentUid).child(uid).observe(.childAdded) { snapshot in
                
                let messageId = snapshot.key
                
                self.fetchMessage(withMessageId: messageId)
            }
        }
    }
    
    private func fetchMessage(withMessageId messageId: String) {
        MESSAGES_REF.child(messageId).observeSingleEvent(of: .value) { snapshot in
            
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
            
            let message = Message(dictionary: dictionary)
            
            // 테이블뷰에서 같은 사람에게 보낸 메세지들이 여러개가 뜨지 않게 하는 코드
            let chatPartnerId = message.getChatPartnerId()
            self.messagesDictionary[chatPartnerId] = message
            self.messages = Array(self.messagesDictionary.values)
            
            self.messages.sort { message1, message2 in
                return message1.creationDate > message2.creationDate
            }
            self.tableView?.reloadData()
        }
    }
}
