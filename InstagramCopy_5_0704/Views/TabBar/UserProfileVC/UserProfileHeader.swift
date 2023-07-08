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
            
            
            profileImageView.loadImageView(with: profileImageUrl)
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
    
    
    
    
    
    // MARK: - Label
    private let fullNameLabel: UILabel = {
        let lbl = UILabel()
        
//        lbl.text = "Heath Ledger"
        lbl.text = "sdafsad"
        lbl.font = UIFont.boldSystemFont(ofSize: 12)
        
        return lbl
    }()
    
    private let postLabel: UILabel = {
        let lbl = UILabel()
        
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        
        let attributedText = NSMutableAttributedString(string: "5\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "posts", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        lbl.attributedText = attributedText
        
        
        return lbl
    }()
    lazy var followersLabel: UILabel = {
        let lbl = UILabel()
        
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        
        let attributedText = NSMutableAttributedString(string: "\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "follower", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        lbl.attributedText = attributedText

        // add gesture recognizer
        let followTap = UITapGestureRecognizer(target: self, action: #selector(handleFollowersTapped))
        followTap.numberOfTapsRequired = 1
        lbl.isUserInteractionEnabled = true
        lbl.addGestureRecognizer(followTap)
        
        return lbl
    }()
    
    lazy var followingLabel: UILabel = {
        let lbl = UILabel()
        
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        
        let attributedText = NSMutableAttributedString(string: "\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "following", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        lbl.attributedText = attributedText
        
        // add gesture recognizer
        let followTap = UITapGestureRecognizer(target: self, action: #selector(handleFollowingTapped))
        followTap.numberOfTapsRequired = 1
        lbl.isUserInteractionEnabled = true
        lbl.addGestureRecognizer(followTap)
        
        return lbl
    }()
    
    

    
    
    
    // MARK: - Button
    lazy var editProfileFollowButton: UIButton = {
        let btn = UIButton(type: .system)
        
        btn.setTitle("Loading", for: .normal)
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 3
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.layer.borderWidth = 0.5
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        btn.setTitleColor(.black, for: .normal)
        
        btn.addTarget(self, action: #selector(handleEditProfileFollow), for: .touchUpInside)
        
        
        return btn
    }()
    
    private let gridButton: UIButton = {
        let btn = UIButton(type: .system)
        
        btn.setImage(UIImage(named: "grid"), for: .normal)
        btn.tintColor = UIColor(white: 0, alpha: 0.2)
        
        return btn
    }()
    private let listButton: UIButton = {
        let btn = UIButton(type: .system)
        
        btn.setImage(UIImage(named: "list"), for: .normal)
        btn.tintColor = UIColor(white: 0, alpha: 0.2)
        
        return btn
    }()
    private let bookmarkButton: UIButton = {
        let btn = UIButton(type: .system)
        
        btn.setImage(UIImage(named: "ribbon"), for: .normal)
        btn.tintColor = UIColor(white: 0, alpha: 0.2)
        
        return btn
    }()
    
    
    
    
    // MARK: - View
    private let topDividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    private let bottomDividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    
    
    
    
    // MARK: - StackView
    private lazy var stackView: UIStackView = {
        let stv = UIStackView(arrangedSubviews: [self.postLabel,
                                                 self.followersLabel,
                                                 self.followingLabel])
        stv.axis = .horizontal
        stv.distribution = .fillEqually

        
        return stv
    }()

    
    private lazy var dividerStackView: UIStackView = {
        let stv = UIStackView(arrangedSubviews: [self.gridButton,
                                                 self.listButton,
                                                 self.bookmarkButton])
        stv.axis = .horizontal
        stv.distribution = .fillEqually
        
        
        return stv
    }()
    

    
    
    // MARK: - Handler
    private func configureEditProfileFollowButton() {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let user = self.user else { return }
        
        if currentUid == user.uid {
            // configure button as eidt profile
            editProfileFollowButton.setTitle("Edit Profile", for: .normal)
            
        } else {
            // configure button as follow button
            self.editProfileFollowButton.setTitleColor(.white, for: .normal)
            self.editProfileFollowButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
            
            
            // 버튼을 누르면 버튼의 텍스트가 바뀜
            user.checkIfUserIsFollowed { followed in
                if followed {
                    self.editProfileFollowButton.setTitle("Following", for: .normal)
                } else {
                    self.editProfileFollowButton.setTitle("Follow", for: .normal)
                }
            }
        }
    }
    
    
    
    
    
    // MARK: - delegate - UserProfileVC
    @objc func handleFollowersTapped() {
        delegate?.handleFollowersTapped(for: self)
    }

    @objc func handleFollowingTapped() {
        delegate?.handleFollowingTapped(for: self)
    }

    @objc func handleEditProfileFollow() {
        delegate?.handleEditFollowTapped(for: self)

    }
    func setUserStats(for user: User?) {
        delegate?.setUserStats(for: self)
    }
    
    
    
    
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.profileImageView)
        self.addSubview(self.fullNameLabel)
        self.addSubview(self.stackView)
        self.addSubview(self.editProfileFollowButton)
        self.addSubview(self.dividerStackView)
        self.addSubview(self.topDividerView)
        self.addSubview(self.bottomDividerView)
        
        
        self.profileImageView.anchor(top: self.topAnchor, bottom: nil,
                                     leading: self.leadingAnchor, trailing: nil,
                                     paddingTop: 16, paddingBottom: 0,
                                     paddingLeading: 12, paddingTrailing: 0,
                                     width: 80, height: 80)
        self.profileImageView.layer.cornerRadius = 80 / 2
        
        self.fullNameLabel.anchor(top: profileImageView.bottomAnchor, bottom: nil,
                                  leading: self.leadingAnchor, trailing: nil,
                                  paddingTop: 12, paddingBottom: 0,
                                  paddingLeading: 12, paddingTrailing: 0,
                                  width: 0, height: 0)
        
        self.stackView.anchor(top: self.topAnchor, bottom: nil,
                              leading: self.profileImageView.trailingAnchor, trailing: self.trailingAnchor,
                              paddingTop: 12, paddingBottom: 0,
                              paddingLeading: 12, paddingTrailing: 12,
                              width: 0, height: 50)
        
        self.editProfileFollowButton.anchor(top: self.postLabel.bottomAnchor, bottom: nil,
                                      leading: self.postLabel.leadingAnchor, trailing: self.trailingAnchor,
                                      paddingTop: 3, paddingBottom: 0,
                                      paddingLeading: 8, paddingTrailing: 12,
                                      width: 0, height: 30)
        
        self.dividerStackView.anchor(top: nil, bottom: self.bottomAnchor,
                                     leading: self.leadingAnchor, trailing: self.trailingAnchor,
                                     paddingTop: 0, paddingBottom: 0,
                                     paddingLeading: 0, paddingTrailing: 0,
                                     width: 0, height: 50)
        
        self.topDividerView.anchor(top: self.dividerStackView.topAnchor, bottom: nil,
                                   leading: self.leadingAnchor, trailing: self.trailingAnchor,
                                   paddingTop: 0, paddingBottom: 0,
                                   paddingLeading: 0, paddingTrailing: 0,
                                   width: 0, height: 0.5)
        
        self.bottomDividerView.anchor(top: self.dividerStackView.bottomAnchor, bottom: nil,
                                      leading: self.leadingAnchor, trailing: self.trailingAnchor,
                                      paddingTop: 0, paddingBottom: 0,
                                      paddingLeading: 0, paddingTrailing: 0,
                                      width: 0, height: 0.5)
        
        
        self.backgroundColor = .white
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
