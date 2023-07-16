//
//  NewMessageCell.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/13.
//

import UIKit

final class NewMessageCell: UITableViewCell {
    
    
    
    // MARK: - Properties
    var user: User? {
        didSet {
            guard let profileImageUrl = user?.profileImageUrl else { return }
            guard let userName = user?.userName else { return }
            guard let fullName = user?.name else { return }
            
            self.profileImageView.loadImageView(with: profileImageUrl)
            self.textLabel?.text = userName
            self.detailTextLabel?.text = fullName
        }
    }
    
    
    
    
    
    
    
    
    
    
    // MARK: - ImageView
    private let profileImageView: CustomImageView = {
        let img = CustomImageView()
        
        img.contentMode = .scaleAspectFill
        img.backgroundColor = .lightGray
        img.clipsToBounds = true
        
        return img
    }()
    
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        self.addSubview(self.profileImageView)
        self.profileImageView.layer.cornerRadius = 50 / 2
        self.profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.profileImageView.anchor(top: nil, bottom: nil,
                                     leading: self.leadingAnchor, trailing: nil,
                                     paddingTop: 0, paddingBottom: 0,
                                     paddingLeading: 12, paddingTrailing: 0,
                                     width: 50, height: 50)
        
        textLabel?.text = "batman"
        detailTextLabel?.text = "Some test label to see if this work"
        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.textLabel?.frame = CGRect(x: 68, y: self.textLabel!.frame.origin.y - 2, width: (self.textLabel?.frame.width)!, height: (self.textLabel?.frame.height)!)
        self.textLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        self.textLabel?.textColor = .black

        self.detailTextLabel?.frame = CGRect(x: 68, y: (self.detailTextLabel?.frame.origin.y)!, width: self.frame.width - 108, height: (self.detailTextLabel?.frame.height)!)
        self.detailTextLabel?.textColor = .lightGray
        self.detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
