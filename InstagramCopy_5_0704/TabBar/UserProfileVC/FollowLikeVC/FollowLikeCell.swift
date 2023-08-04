//
//  FollowLikeCell.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/06.
//

import UIKit
import Firebase

final class FollowLikeCell: UITableViewCell {
    
    
    
    // MARK: - Properties
    

    
    
    
    
    
    
    // FollowLikeVC
    var delegate: FollowCellDelegate?
    
    var user: User? {
        didSet {
            guard let user = user else { return }
            guard let profileImgeUrl = user.profileImageUrl else { return }
            guard let userName = user.userName else { return }
            guard let fullName = user.name else { return }
            
            
            self.profileImageView.loadImageView(with: profileImgeUrl)
            
            self.textLabel?.text = userName
            self.detailTextLabel?.text = fullName
            
            // hide follow button for current user
                // 자기 자신은 숨김
//            guard let currentUid = Auth.auth().currentUser?.uid else { return }
//            guard let userUid = user.uid else { return }
            if user.uid == Auth.auth().currentUser?.uid {
                print(user.uid)
                self.followButton.isHidden = true
            }
            
            
            // 셀에 들어오면 버튼의 텍스트를 설정
            user.checkIfUserIsFollowed(completion: { (followed) in
                
                if followed {
                    
                    // configure follow button for followed user
                    self.followButton.configure(didFollow: true)
                    
                } else {
                    
                    // configure follow button for non followed user
                    self.followButton.configure(didFollow: false)
                }
                
            })
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
    
    lazy var followButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Loading", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.titleLabel?.font = .boldSystemFont(ofSize: 14)
        
        btn.addTarget(self, action: #selector(handleFollowTapped), for: .touchUpInside)

        return btn
    }()
    
    
    
    
    
    
    // MARK: - init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
//        print("FollowLikeCell")
        
        self.selectionStyle = .none
        
        self.textLabel?.text = "UserName"
        self.detailTextLabel?.text = "FullName"
        
        self.addSubview(self.profileImageView)
        self.profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.profileImageView.layer.cornerRadius = 48 / 2
        self.profileImageView.anchor(leading: self.leadingAnchor, paddingLeading: 8,
                                     width: 48, height: 48)
        
        
        self.addSubview(self.followButton)
        self.followButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.followButton.layer.cornerRadius = 3
        self.followButton.anchor(trailing: self.trailingAnchor, paddingTrailing: 12,
                                 width: 90, height: 30)
        


        self.selectionStyle = .none
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
    
    
    
    
    
    
    
    // MARK: - Handler
    @objc func handleFollowTapped() {
        delegate?.handleFollowTapped(for: self)
    }
    
    
}



