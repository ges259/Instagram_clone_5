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
        let img = CustomImageView()
        
        img.contentMode = .scaleAspectFill
        img.backgroundColor = .lightGray
        img.clipsToBounds = true
        
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
        tv.textColor = .white
        tv.isEditable = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        
        return tv
    }()
    
    
    
    
    
    
    
    
    
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
//        self.backgroundColor = .red
        
        
        self.addSubview(self.profileImageView)
        self.profileImageView.layer.cornerRadius = 32 / 2
        self.profileImageView.anchor(top: nil, bottom: self.bottomAnchor,
                                     leading: self.leadingAnchor, trailing: nil,
                                     paddingTop: 0, paddingBottom: -4,
                                     paddingLeading: 8, paddingTrailing: 0,
                                     width: 32, height: 32)
        

//
        
        self.addSubview(self.bubbleView)
        // bubble view right anchor
        bubbleViewRightAnchor = bubbleView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8)
        bubbleViewRightAnchor?.isActive = true
        
        // bubble view left anchor
        bubbleViewLeftAnchor = bubbleView.trailingAnchor.constraint(equalTo: self.profileImageView.trailingAnchor, constant: 8)
        bubbleViewLeftAnchor?.isActive = false
        
        // bubble view width and top anchor
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        
        
        
        // bubble view text view anchor
        self.addSubview(self.textView)
        textView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 8).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        textView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
