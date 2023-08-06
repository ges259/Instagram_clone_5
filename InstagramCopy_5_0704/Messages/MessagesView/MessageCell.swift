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
            self.configureUserData()
        }
    }
    
    
    // MARK: - ImageView
    private let profileImageView: CustomImageView = {
        return CustomImageView().configureCustomImageView()
    }()
    
    private let timestampLabel: UILabel = {
        return UILabel().label(labelText: "2b",
                                  LabelTextColor: UIColor.darkGray,
                                  fontName: .system,
                                  fontSize: 12)
    }()
    
    
    
    // MARK: - Helper Functions
    private func configureUserData() {
        guard let chatParnerId = message?.getChatPartnerId() else { return }
        
        Database.fetchUser(with: chatParnerId) { user in
            self.profileImageView.loadImageView(with: user.profileImageUrl)
            self.textLabel?.text = user.userName
        }
    }
    
    
    
    // MARK: - LifeCycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        // profileImageView
        self.addSubview(self.profileImageView)
        self.profileImageView.anchor(leading: self.leadingAnchor, paddingLeading: 12,
                                     width: 50, height: 50,
                                     centerY: self,
                                     cornerRadius: 50 / 2)
        // timestampLabel
        self.addSubview(self.timestampLabel)
        self.timestampLabel.anchor(top: self.topAnchor, paddingTop: 20,
                                   trailing: self.trailingAnchor, paddingTrailing: 12)
        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        // textLabel
        self.textLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        self.textLabel?.textColor = .black
        self.textLabel?.frame = CGRect(x: 68,
                                       y: self.textLabel!.frame.origin.y - 2,
                                       width: (self.textLabel?.frame.width)!,
                                       height: (self.textLabel?.frame.height)!)
        // detailTextLabel
        self.detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
        self.detailTextLabel?.textColor = .lightGray
        self.detailTextLabel?.frame = CGRect(x: 68,
                                             y: (self.detailTextLabel?.frame.origin.y)!,
                                             width: self.frame.width - 108,
                                             height: (self.detailTextLabel?.frame.height)!)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
