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
            // 이미지 불러오기
            self.profileImageView.loadImageView(with: profileImgeUrl)
            // textLabel / detailTextLabel 텍스트 설정
            self.textLabel?.text = userName
            self.detailTextLabel?.text = fullName
        }
    }
    
    
    
    // MARK: - ImageView
    private let profileImageView: CustomImageView = {
        let img = CustomImageView().configureCustomImageView()
            // 기본 이미지
            img.image = UIImage(named: "profile_unselected")
        return img
    }()
    
    
    
    // MARK: - LifeCycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.configureUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // textLabel
        self.textLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        self.textLabel?.frame = CGRect(x: 68,
                                       y: (textLabel?.frame.origin.y)! - 2,
                                       width: (self.textLabel?.frame.width)!,
                                       height: (self.textLabel?.frame.height)!)
        // detailTextLabel
        self.detailTextLabel?.textColor = .lightGray
        self.detailTextLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        self.detailTextLabel?.frame = CGRect(x: 68,
                                             y: (detailTextLabel?.frame.origin.y)!,
                                             width: self.frame.width - 108,
                                             height: (self.detailTextLabel?.frame.height)!)
    }
    
    
    
    // MARK: - Configure UI
    private func configureUI() {
        self.selectionStyle = .none
        
        // add profile image view
        self.addSubview(self.profileImageView)
        self.profileImageView.anchor(leading: leadingAnchor, paddingLeading: 8,
                                     width: 48, height: 48,
                                     centerY: self,
                                     cornerRadius: 48 / 2)
    }
}
