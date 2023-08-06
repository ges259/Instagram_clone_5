//
//  ChatCell.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/13.
//

import UIKit
import Firebase

final class ChatCell: UICollectionViewCell {
    
    // MARK: - Properties
    // Anchor를 따로 설정하는 이유
        // 상대방이 보낸 메세지와 - 내가 보낸 메세지    는 같은 bubbleView를 사용한다.
        // 그렇기 때문에 사용자에 따라 다른 Anchor(제약)을 사용하여 다르게 표시
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?
    var bubbleViewLeftAnchor: NSLayoutConstraint?
    
    // ChatVC
    var delegate: ChatCellDelegate?
    
    var message: Message? {
        didSet {
            guard let messageText = message?.messageText else { return }
            self.textView.text = messageText
            
            guard let chatPartnerId = message?.getChatPartnerId() else { return }
            Database.fetchUser(with: chatPartnerId) { user in
                guard let profileImageUrl = user.profileImageUrl else { return }
                self.profileImageView.loadImageView(with: profileImageUrl)
            }
        }
    }
    
    
    
    // MARK: - ImageView
    lazy var profileImageView: CustomImageView = {
        let img = CustomImageView().configureCustomImageView()

        let imageTap = UITapGestureRecognizer(target: self, action: #selector(self.chatCellImageTapped))
            imageTap.numberOfTapsRequired = 1
        img.isUserInteractionEnabled = true
        img.addGestureRecognizer(imageTap)
        
        return img
    }()
    
    
    let bubbleView: UIView = {
        let view = UIView()
        
        view.backgroundColor = UIColor.rgb(red: 0, green: 137, blue: 249)
        
        view.clipsToBounds = true
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()
    
    let textView: UITextView = {
        let tv = UITextView()
        
        tv.text = "Sample text for now"
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.backgroundColor = .clear
        tv.isEditable = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        
        return tv
    }()
    
    
    
    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.configureUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    // MARK: - Selectors
    @objc private func chatCellImageTapped() {
        // ChatVC
        self.delegate?.chatCellImageTapped(for: self)
    }
    
    
    
    // MARK: - Configure UI
    private func configureUI() {
        // profileImageView
        self.addSubview(self.profileImageView)
        self.profileImageView.anchor(bottom: self.bottomAnchor, paddingBottom: -4,
                                     leading: self.leadingAnchor, paddingLeading: 8,
                                     width: 32, height: 32,
                                     cornerRadius: 32 / 2)
        
        // bubbleView ( 채팅 셀 )
        self.addSubview(self.bubbleView)
        // bubble view width and top anchor
        self.bubbleView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        self.bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        // 셀의 가로 폭 200
        self.bubbleWidthAnchor = self.bubbleView.widthAnchor.constraint(equalToConstant: 200)
        self.bubbleWidthAnchor?.priority = UILayoutPriority(rawValue: 747)
        self.bubbleWidthAnchor?.isActive = true
        
        // 셀의 오른쪽 Anchor
            // 내가 보낸 메세지박스(bubbleView)의 Anchor
        self.bubbleViewRightAnchor = self.bubbleView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8)
        self.bubbleViewRightAnchor?.priority = UILayoutPriority(rawValue: 748)
        self.bubbleViewRightAnchor?.isActive = true
        
        // 셀의 왼쪽 Anchor
            // 상대가 보낸 메세지박스(bubbleView) Anchor
        self.bubbleViewLeftAnchor?.priority = UILayoutPriority(rawValue: 749)
        self.bubbleViewLeftAnchor = self.bubbleView.leadingAnchor.constraint(equalTo: self.profileImageView.trailingAnchor, constant: 8)
        self.bubbleViewLeftAnchor?.isActive = false
        
        
        // bubble view text view anchor
        self.addSubview(self.textView)
        self.textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        self.textView.anchor(top: self.topAnchor, paddingTop: 8,
                             leading: self.bubbleView.leadingAnchor, paddingLeading: 8,
                             trailing: self.bubbleView.trailingAnchor)
        
//        self.textView.leadingAnchor.constraint(equalTo: self.bubbleView.leadingAnchor, constant: 8).isActive = true
//        self.textView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
//        self.textView.trailingAnchor.constraint(equalTo: self.bubbleView.trailingAnchor).isActive = true
    }
}
