//
//  UserPostCell.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/06.
//

import UIKit

final class UserPostCell: UICollectionViewCell {
    
    // MARK: - Properties
    var post: Post? {
        didSet {
            guard let imageUrl = post?.imageUrl else { return }
            self.postIamgeView.loadImageView(with: imageUrl)
        }
    }
    
    
    
    // MARK: - Layout
    private let postIamgeView: CustomImageView = {
        return CustomImageView().configureCustomImageView()
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
        // background Color
        self.backgroundColor = .red
        
        // postIamgeView
        self.addSubview(self.postIamgeView)
        self.postIamgeView.anchor(top: self.topAnchor,
                                  bottom: self.bottomAnchor,
                                  leading: self.leadingAnchor,
                                  trailing: self.trailingAnchor)
    }
}

