//
//  FeedCell.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/08.
//

import UIKit
import Firebase

final class FeedCell: UICollectionViewCell {
    
    
    var delegate: FeedCellDelegate?
    
    var post: Post? {
        didSet {
            guard let ownerUid = post?.ownerUid else { return }
            guard let imageUrl = post?.imageUrl else { return }
            guard let likes = post?.likes else { return }
            guard let date = post?.creationDate else { return }
            
            Database.fetchUser(with: ownerUid) { user in
                self.profileImageView.loadImageView(with: user.profileImageUrl)
                self.userName.setTitle(user.userName, for: .normal)
                self.postImageView.loadImageView(with: imageUrl)
                self.configurePostCaption(user: user)
            }
            self.profileImageView.loadImageView(with: imageUrl)
            self.likesLabel.text = "\(likes) likes"
            self.postTimeLabel.text = "\(date)"
            
        }
    }
    
    
    
    
    // MARK: - ImageView
    private let profileImageView: CustomImageView = {
        let img = CustomImageView()
        
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        img.backgroundColor = .lightGray
        
        return img
    }()
    private let postImageView: CustomImageView = {
        let img = CustomImageView()
        
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        img.backgroundColor = .lightGray
        
        return img
    }()
    
    
    
    // MARK: - Button
    private lazy var userName: UIButton = {
        let btn = UIButton(type: .system)
        
        btn.setTitle("UserName", for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        btn.setTitleColor(.black, for: .normal)
        
        btn.addTarget(self, action: #selector(handleUserNameTapped), for: .touchUpInside)
        
        return btn
    }()
    private lazy var optionButton: UIButton = {
        let btn = UIButton(type: .system)
        
        btn.setTitle("•••", for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        btn.setTitleColor(.black, for: .normal)
        
        btn.addTarget(self, action: #selector(handleOptionsTapped), for: .touchUpInside)

        return btn
    }()
    private lazy var likeButton: UIButton = {
        let btn = UIButton(type: .system)
        
        btn.setImage(#imageLiteral(resourceName: "like_unselected"), for: .normal)
        btn.tintColor = .black
        
        btn.addTarget(self, action: #selector(handleLikeTapped), for: .touchUpInside)

        return btn
    }()
    private lazy var commentButton: UIButton = {
        let btn = UIButton(type: .system)
        
        btn.setImage(#imageLiteral(resourceName: "comment"), for: .normal)
        btn.tintColor = .black
        
        btn.addTarget(self, action: #selector(handleCommentTapped), for: .touchUpInside)

        return btn
    }()
    private let messageButton: UIButton = {
        let btn = UIButton(type: .system)
        
        btn.setImage(#imageLiteral(resourceName: "send2"), for: .normal)
        btn.tintColor = .black
        
        return btn
    }()
    private let bookPostButton: UIButton = {
        let btn = UIButton(type: .system)
         
        btn.setImage(#imageLiteral(resourceName: "ribbon"), for: .normal)
        btn.tintColor = .black
        
        return btn
    }()
    
    
    
    // MARK: - StackView
    private lazy var stackView: UIStackView = {
        let stv = UIStackView(arrangedSubviews: [self.likeButton, self.commentButton, self.messageButton])
        
        stv.axis = .horizontal
        stv.distribution = .fillEqually
        
        return stv
    }()
    
    
    // MARK: - Lbael
    private let likesLabel: UILabel = {
        let lbl = UILabel()
        
        lbl.font = UIFont.boldSystemFont(ofSize: 12)
        lbl.text = "3 likes"
        
        return lbl
    }()
    private let captionLabel: UILabel = {
        let lbl = UILabel()
        
 
        

        return lbl
    }()
    private let postTimeLabel: UILabel = {
        let lbl = UILabel()
        
        lbl.textColor = .lightGray
        lbl.font = UIFont.boldSystemFont(ofSize: 12)
        lbl.text = "2 DAYS AGO"
        
        return lbl
    }()
    
    
    
    
    
    
    // MARK: - caption()
    private func configurePostCaption(user: User) {
        guard let post = self.post else { return }
        guard let caption = self.post?.caption else { return }
                
        let attributedText = NSMutableAttributedString(string: user.userName, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)])
        attributedText.append(NSAttributedString(string: " \(caption)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]))
        
        captionLabel.attributedText = attributedText


    }
    
    
    
    
    
    // MARK: - Handler
    @objc private func handleUserNameTapped() {
        delegate?.handleUserNameTapped(for: self)
    }
    @objc private func handleOptionsTapped() {
        delegate?.handleOptionsTapped(for: self)
    }
    @objc private func handleLikeTapped() {
        delegate?.handleLikeTapped(for: self)
    }
    @objc private func handleCommentTapped() {
        delegate?.handleCommentTapped(for: self)
    }
    
    
    
    
    
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.profileImageView)
        self.profileImageView.layer.cornerRadius = 40 / 2
        self.profileImageView.anchor(top: self.topAnchor, bottom: nil,
                                     leading: self.leadingAnchor, trailing: nil,
                                     paddingTop: 8, paddingBottom: 0,
                                     paddingLeading: 8, paddingTrailing: 0,
                                     width: 40, height: 40)
        
        
        self.addSubview(self.userName)
        self.userName.centerYAnchor.constraint(equalTo: self.profileImageView.centerYAnchor).isActive = true
        self.userName.anchor(top: nil, bottom: nil,
                             leading: self.profileImageView.trailingAnchor, trailing: nil,
                             paddingTop: 0, paddingBottom: 0,
                             paddingLeading: 8, paddingTrailing: 0,
                             width: 0, height: 0)
        
        self.addSubview(self.optionButton)
        self.optionButton.centerYAnchor.constraint(equalTo: self.profileImageView.centerYAnchor).isActive = true
        self.optionButton.anchor(top: nil, bottom: nil,
                                 leading: nil, trailing: self.trailingAnchor,
                                 paddingTop: 0, paddingBottom: 0,
                                 paddingLeading: 0, paddingTrailing: 8,
                                 width: 0, height: 0)
        
        
        self.addSubview(self.postImageView)
        self.postImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        self.postImageView.anchor(top: self.profileImageView.bottomAnchor, bottom: nil,
                                  leading: self.leadingAnchor, trailing: self.trailingAnchor,
                                  paddingTop: 8, paddingBottom: 0,
                                  paddingLeading: 0, paddingTrailing: 0,
                                  width: 0, height: 0)
        
        self.addSubview(self.stackView)
        self.stackView.anchor(top: self.postImageView.bottomAnchor, bottom: nil,
                              leading: nil, trailing: nil,
                              paddingTop: 0, paddingBottom: 0,
                              paddingLeading: 0, paddingTrailing: 0,
                              width: 120, height: 50)
        
        self.addSubview(self.bookPostButton)
        self.bookPostButton.anchor(top: self.postImageView.bottomAnchor, bottom: nil,
                                   leading: nil, trailing: self.trailingAnchor,
                                   paddingTop: 9, paddingBottom: 0,
                                   paddingLeading: 0, paddingTrailing: 8,
                                   width: 20, height: 24)
        
        self.addSubview(self.likesLabel)
        self.likesLabel.anchor(top: self.likeButton.bottomAnchor, bottom: nil, leading: self.leadingAnchor, trailing: nil, paddingTop: -4, paddingBottom: 0, paddingLeading: 8, paddingTrailing: 0, width: 0, height: 0)
        
        
        self.addSubview(self.captionLabel)
        self.captionLabel.anchor(top: self.likesLabel.bottomAnchor, bottom: nil, leading: self.leadingAnchor, trailing: self.trailingAnchor, paddingTop: 8, paddingBottom: 0, paddingLeading: 8, paddingTrailing: 8, width: 0, height: 0)
        
        
        self.addSubview(self.postTimeLabel)
        self.postTimeLabel.anchor(top: self.captionLabel.bottomAnchor, bottom: nil, leading: self.leadingAnchor, trailing: nil, paddingTop: 8, paddingBottom: 0, paddingLeading: 8, paddingTrailing: 0, width: 0, height: 0)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
