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
            
            // 이미지 불러오기
            self.profileImageView.loadImageView(with: profileImgeUrl)
            
            // textLabel 및 detailTextLabel을 설정
            self.textLabel?.text = userName
            self.detailTextLabel?.text = fullName
            
            // hide follow button for current user
                // 자기 자신은 followButton을 숨김
            if user.uid == Auth.auth().currentUser?.uid {
                self.followButton.isHidden = true
            }
            
            // 셀에 들어오면 상태에 맞게 버튼의 설정 ( 텍스트, 컬러 등 )
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
        return CustomImageView().configureCustomImageView()
    }()
    
    lazy var followButton: UIButton = {
        let btn = UIButton().button(title: "Loading",
                                    titleColor: UIColor.white,
                                    fontName: .bold,
                                    fontSize: 14,
                                    backgroundColor: UIColor.buttonBlue)
        btn.layer.borderColor = UIColor.lightGray.cgColor
        
        btn.addTarget(self, action: #selector(self.handleFollowTapped), for: .touchUpInside)

        return btn
    }()
    
    
    
    // MARK: - Selectors
    @objc func handleFollowTapped() {
        // FollowLikeVC
        self.delegate?.handleFollowTapped(for: self)
    }
    
    
    
    // MARK: - LifeCycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        self.configureUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

    
    
    // MARK: - Configure UI
    private func configureUI() {
        // selectionStyle
        self.selectionStyle = .none
        
        // profileImageView
        self.addSubview(self.profileImageView)
        self.profileImageView.anchor(leading: self.leadingAnchor, paddingLeading: 8,
                                     width: 48, height: 48,
                                     centerY: self,
                                     cornerRadius: 48 / 2)
        
        // followButton
        self.addSubview(self.followButton)
        self.followButton.anchor(trailing: self.trailingAnchor, paddingTrailing: 12,
                                 width: 90, height: 30,
                                 centerY: self,
                                 cornerRadius: 3)
    }
}



