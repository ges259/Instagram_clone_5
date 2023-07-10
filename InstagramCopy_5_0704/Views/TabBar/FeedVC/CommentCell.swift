//
//  CommentCell.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/10.
//

import UIKit

final class CommentCell: UICollectionViewCell {
    
    
    
    
    // MARK: - Layout
    let profileImageView: CustomImageView = {
        let img = CustomImageView()
        img.contentMode = .scaleAspectFill
//        img.backgroundColor = .lightGray
        img.backgroundColor = .lightGray
        img.clipsToBounds = true
        
        return img
    }()
    
    
//
    let commentLabel: UILabel = {
        let lbl = UILabel()

        let attributedText = NSMutableAttributedString(string: "joker", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12)])
        attributedText.append(NSAttributedString(string: " Some test comment", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12)]))
        lbl.attributedText = attributedText

        return lbl
    }()

    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.profileImageView)
        self.profileImageView.layer.cornerRadius = 40 / 2
        self.profileImageView.anchor(top: self.topAnchor, bottom: nil,
                                     leading: self.leadingAnchor, trailing: nil,
                                     paddingTop: 8, paddingBottom: 0,
                                     paddingLeading: 8, paddingTrailing: 0,
                                     width: 40, height: 40)

        self.addSubview(self.commentLabel)
        self.commentLabel.centerYAnchor.constraint(equalTo: self.profileImageView.centerYAnchor).isActive = true
        self.commentLabel.anchor(top: nil, bottom: nil,
                             leading: self.profileImageView.trailingAnchor, trailing: nil,
                             paddingTop: 0, paddingBottom: 0,
                             paddingLeading: 8, paddingTrailing: 0,
                             width: 0, height: 0)

        
        
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
