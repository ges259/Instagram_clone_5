//
//  NotificationCell.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/11.
//

import UIKit

final class NotificationCell: UITableViewCell {
    
    
    
    
    // MARK: - Layout
    private let profileImageView: CustomImageView = {
        let img = CustomImageView()
        img.contentMode = .scaleAspectFill
        img.backgroundColor = .lightGray
        img.clipsToBounds = true

        return img
    }()
    private let postImageView: CustomImageView = {
        let img = CustomImageView()
        img.contentMode = .scaleAspectFill
        img.backgroundColor = .lightGray
        img.clipsToBounds = true

        return img
    }()
    
    private let notificationLabel: UILabel = {
        let lbl = UILabel()
        
        let attributedText = NSMutableAttributedString(string: "joker", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12)])
        attributedText.append(NSAttributedString(string: " commented on your post", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)]))
        attributedText.append(NSAttributedString(string: " 2d", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        lbl.attributedText = attributedText
        
        return lbl
    }()
    
    private let followButton = {
        let btn = UIButton(type: .system)
        
        btn.setTitle("", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        btn.addTarget(self, action: #selector(handleFollowTapped), for: .touchUpInside)
        
        
        return btn
    }()
    
    
    
    
    
    
    // MARK: - Handler
    @objc private func handleFollowTapped() {
        print("Handle Follow Button Tapped")
    }
    
    
    
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(self.profileImageView)
        self.profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.profileImageView.layer.cornerRadius = 40 / 2
        self.profileImageView.anchor(top: nil, bottom: nil,
                                     leading: self.leadingAnchor, trailing: nil,
                                     paddingTop: 0, paddingBottom: 0,
                                     paddingLeading: 8, paddingTrailing: 0,
                                     width: 40, height: 40)
        
        self.addSubview(self.followButton)
        self.followButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.followButton.layer.cornerRadius = 3
        self.followButton.anchor(top: nil, bottom: nil,
                                 leading: nil, trailing: self.trailingAnchor,
                                 paddingTop: 0, paddingBottom: 0,
                                 paddingLeading: 0, paddingTrailing: 12,
                                 width: 90, height: 30)
        self.followButton.isHidden = true
        
        

        
        self.addSubview(self.postImageView)
        self.postImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.postImageView.anchor(top: nil, bottom: nil,
                                  leading: nil, trailing: self.trailingAnchor,
                                  paddingTop: 0, paddingBottom: 0,
                                  paddingLeading: 0, paddingTrailing: 8,
                                  width: 40, height: 40)
        
        
        self.addSubview(self.notificationLabel)
        self.notificationLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.notificationLabel.anchor(top: nil, bottom: nil,
                                      leading: self.profileImageView.trailingAnchor, trailing: self.followButton.leadingAnchor,
                                      paddingTop: 0, paddingBottom: 0,
                                      paddingLeading: 8, paddingTrailing: 8,
                                      width: 0, height: 0)
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
