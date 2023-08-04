//
//  UserProfileHeader.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/05.
//

import UIKit
import FirebaseAuth

final class UserProfileHeader: UICollectionViewCell {
    
    
    // MARK: - Properties
    // UserProfileVC
    var delegate: UserProfileHeaderDelegate?
    
    var user: User? {
        didSet {
            // configure edit profile button
            self.configureEditProfileFollowButton()
            
            // set user Stats
            self.setUserStats(for: user)
            
            let fullName = user?.name
            self.fullNameLabel.text = fullName
            
            guard let profileImageUrl = user?.profileImageUrl else { return }
            
            self.profileImageView.loadImageView(with: profileImageUrl)
        }
    }
    
    
    
    // MARK: - ImageView
    private let profileImageView: CustomImageView = {
        let img = CustomImageView().configureCustomImageView()
            // 기본 이미지
            img.image = UIImage(named: "profile_unselected")
        return img
    }()
    
    
    
    // MARK: - Label
    private let fullNameLabel: UILabel = {
        return UILabel().label(fontName: .bold, fontSize: 12)
    }()
    
    // 나중에 기능 추가해야 함
    private let postLabel: UILabel = {
        return UILabel().labelMutableAttributedString(
            type1TextString: "5\n",
            type1FontName: .bold,
            type1FontSize: 14,
            type1Foreground: UIColor.black,
            
            type2TextString: "posts",
            type2FontName: .bold,
            type2FontSize: 14,
            type2Foreground: UIColor.lightGray,
            
            numberOfLines: 0,
            textAlignment: .center)
    }()
    
