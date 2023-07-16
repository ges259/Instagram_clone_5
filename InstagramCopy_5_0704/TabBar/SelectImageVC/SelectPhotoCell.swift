//
//  SelectPhotoCell.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/08.
//

import UIKit

final class SelectPhotoCell: UICollectionViewCell {
    
    // MARK: - ImageView
    let photoImageView: UIImageView = {
        let img = UIImageView()
        
        img.contentMode = .scaleAspectFill
        img.backgroundColor = .lightGray
        img.clipsToBounds = true
        
        return img
    }()
    
    
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.photoImageView)
        self.photoImageView.anchor(top: self.topAnchor, bottom: self.bottomAnchor,
                                   leading: self.leadingAnchor, trailing: self.trailingAnchor,
                                   paddingTop: 0, paddingBottom: 0,
                                   paddingLeading: 0, paddingTrailing: 0,
                                   width: 0, height: 0)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
