//
//  NotificationCell.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/11.
//

import UIKit

final class NotificationCell: UITableViewCell {

    
    var delegate: NotificationCellDelegate?
    
    
    // MARK: - Properties
    var notification: Notification? {
        didSet {
            guard let user = notification?.user else { return }
            guard let profileImageUrl = user.profileImageUrl else { return }
            
            // configure notification label
            configureNotificationLabel()
            
            // configure notification type
            configureNotificationType()
            
            
            
            
            profileImageView.loadImageView(with: profileImageUrl)

            
            if let post = notification?.post {
                self.postImageView.loadImageView(with: post.imageUrl)
            }
        }
    }
    
    
    
    
    // MARK: - Layout
    private let profileImageView: CustomImageView = {
        let img = CustomImageView()
        img.contentMode = .scaleAspectFill
        img.backgroundColor = .lightGray
        img.clipsToBounds = true

        return img
    }()
    lazy var postImageView: CustomImageView = {
        let img = CustomImageView()
        img.contentMode = .scaleAspectFill
        img.backgroundColor = .lightGray
        img.clipsToBounds = true
        
        let postTap = UITapGestureRecognizer(target: self, action: #selector(handlePostTapped))
        postTap.numberOfTapsRequired = 1
        img.isUserInteractionEnabled = true
        img.addGestureRecognizer(postTap)
        
        return img
    }()
     
    private let notificationLabel: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 2
        
        return lbl
    }()
    
    lazy var followButton: UIButton = {
        let btn = UIButton(type: .system)
        
        btn.setTitle("", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        btn.addTarget(self, action: #selector(handleFollowTapped), for: .touchUpInside)
        
        
        return btn
    }()
    
    
    
    
    
    
    
    // MARK: - Delegate
    @objc private func handleFollowTapped() {
        delegate?.handleFollowTapped(for: self)
    }
    @objc private func handlePostTapped() {
        delegate?.handlePostTapped(for: self)
    }
    
    
    // MARK: - Handler
    
    private func configureNotificationLabel() {
        guard let notification = self.notification else { return }
        guard let user = notification.user else { return }
        guard let userName = user.userName else { return }
        let notificationsMessage = notification.notificationType.description

        guard let notificationDate = getNotificationTimeStamp() else { return }
        
        let attributedText = NSMutableAttributedString(string: userName, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12)])
        attributedText.append(NSAttributedString(string: notificationsMessage, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)]))
        attributedText.append(NSAttributedString(string: " \(notificationDate)", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        notificationLabel.attributedText = attributedText
    }
    
    private func configureNotificationType() {
        guard let notification = self.notification else { return }
        guard let user = notification.user else { return }
        
        
        
        if notification.notificationType != .Follow {
            // notification type is comment or like
            self.contentView.addSubview(postImageView)
            self.postImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            self.postImageView.anchor(top: nil, bottom: nil,
                                      leading: nil, trailing: self.trailingAnchor,
                                      paddingTop: 0, paddingBottom: 0,
                                      paddingLeading: 0, paddingTrailing: 8,
                                      width: 40, height: 40)
            followButton.isHidden = true
            postImageView.isHidden = false


        } else {
            // notification is follow
            self.contentView.addSubview(self.followButton)
            self.followButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            self.followButton.layer.cornerRadius = 3
            self.followButton.anchor(top: nil, bottom: nil,
                                     leading: nil, trailing: self.trailingAnchor,
                                     paddingTop: 0, paddingBottom: 0,
                                     paddingLeading: 0, paddingTrailing: 8,
                                     width: 90, height: 30)
            
            
            followButton.isHidden = false
            postImageView.isHidden = true
            
            user.checkIfUserIsFollowed(completion: { (followed) in
                
                if followed {
                    self.followButton.setTitle("Following", for: .normal)
                    self.followButton.setTitleColor(.black, for: .normal)
                    self.followButton.layer.borderWidth = 0.5
                    self.followButton.layer.borderColor = UIColor.lightGray.cgColor
                    self.followButton.backgroundColor = .white
                } else {
                    self.followButton.setTitle("Follow", for: .normal)
                    self.followButton.setTitleColor(.white, for: .normal)
                    self.followButton.layer.borderWidth = 0
                    self.followButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
                }
            })
        }
        self.addSubview(self.notificationLabel)
        self.notificationLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.notificationLabel.anchor(top: nil, bottom: nil,
                                      leading: self.profileImageView.trailingAnchor, trailing: self.trailingAnchor,
                                      paddingTop: 0, paddingBottom: 0,
                                      paddingLeading: 8, paddingTrailing: 108,
                                      width: 0, height: 0)
    }
    
    private func getNotificationTimeStamp() -> String? {
        
        guard let notification = self.notification else { return nil }
        
        let dateFormatter = DateComponentsFormatter()
        dateFormatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        dateFormatter.maximumUnitCount = 1
        dateFormatter.unitsStyle = .abbreviated
        let now = Date()
        
        return dateFormatter.string(from: notification.creationDate, to: now)
    }
    
    
    
    
    
    
    
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
//        self.selectionStyle = .none
        
        self.addSubview(self.profileImageView)
        self.profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.profileImageView.layer.cornerRadius = 40 / 2
        self.profileImageView.anchor(top: nil, bottom: nil,
                                     leading: self.leadingAnchor, trailing: nil,
                                     paddingTop: 0, paddingBottom: 0,
                                     paddingLeading: 8, paddingTrailing: 0,
                                     width: 40, height: 40)

        
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//extension UITableViewCell {
//    open override func addSubview(_ view: UIView) {
//        super.addSubview(view)
//        sendSubviewToBack(contentView)
//    }
//}
