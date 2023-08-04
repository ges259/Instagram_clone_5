//
//  SelectPhotoHeader.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/08.
//

import UIKit

final class SelectPhotoHeader: UICollectionViewCell {
    
    
    // MARK: - ImageView
    let photoImageView: UIImageView = {
        let img = UIImageView()
        
            img.contentMode = .scaleAspectFill
            img.backgroundColor = .blue
            img.clipsToBounds = true
        return img
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
        self.addSubview(self.photoImageView)
        self.photoImageView.anchor(top: self.topAnchor,
                                   bottom: self.bottomAnchor,
                                   leading: self.leadingAnchor,
                                   trailing: self.trailingAnchor)
    }
}