    lazy var followersLabel: UILabel = {
        let lbl = UILabel().labelMutableAttributedString(
            type1TextString: "0\n",
            type1FontName: .bold,
            type1FontSize: 14,
            type1Foreground: UIColor.black,
            
            type2TextString: "followers",
            type2FontName: .bold,
            type2FontSize: 14,
            type2Foreground: UIColor.lightGray,
            
            numberOfLines: 0,
            textAlignment: .center)
        
        // add gesture recognizer
        let followTap = UITapGestureRecognizer(target: self,
                                               action: #selector(self.handleFollowersTapped))
            followTap.numberOfTapsRequired = 1
        
            lbl.isUserInteractionEnabled = true
            lbl.addGestureRecognizer(followTap)
        
        return lbl
    }()
    
    lazy var followingLabel: UILabel = {
        let lbl = UILabel().labelMutableAttributedString(
            type1TextString: "0\n",
            type1FontName: .bold,
            type1FontSize: 14,
            type1Foreground: UIColor.black,
            
            type2TextString: "following",
            type2FontName: .bold,
            type2FontSize: 14,
            type2Foreground: UIColor.lightGray,
            
            numberOfLines: 0,
            textAlignment: .center)
        
        // add gesture recognizer
        let followTap = UITapGestureRecognizer(target: self,
                                               action: #selector(self.handleFollowingTapped))
            followTap.numberOfTapsRequired = 1
        
            lbl.isUserInteractionEnabled = true
            lbl.addGestureRecognizer(followTap)
        
        return lbl
    }()
    
    
    
    // MARK: - Button
    lazy var editProfileFollowButton: UIButton = {
        let btn = UIButton().button(title: "Loading",
                                    titleColor: UIColor.black,
                                    fontName: .bold,
                                    fontSize: 14,
                                    cornerRadius: 3)
            btn.layer.borderColor = UIColor.lightGray.cgColor
            btn.layer.borderWidth = 0.5
        
            btn.addTarget(self, action: #selector(self.handleEditProfileFollow), for: .touchUpInside)
        return btn
    }()
    
    private let gridButton: UIButton = {
        return UIButton().button(tintColor: UIColor(white: 0, alpha: 0.2),
                                 image: "grid")
    }()
    
    private let listButton: UIButton = {
        return UIButton().button(tintColor: UIColor(white: 0, alpha: 0.2),
                                 image: "list")
    }()
    
    private let bookmarkButton: UIButton = {
        return UIButton().button(tintColor: UIColor(white: 0, alpha: 0.2),
                                 image: "ribbon")
    }()
    
    
    
    // MARK: - View
    private let topDividerView: UIView = {
        return UIView().backgrouncColorView(backgroundColor: UIColor.lightGray)
    }()
    
    private let bottomDividerView: UIView = {
        return UIView().backgrouncColorView(backgroundColor: UIColor.lightGray)
    }()
    
    
    
    // MARK: - StackView
    private lazy var stackView: UIStackView = {
        return UIStackView().stackView(arrangedSubviews:
                                            [self.postLabel,
                                             self.followersLabel,
                                             self.followingLabel],
                                          axis: .horizontal,
                                          distribution: .fillEqually)
    }()
    
    private lazy var dividerStackView: UIStackView = {
        return UIStackView().stackView(arrangedSubviews:
                                            [self.gridButton,
                                             self.listButton,
                                             self.bookmarkButton],
                                          axis: .horizontal,
                                          distribution: .fillEqually)
    }()
    

    
    // MARK: - Helper Functions
    // posts  / followers / following 밑에 버튼의 색상 및 텍스트 변경
    private func configureEditProfileFollowButton() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let user = self.user else { return }
        
        // 사용자의 userProfile일 경우
        if currentUid == user.uid {
            // configure button as eidt profile
            self.editProfileFollowButton.setTitle("Edit Profile", for: .normal)
            
            
            // 다른 사용자의 userProfile일 경우
        } else {
            // configure button as follow button
            self.editProfileFollowButton.setTitleColor(.white, for: .normal)
            self.editProfileFollowButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
            
            // 버튼을 누르면 버튼의 텍스트가 바뀜
            user.checkIfUserIsFollowed { followed in
                followed == true
                    ? self.editProfileFollowButton.setTitle("Following", for: .normal)
                    : self.editProfileFollowButton.setTitle("Follow", for: .normal)
            }
        }
    }
    
    
    
    // MARK: - Selector - Delegate
        // UserProfileVC
    @objc func handleFollowersTapped() {
        self.delegate?.handleFollowersTapped(for: self)
    }

    @objc func handleFollowingTapped() {
        self.delegate?.handleFollowingTapped(for: self)
    }

    @objc func handleEditProfileFollow() {
        self.delegate?.handleEditFollowTapped(for: self)
    }
    
    func setUserStats(for user: User?) {
        self.delegate?.setUserStats(for: self)
    }
    
    
    
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
        // background Color
        self.backgroundColor = .white
        
        // profileImageView
        self.addSubview(self.profileImageView)
        self.profileImageView.anchor(top: self.topAnchor, paddingTop: 16,
                                     leading: self.leadingAnchor, paddingLeading: 12,
                                     width: 80, height: 80,
                                     cornerRadius: 80 / 2)
        
        // fullNameLabel
        self.addSubview(self.fullNameLabel)
        self.fullNameLabel.anchor(top: profileImageView.bottomAnchor, paddingTop: 12,
                                  leading: self.leadingAnchor, paddingLeading: 12)
        // stackView
        self.addSubview(self.stackView)
        self.stackView.anchor(top: self.topAnchor, paddingTop: 12,
                              leading: self.profileImageView.trailingAnchor, paddingLeading: 12,
                              trailing: self.trailingAnchor, paddingTrailing: 12,
                              height: 50)
        // editProfileFollowButton
        self.addSubview(self.editProfileFollowButton)
        self.editProfileFollowButton.anchor(top: self.postLabel.bottomAnchor, paddingTop: 3,
                                            leading: self.postLabel.leadingAnchor, paddingLeading: 8,
                                            trailing: self.trailingAnchor, paddingTrailing: 12,
                                            height: 30)
        // dividerStackView
        self.addSubview(self.dividerStackView)
        self.dividerStackView.anchor(bottom: self.bottomAnchor,
                                     leading: self.leadingAnchor,
                                     trailing: self.trailingAnchor,
                                     height: 50)
        // topDividerView
        self.addSubview(self.topDividerView)
        self.topDividerView.anchor(top: self.dividerStackView.topAnchor,
                                   leading: self.leadingAnchor,
                                   trailing: self.trailingAnchor,
                                   height: 0.5)
        // bottomDividerView
        self.addSubview(self.bottomDividerView)
        self.bottomDividerView.anchor(top: self.dividerStackView.bottomAnchor,
                                      leading: self.leadingAnchor,
                                      trailing: self.trailingAnchor,
                                      height: 0.5)
    }
}
