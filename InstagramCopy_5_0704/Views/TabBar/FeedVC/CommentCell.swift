//
//  CommentCell.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/10.
//

import UIKit

final class CommentCell: UICollectionViewCell {
    
    
    // MARK: - Properties
    var comment: Comment? {
        didSet{
            guard let user = comment?.user else { return }
            guard let profileImageUrl = user.profileImageUrl else { return }
            guard let userName = user.userName else { return }
            guard let commentText = comment?.commentText else { return }
            
            profileImageView.loadImageView(with: profileImageUrl)
            
            let attributedText = NSMutableAttributedString(string: userName, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12)])
            attributedText.append(NSAttributedString(string: " \(commentText)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]))
            attributedText.append(NSAttributedString(string: " 2d", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
            self.commentTextView.attributedText = attributedText
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
    

    private let commentTextView: UITextView = {
        let tv = UITextView()
        
        tv.font = UIFont.systemFont(ofSize: 12)
        tv.isScrollEnabled = false
        
        tv.autocorrectionType = .no
        tv.autocapitalizationType = .none
        
        return tv
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        
        view.backgroundColor = .lightGray
        
        return view
    }()
    
    

    
    
    
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

        self.addSubview(self.commentTextView)
        self.commentTextView.anchor(top: self.topAnchor, bottom: self.bottomAnchor,
                                    leading: self.profileImageView.trailingAnchor, trailing: self.trailingAnchor,
                             paddingTop: 4, paddingBottom: 4,
                             paddingLeading: 4, paddingTrailing: 4,
                             width: 0, height: 0)
        
        self.addSubview(self.separatorView)
        self.separatorView.anchor(top: nil, bottom: self.bottomAnchor,
                                  leading: self.leadingAnchor, trailing: self.trailingAnchor,
                                  paddingTop: 0, paddingBottom: 0,
                                  paddingLeading: 60, paddingTrailing: 0,
                                  width: 0, height: 0.5)

    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
