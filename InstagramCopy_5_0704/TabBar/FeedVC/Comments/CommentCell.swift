//
//  CommentCell.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/10.
//

import UIKit
import ActiveLabel

final class CommentCell: UICollectionViewCell {
    
    // MARK: - Properties
    var comment: Comment? {
        didSet{
            guard let user = comment?.user else { return }
            guard let profileImageUrl = user.profileImageUrl else { return }
            
            
            profileImageView.loadImageView(with: profileImageUrl)
            
            configureCommentLabel()
        }
    }
    
    
    
    // MARK: - Layout
    private let profileImageView: CustomImageView = {
        let img = CustomImageView()
        
        img.contentMode = .scaleAspectFill
        img.backgroundColor = .lightGray
        img.clipsToBounds = true
        
        return img
    }()

    let commentLabel: ActiveLabel = {
        let lbl = ActiveLabel()
        
        lbl.font = UIFont.systemFont(ofSize: 12)
        lbl.numberOfLines = 0
        
        return lbl
    }()
    
    private let separatorView: UIView = {
        return UIView().backgrouncColorView(backgroundColor: UIColor.lightGray)
    }()
    
    
    
    // MARK: - Helper Functions
    private func getCommentTimeStamp() -> String? {
        
        guard let comment = self.comment else { return nil }
        
        let dateFormatter = DateComponentsFormatter()
        dateFormatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        dateFormatter.maximumUnitCount = 1
        dateFormatter.unitsStyle = .abbreviated
        let now = Date()
        
        return dateFormatter.string(from: comment.creationDate, to: now)
    }
    
    private func configureCommentLabel() {
        guard let comment = self.comment else { return }
        guard let user = comment.user else { return }
        guard let userName = user.userName else { return }
        guard let commentText = comment.commentText else { return }
        
        let customType = ActiveType.custom(pattern: "^\(userName)\\b")
        
        self.commentLabel.enabledTypes = [.hashtag, .mention, .url, customType]
        
        commentLabel.configureLinkAttribute = {(type, attributes, isSelected) in
            var atts = attributes
            
            switch type {
            case .custom:
                atts[NSAttributedString.Key.font] = UIFont.boldSystemFont(ofSize: 12)
            default: ()
            }
            return atts
        }
        commentLabel.customize { label in
            label.text = "\(userName) \(commentText)"
            label.customColor[customType] = .black
            label.font = UIFont.systemFont(ofSize: 12)
            label.textColor = .black
            label.numberOfLines = 2
        }
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
        self.profileImageView.layer.cornerRadius = 40 / 2
        self.profileImageView.anchor(top: self.topAnchor, paddingTop: 8,
                                     leading: self.leadingAnchor, paddingLeading: 8,
                                     width: 40, height: 40)
        // commentLabel
        self.addSubview(self.commentLabel)
        self.commentLabel.anchor(top: self.topAnchor, paddingTop: 4,
                                 bottom: self.bottomAnchor, paddingBottom: 4,
                                 leading: self.profileImageView.trailingAnchor, paddingLeading: 4,
                                 trailing: self.trailingAnchor, paddingTrailing: 4)
        // separatorView
        self.addSubview(self.separatorView)
        self.separatorView.anchor(bottom: self.bottomAnchor,
                                  leading: self.leadingAnchor, paddingLeading: 60,
                                  trailing: self.trailingAnchor,
                                  height: 0.5)
    }
}
