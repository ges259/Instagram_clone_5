//
//  FeedCell.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/08.
//

import UIKit
import Firebase
import ActiveLabel

final class FeedCell: UICollectionViewCell {
    
    
    var delegate: FeedCellDelegate?
    
    var post: Post? {
        didSet {
            guard let ownerUid = post?.ownerUid else { return }
            guard let imageUrl = post?.imageUrl else { return }
            guard let likes = post?.likes else { return }
//            guard let date = post?.creationDate else { return }
            
            Database.fetchUser(with: ownerUid) { user in
//                self.profileImageView.loadImageView(with: user.profileImageUrl)
                self.userName.setTitle(user.userName, for: .normal)
                self.postImageView.loadImageView(with: imageUrl)
                self.configurePostCaption(user: user)
            }
            self.profileImageView.loadImageView(with: imageUrl)
            self.likesLabel.text = "\(likes) likes"
//            self.postTimeLabel.text = "\(date)"
            
            self.handleConfigureLikeButton()
        }
    }
    
    
    
    
    // MARK: - ImageView
    private let profileImageView: CustomImageView = {
        return CustomImageView().configureCustomImageView()
    }()
    private lazy var postImageView: CustomImageView = {
        let img = CustomImageView().configureCustomImageView()
        
        // add gesture recognizer for double tap to like
        let likeTap = UITapGestureRecognizer(target: self, action: #selector(self.handleDoubleTappedToLike))
            likeTap.numberOfTapsRequired = 2
        
            img.isUserInteractionEnabled = true
            img.addGestureRecognizer(likeTap)
        return img
    }()
    
    
    
    // MARK: - Button
    private lazy var userName: UIButton = {
        let btn = UIButton().button(title: "UserName",
                                    titleColor: UIColor.black,
                                    fontSize: 12)
            btn.addTarget(self, action: #selector(self.handleUserNameTapped), for: .touchUpInside)
        return btn
    }()
    private lazy var optionButton: UIButton = {
        let btn = UIButton().button(title: "•••",
                                    titleColor: UIColor.black,
                                    fontSize: 14)
            btn.addTarget(self, action: #selector(self.handleOptionsTapped), for: .touchUpInside)
        return btn
    }()
    lazy var likeButton: UIButton = {
        let btn = UIButton().button(image: "like_unselected")
        
            btn.addTarget(self, action: #selector(self.handleLikeTapped), for: .touchUpInside)
        return btn
    }()
    private lazy var commentButton: UIButton = {
        let btn = UIButton().button(image: "comment")

            btn.addTarget(self, action: #selector(self.handleCommentTapped), for: .touchUpInside)
        return btn
    }()
    private let messageButton: UIButton = {
        return UIButton().button(image: "send2")
    }()
    private let bookPostButton: UIButton = {
        return UIButton().button(image: "ribbon")
    }()
    
    
    
    // MARK: - StackView
    private lazy var stackView: UIStackView = {
        return UIStackView().stackView(arrangedSubviews:
                                            [self.likeButton,
                                             self.commentButton,
                                             self.messageButton],
                                       axis: .horizontal,
                                       distribution: .fillEqually)
    }()
    
    
    
    // MARK: - Label
    lazy var likesLabel: UILabel = {
        let lbl = UILabel().label(fontName: .bold,
                                  fontSize: 12)
        // add gesture recognizer to label
        let likeTap = UITapGestureRecognizer(target: self, action: #selector(self.handleShowLikes))
            likeTap.numberOfTapsRequired = 1
        
            lbl.isUserInteractionEnabled = true
            lbl.addGestureRecognizer(likeTap)
        return lbl
    }()
    let captionLabel: ActiveLabel = {
        let lbl = ActiveLabel()
            lbl.numberOfLines = 0
        return lbl
    }()
    private let postTimeLabel: UILabel = {
        return UILabel().label(LabelTextColor: UIColor.lightGray,
                               fontName: .bold,
                               fontSize: 12)
    }()
    
    
    
    // MARK: - Helper Functions
    private func configurePostCaption(user: User) {
        guard let post = self.post else { return }
        guard let caption = post.caption else { return }
        guard let userName = post.user?.userName else { return }
        
        // look for userName as pattern
        let customType = ActiveType.custom(pattern: "^\(userName)\\b")
        
        // enable userName as custom type
        self.captionLabel.enabledTypes = [.mention, .hashtag, .url, customType]
        
        // configure userName link attributes
        self.captionLabel.configureLinkAttribute = { ( type, attributes, isSelected) in
            var atts = attributes
            switch type {
            case .custom:
                atts[NSAttributedString.Key.font] = UIFont.boldSystemFont(ofSize: 12)
            default: ()
            }
            return atts
        }
        self.captionLabel.customize { label in
            label.text = "\(userName) \(caption)"
            label.customColor[customType] = .black
            label.font = UIFont.systemFont(ofSize: 12)
            label.textColor = .black
            captionLabel.numberOfLines = 2
        }
        self.postTimeLabel.text = post.creationDate.timeAgoToDisplay()
    }
    
    
    
    // MARK: - Selector
    // FeedVC
    @objc private func handleUserNameTapped() {
        self.delegate?.handleUserNameTapped(for: self)
    }
    @objc private func handleOptionsTapped() {
        self.delegate?.handleOptionsTapped(for: self)
    }
    @objc private func handleLikeTapped() {
        self.delegate?.handleLikeTapped(for: self, isDoubleTapped: false)
    }
    @objc private func handleCommentTapped() {
        self.delegate?.handleCommentTapped(for: self)
    }
    func handleConfigureLikeButton() {
        self.delegate?.handleConfigureLikeButton(for: self)
    }
    
    // gesture
    @objc private func handleShowLikes() {
        self.delegate?.handleShowLikes(for: self)
    }
    @objc private func handleDoubleTappedToLike() {
        self.delegate?.handleLikeTapped(for: self, isDoubleTapped: true)
    }
    
    
    
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
        self.profileImageView.anchor(top: self.topAnchor, paddingTop: 8,
                                     leading: self.leadingAnchor, paddingLeading: 8,
                                     width: 40, height: 40,
                                     cornerRadius: 40 / 2)

        // userName
        self.addSubview(self.userName)
        self.userName.anchor(leading: self.profileImageView.trailingAnchor, paddingLeading: 8,
                             centerY: self.profileImageView)
        
        // optionButton
        self.addSubview(self.optionButton)
        self.optionButton.anchor(trailing: self.trailingAnchor, paddingTrailing: 8,
                                 centerY: self.profileImageView)
        
        // postImageView
        self.addSubview(self.postImageView)
        self.postImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        self.postImageView.anchor(top: self.profileImageView.bottomAnchor, paddingTop: 8,
                                  leading: self.leadingAnchor,
                                  trailing: self.trailingAnchor)
        
        // stackView
        self.addSubview(self.stackView)
        self.stackView.anchor(top: self.postImageView.bottomAnchor, paddingTop: 0,
                              width: 120, height: 50)
        
        // bookPostButton
        self.addSubview(self.bookPostButton)
        self.bookPostButton.anchor(top: self.postImageView.bottomAnchor, paddingTop: 9,
                                   trailing: self.trailingAnchor, paddingTrailing: 8,
                                   width: 20, height: 24)
        
        // likesLabel
        self.addSubview(self.likesLabel)
        self.likesLabel.anchor(top: self.likeButton.bottomAnchor, paddingTop: -4,
                               leading: self.leadingAnchor, paddingLeading: 8)
        
        // captionLabel
        self.addSubview(self.captionLabel)
        self.captionLabel.anchor(top: self.likesLabel.bottomAnchor, paddingTop: 8,
                                 leading: self.leadingAnchor, paddingLeading: 8,
                                 trailing: self.trailingAnchor, paddingTrailing: 8)
        
        // postTimeLabel
        self.addSubview(self.postTimeLabel)
        self.postTimeLabel.anchor(top: self.captionLabel.bottomAnchor, paddingTop: 8,
                                  leading: self.leadingAnchor, paddingLeading: 8)
    }
}
