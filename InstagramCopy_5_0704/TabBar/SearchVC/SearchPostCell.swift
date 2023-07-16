//
//  SearchPostCell.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/13.
//

import UIKit

final class SearchPostCell: UICollectionViewCell {
    
    var post: Post? {
        didSet {
            guard let imageUrl = post?.imageUrl else { return }
            self.postIamgeView.loadImageView(with: imageUrl)
        }
    }
    
    
    private let postIamgeView: CustomImageView = {
        let img = CustomImageView()
        
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        img.backgroundColor = .lightGray
        
        return img
    }()
    
    
    
    
    
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.addSubview(self.postIamgeView)
        self.postIamgeView.anchor(top: self.topAnchor, bottom: self.bottomAnchor,
                                  leading: self.leadingAnchor, trailing: self.trailingAnchor,
                                  paddingTop: 0, paddingBottom: 0,
                                  paddingLeading: 0, paddingTrailing: 0,
                                  width: 0, height: 0)
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
