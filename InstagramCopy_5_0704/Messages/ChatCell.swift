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
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?
    var bubbleViewLeftAnchor: NSLayoutConstraint?
    
    var message: Message? {
        didSet {
            guard let messageText = message?.messageText else { return }
            textView.text = messageText
            
            guard let chatPartnerId = message?.getChatPartnerId() else { return }
            Database.fetchUser(with: chatPartnerId) { user in
                guard let profileImageUrl = user.profileImageUrl else { return }
                self.profileImageView.loadImageView(with: profileImageUrl)
            }
        }
    }
    
    
    
    // MARK: - ImageView
    let profileImageView: CustomImageView = {
        return CustomImageView().configureCustomImageView()
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
    
    
    
    // MARK: - Configure UI
    private func configureUI() {
        // profileImageView
        self.addSubview(self.profileImageView)
        self.profileImageView.anchor(bottom: self.bottomAnchor, paddingBottom: -4,
                                     leading: self.leadingAnchor, paddingLeading: 8,
                                     width: 32, height: 32,
                                     cornerRadius: 32 / 2)
        
        // bubbleView
        self.addSubview(self.bubbleView)
        // bubble view width and top anchor
        self.bubbleView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        self.bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        
        self.bubbleWidthAnchor = self.bubbleView.widthAnchor.constraint(equalToConstant: 200)
        self.bubbleWidthAnchor?.isActive = true
        
        
        self.bubbleViewRightAnchor = self.bubbleView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8)
        self.bubbleViewRightAnchor?.isActive = true
        
        // bubble view left anchor
        self.bubbleViewLeftAnchor = self.bubbleView.leadingAnchor.constraint(equalTo: self.profileImageView.trailingAnchor, constant: 8)
        self.bubbleViewLeftAnchor?.isActive = false
        
        
        // bubble view text view anchor
        self.addSubview(self.textView)
        self.textView.leadingAnchor.constraint(equalTo: self.bubbleView.leadingAnchor, constant: 8).isActive = true
        self.textView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        self.textView.trailingAnchor.constraint(equalTo: self.bubbleView.trailingAnchor).isActive = true
        self.textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }
}
