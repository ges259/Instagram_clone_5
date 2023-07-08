//
//  UserPostCell.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/06.
//

import UIKit

final class UserPostCell: UICollectionViewCell {
    
    
    
    
    
    
    private let postIamgeView: UIImageView = {
        let img = UIImageView()
        
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        img.backgroundColor = .lightGray
        
        return img
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("UserPostCell")
        
        self.backgroundColor = .red
        
        self.addSubview(self.postIamgeView)
        self.postIamgeView.anchor(top: self.topAnchor, bottom: self.bottomAnchor, leading: self.leadingAnchor, trailing: self.trailingAnchor, paddingTop: 0, paddingBottom: 0, paddingLeading: 0, paddingTrailing: 0, width: 0, height: 0)
        
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
}
