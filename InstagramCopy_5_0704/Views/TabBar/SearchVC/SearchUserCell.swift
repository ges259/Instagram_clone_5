//
//  SearchUserCell.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/05.
//

import UIKit

final class SearchUserCell: UITableViewCell {
    
    var user: User? {
        didSet {
            guard let profileImgeUrl = user?.profileImageUrl else { return }
            guard let userName = user?.userName else { return }
            guard let fullName = user?.name else { return }
            
            profileImageView.loadImageView(with: profileImgeUrl)
            
            self.textLabel?.text = userName
            self.detailTextLabel?.text = fullName
        }
    }
    
    
    
    
    
    // MARK: - ImageView
    private let profileImageView: UIImageView = {
        let img = UIImageView()
        
        img.image = UIImage(named: "profile_unselected")
        img.contentMode = .scaleAspectFill
        img.backgroundColor = .lightGray
        img.clipsToBounds = true
        
        return img
    }()
    
    
    
    
    
    
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        // add profile image view
        self.addSubview(self.profileImageView)
        self.profileImageView.anchor(top: nil, bottom: nil, leading: leadingAnchor, trailing: nil, paddingTop: 0, paddingBottom: 0, paddingLeading: 8, paddingTrailing: 0, width: 48, height: 48)
        self.profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.profileImageView.layer.cornerRadius = 48 / 2
        self.profileImageView.clipsToBounds = true
        
        self.textLabel?.text = "UserName"
        
        self.detailTextLabel?.text = "Full name"
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        self.textLabel?.frame = CGRect(x: 68, y: (textLabel?.frame.origin.y)! - 2,
                                       width: (self.textLabel?.frame.width)!,
                                       height: (self.textLabel?.frame.height)!)
        self.textLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        
        
        self.detailTextLabel?.frame = CGRect(x: 68, y: (detailTextLabel?.frame.origin.y)!,
                                             width: self.frame.width - 108,
                                             height: (self.detailTextLabel?.frame.height)!)
        self.detailTextLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        self.detailTextLabel?.textColor = .lightGray
    }
    
    

    
    
}
