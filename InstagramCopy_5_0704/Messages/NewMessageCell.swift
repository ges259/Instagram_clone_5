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
            // data setup
            self.profileImageView.loadImageView(with: profileImageUrl)
            self.textLabel?.text = userName
            self.detailTextLabel?.text = fullName
        }
    }
    
    
    
    // MARK: - ImageView
    private let profileImageView: CustomImageView = {
        return CustomImageView().configureCustomImageView()
    }()
    
    
    // MARK: - LifeCycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        self.configureUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.textLabel?.textColor = .black
        self.textLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        self.textLabel?.frame = CGRect(x: 68,
                                       y: self.textLabel!.frame.origin.y - 2,
                                       width: (self.textLabel?.frame.width)!,
                                       height: (self.textLabel?.frame.height)!)
        
        self.detailTextLabel?.textColor = .lightGray
        self.detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
        self.detailTextLabel?.frame = CGRect(x: 68,
                                             y: (self.detailTextLabel?.frame.origin.y)!,
                                             width: self.frame.width - 108,
                                             height: (self.detailTextLabel?.frame.height)!)
    }
    
    
    
    // MARK: - Configure UI
    private func configureUI() {
        self.addSubview(self.profileImageView)
        self.profileImageView.anchor(leading: self.leadingAnchor, paddingLeading: 12,
                                     width: 50, height: 50,
                                     centerY: self,
                                     cornerRadius: 50 / 2)
    }
}
