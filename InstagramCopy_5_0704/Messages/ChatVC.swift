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
    
//    var collectionViewBottomAnchor: NSLayoutConstraint?
    
    private lazy var containerView: UIView = {
        let containerView = UIView()
        
            containerView.frame = CGRect(x: 0, y: 0, width: 100, height: 55)
            // sendButton
            containerView.addSubview(self.sendButton)
            self.sendButton.anchor(trailing: containerView.trailingAnchor, paddingTrailing: 16,
                                   width: 50,
                                   centerY: containerView)
            // messageTextField
            containerView.addSubview(self.messageTextField)
            self.messageTextField.anchor(top: containerView.topAnchor,
                                         bottom: containerView.bottomAnchor,
                                         leading: containerView.leadingAnchor, paddingLeading: 12,
                                         trailing: self.sendButton.leadingAnchor, paddingTrailing: 20)
            // separatorView
            containerView.addSubview(self.separatorView)
            self.separatorView.anchor(top: containerView.topAnchor,
                                      leading: containerView.leadingAnchor,
                                      trailing: containerView.trailingAnchor,
                                      height: 0.5)
        return containerView
    }()
    private lazy var messageTextField: UITextField = {
        return UITextField().textField(withPlaceholder: "Enter message..")
    }()
    
    private lazy var sendButton: UIButton = {
        let btn = UIButton().button(title: "Send",
                                    fontName: .bold,
                                    fontSize: 14)
            btn.addTarget(self, action: #selector(self.handleSend), for: .touchUpInside)
        return btn
    }()
    
    private lazy var separatorView: UIView = {
        return UIView().backgrouncColorView(backgroundColor: UIColor.darkGray)
    }()
    
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // configure Nav + CollectionView
        self.configureChatVC()
        // 메세지 가져오기
        self.observeMessages()
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
            return self.containerView
        }
    }
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    
    
    // MARK: - CollectionView
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        return
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ChatCell
            cell.message = self.messages[indexPath.item]
            cell.delegate = self
        
        self.configureMessage(cell: cell, message: self.messages[indexPath.item])
        return cell
    }
    // cell의 height를 동적으로 조절
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let message = messages[indexPath.row]
        
        var height: CGFloat = 80
            height = self.estimateFrameForText(message.messageText).height + 20
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    
    
    // MARK: - Cell - Functions
    // cell에 관한 함수들
    private func estimateFrameForText( _ text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size,
                                                   options: options,
                                                   attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)],
                                                   context: nil)
    }
       
    private func configureMessage(cell: ChatCell, message: Message) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(message.messageText).width + 32
            cell.frame.size.height = self.estimateFrameForText(message.messageText).height + 20
        
        // 사용자가 보낸 메세지
        if message.fromId == currentUid {
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            cell.bubbleView.backgroundColor = UIColor.rgb(red: 210, green: 240, blue: 240)
            cell.profileImageView.isHidden = true
            
            
            // 상대가 보낸 메세지
        } else {
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
            cell.bubbleView.backgroundColor = UIColor.customGray
            cell.textView.textColor = .black
            cell.profileImageView.isHidden = false
        }
    }
    
    
    // MARK: - Helper Functions
    private func configureChatVC() {
        // configure CollectionView
        self.collectionView.backgroundColor = .white
        self.collectionView.register(ChatCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // configure NavigationBar
        // 네비게이션 타이틀에 액션 추가하기
        guard let user = self.chatPartnerUser else { return }
        let titleButton = UIButton(type: .infoLight).button(title: user.userName,
                                                            titleColor: UIColor.black,
                                                            fontName: .bold,
                                                            fontSize: 17)
            titleButton.addTarget(self, action: #selector(self.handleTitleTapped), for: .touchUpInside)
        
        self.navigationItem.titleView = titleButton
        
        // Nav - Right Bar Button
        let infoButton = UIButton(type: .infoLight)
            infoButton.tintColor = .black
            infoButton.addTarget(self, action: #selector(self.handleInfoTapped), for: .touchUpInside)
        let infoButtonItem = UIBarButtonItem(customView: infoButton)
        self.navigationItem.rightBarButtonItem = infoButtonItem
        
        
        
        
        
        // configure Bottom Anchor
            // UIViewController에 collectionView가 변수라면 해볼만 할 듯?
//        self.collectionViewBottomAnchor = self.collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor,
//                                                                                      constant: -55)
//        self.collectionViewBottomAnchor?.priority = UILayoutPriority(742)
//        self.collectionViewBottomAnchor?.isActive = true
    }
    
    
    
    // MARK: - Selectors
    @objc private func handleTitleTapped() {
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
            userProfileVC.user = self.chatPartnerUser
        self.navigationController?.pushViewController(userProfileVC, animated: true)
    }
    
    // 신고하기 / 취소 - 얼럿 만들기
    @objc private func handleInfoTapped() {
        self.presentAlertController(alertStyle: .actionSheet,
                                    secondButtonName: "신고") { _ in
            print(#function)
        }
    }
    
    @objc private func handleSend() {
        self.uploadMessageToServer()
        self.messageTextField.text = nil
    }
    
    
    
    // MARK: - API
    private func uploadMessageToServer() {
        guard let messageText = messageTextField.text else { return }
        // from user
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        // to user
        guard let userId = self.chatPartnerUser?.uid else { return }
        // 날짜 생성
        let creationDate = Int(NSDate().timeIntervalSince1970)
        // 배열 생성
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
            
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
                // 처음에 ChatVC에 들어온 상황 / 새로운 메세지가 온 상황
                    // 화면의 맨 밑으로 이동
                let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                self.collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
            }
            
        }
    }
}



// MARK: - ChatCellDelegate
extension ChatVC: ChatCellDelegate {
    func chatCellImageTapped(for cell: ChatCell) {
        print(#function)
        
        self.handleTitleTapped()
        
    }
}
