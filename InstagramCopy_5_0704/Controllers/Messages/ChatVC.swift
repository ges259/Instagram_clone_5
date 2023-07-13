//
//  ChatVC.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/13.
//

import UIKit
import Firebase

private let reuseIdentifier: String = "ChatCell"
final class ChatVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    
    // MARK: - Properties
    
    var chatPartnerUser: User?
    var messages = [Message]()
    
    private lazy var containerView: UIView = {
        let containerView = UIView()
        
        containerView.frame = CGRect(x: 0, y: 0, width: 100, height: 55)
        
        
        
        containerView.addSubview(self.sendButton)
        self.sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        self.sendButton.anchor(top: nil, bottom: nil,
                               leading: nil, trailing: containerView.trailingAnchor,
                               paddingTop: 0, paddingBottom: 0,
                               paddingLeading: 0, paddingTrailing: 16,
                               width: 50, height: 0)
        
        containerView.addSubview(self.messageTextField)
        self.messageTextField.anchor(top: containerView.topAnchor, bottom: containerView.bottomAnchor,
                                     leading: containerView.leadingAnchor, trailing: self.sendButton.leadingAnchor,
                                     paddingTop: 0, paddingBottom: 0,
                                     paddingLeading: 12, paddingTrailing: 20,
                                     width: 0, height: 0)
        
        containerView.addSubview(self.separatorView)
        self.separatorView.anchor(top: containerView.topAnchor, bottom: nil,
                                  leading: containerView.leadingAnchor, trailing: containerView.trailingAnchor,
                                  paddingTop: 0, paddingBottom: 0,
                                  paddingLeading: 0, paddingTrailing: 0,
                                  width: 0, height: 0.5)
        
        
        
        return containerView
    }()
    private let messageTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter message.."
        
        return tf
    }()
    private let sendButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        btn.setTitle("Send", for: .normal)
        btn.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        
        return btn
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        return view
    }()
    
    
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        
        self.collectionView.backgroundColor = .white
        self.collectionView.register(ChatCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        
        observeMessages()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    
    
    // MARK: - UICollectionView
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return messages.count
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ChatCell
        
        cell.message = messages[indexPath.item]
        configureMessage(cell: cell, message: messages[indexPath.item])
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        let message = messages[indexPath.row]
        
        height = estimateFrameForText(message.messageText).height + 20
        
        return CGSize(width: view.frame.width, height: height)
    }
     
    
    
    
    
    
    
    
    
    
    // MARK: - Handlers
    private func configureNavigationBar() {
        guard let user = self.chatPartnerUser else { return }
        
        navigationItem.title = user.userName
        
        let infoButton = UIButton(type: .infoLight)
        infoButton.tintColor = .black
        infoButton.addTarget(self, action: #selector(handleInfoTapped), for: .touchUpInside)
        
        let infoButtonItem = UIBarButtonItem(customView: infoButton)
        
        navigationItem.rightBarButtonItem = infoButtonItem
    }
    @objc private func handleInfoTapped() {
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileVC.user = chatPartnerUser
        navigationController?.pushViewController(userProfileVC, animated: true)
    }
    
    
    
    @objc private func handleSend() {
        uploadMessageToServer()
        messageTextField.text = nil
    }
    
    private func estimateFrameForText( _ text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    private func configureMessage(cell: ChatCell, message: Message) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        
        cell.bubbleWidthAnchor?.constant = estimateFrameForText(message.messageText).width + 32
        cell.frame.size.height = estimateFrameForText(message.messageText).height + 20
        
        if message.fromId == currentUid {
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            cell.bubbleView.backgroundColor = UIColor.rgb(red: 0, green: 137, blue: 249)
            cell.profileImageView.isHidden = true
        } else {
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
            cell.bubbleView.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
            cell.textView.textColor = .black
            cell.profileImageView.isHidden = false
        }
    }
    
    
    
    // MARK: - API
    private func uploadMessageToServer() {
        guard let messageText = messageTextField.text else { return }
        // from user
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        // to user
        guard let userId = self.chatPartnerUser?.uid else { return }
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        
        let messageValues = ["creationDate": creationDate,
                             "fromId": currentUid,
                             "toId": userId,
                             "messageText": messageText] as [String: Any]
        
        let messageRef = MESSAGES_REF.childByAutoId()
        
        guard let messageKey = messageRef.key else { return }
        
        messageRef.updateChildValues(messageValues) { err, ref in
            USER_MESSAGES_REF.child(currentUid).child(userId).updateChildValues([messageKey: 1])
            USER_MESSAGES_REF.child(userId).child(currentUid).updateChildValues([messageKey: 1])
        }
    }
    
    private func observeMessages() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let chatPartnerId = self.chatPartnerUser?.uid else { return }
        
        USER_MESSAGES_REF.child(currentUid).child(chatPartnerId).observe(.childAdded) { snapshot in
            let messageId = snapshot.key
            /*
             -N_EeYe7kjiMY9efYP2_
             -N_Eg89xLGV3lrVHOrxg
             */
            self.fetchMessage(withMessageId: messageId)
            
        }
    }
    private func fetchMessage(withMessageId messageId: String) {
        
        MESSAGES_REF.child(messageId).observeSingleEvent(of: .value) { snapshot in
            
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
                
            let message = Message(dictionary: dictionary)
            self.messages.append(message)
            
            self.collectionView?.reloadData()
        }
    }
    
    
    
}
