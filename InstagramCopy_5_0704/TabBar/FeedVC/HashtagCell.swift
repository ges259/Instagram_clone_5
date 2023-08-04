//
//  HashtagCell.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/14.
//

import UIKit

final class HashtagCell: UICollectionViewCell {
    
    // MARK: - Properties
    var post: Post? {
        didSet {
            guard let imageUrl = post?.imageUrl else { return }
            self.postIamgeView.loadImageView(with: imageUrl)
        }
    }
    
    
    
    // MARK: - ImageView
    private let postIamgeView: CustomImageView = {
        return CustomImageView().configureCustomImageView()
    }()
    
    
    
    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.addSubview(self.postIamgeView)
        self.postIamgeView.anchor(top: self.topAnchor,
                                  bottom: self.bottomAnchor,
                                  leading: self.leadingAnchor,
                                  trailing: self.trailingAnchor)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
