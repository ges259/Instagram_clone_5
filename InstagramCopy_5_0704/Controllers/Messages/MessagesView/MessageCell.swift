//
//  MessagesCell.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/13.
//

import UIKit
import Firebase

final class MessageCell: UITableViewCell {

    // MARK: - Properties
    
    
    var message: Message? {
        didSet {
            guard let messagetext = message?.messageText else { return }
            detailTextLabel?.text = messagetext
            if let second = message?.creationDate {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm a"
                self.timestampLabel.text = dateFormatter.string(from: second)
            }
            configureUserData()
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
    
    private let timestampLabel: UILabel = {
        let lbl = UILabel()
        
        lbl.font = UIFont.systemFont(ofSize: 12)
        lbl.textColor = .darkGray
        lbl.text = "2b"
        return lbl
    }()
    
    
    
    // MARK: - Handler
    private func configureUserData() {
        
        guard let chatParnerId = message?.getChatPartnerId() else { return }
        
        
        Database.fetchUser(with: chatParnerId) { user in
            self.profileImageView.loadImageView(with: user.profileImageUrl)
            self.textLabel?.text = user.userName
        }
    }
    
    
    
    
    
    
    
    
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
        
        self.addSubview(self.timestampLabel)
        self.timestampLabel.anchor(top: self.topAnchor, bottom: nil,
                                   leading: nil, trailing: self.trailingAnchor,
                                   paddingTop: 20, paddingBottom: 0,
                                   paddingLeading: 0, paddingTrailing: 12,
                                   width: 0, height: 0)
        
        
        
        textLabel?.text = "batman"
        detailTextLabel?.text = "batbatbatbat"
        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.textLabel?.frame = CGRect(x: 68, y: self.textLabel!.frame.origin.y - 2, width: (self.textLabel?.frame.width)!, height: (self.textLabel?.frame.height)!)
        self.textLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        self.textLabel?.textColor = .black

        self.detailTextLabel?.frame = CGRect(x: 68, y: (self.detailTextLabel?.frame.origin.y)!, width: self.frame.width - 108, height: (self.detailTextLabel?.frame.height)!)
        self.detailTextLabel?.textColor = .lightGray
        self.detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
//        textLabel?.anchor(top: self.profileImageView.topAnchor, bottom: nil,
//                          leading: self.profileImageView.trailingAnchor, trailing: self.leadingAnchor, paddingTop: 8, paddingBottom: 0,
//                          paddingLeading: 12, paddingTrailing: 8,
//                          width: 0, height: 0)
//
//        detailTextLabel?.anchor(top: self.textLabel?.topAnchor, bottom: nil,
//                                leading: self.profileImageView.trailingAnchor, trailing: self.leadingAnchor,
//                                paddingTop: 20, paddingBottom: 0,
//                                paddingLeading: 12, paddingTrailing: 8,
//                                width: 0, height: 0)
//
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
