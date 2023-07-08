//
//  EditProfileController.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/06.
//

import UIKit


final class EditProfileController: UIViewController {
    
    var user: User?
    var userProfileController: UserProfileVC?

    
    
    
    // MARK: - View
    private lazy var backgroundView: UIView = {
        
        let frame = CGRect(x: 0, y: 88, width: view.frame.width, height: 150)
        
        let view = UIView(frame: frame)
        
        view.addSubview(self.profileIamgeView)
        view.addSubview(self.changePhotoButton)
        
        // profileImageView autoLayout
        self.profileIamgeView.anchor(top: view.topAnchor, bottom: nil, leading: nil, trailing: nil, paddingTop: 16, paddingBottom: 0, paddingLeading: 0, paddingTrailing: 0, width: 80, height: 80)
        self.profileIamgeView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.profileIamgeView.clipsToBounds = true
        self.profileIamgeView.layer.cornerRadius = 80 / 2
        
        // changePhotoButton autoLayout
        self.changePhotoButton.anchor(top: self.profileIamgeView.bottomAnchor, bottom: nil, leading: nil, trailing: nil, paddingTop: 8, paddingBottom: 0, paddingLeading: 0, paddingTrailing: 0, width: 0, height: 0)
        self.changePhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.backgroundColor = .lightGray
        
        return view
    }()
    private let fullNameSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    private let userNameSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    
    // MARK: - ImageView
    private let profileIamgeView: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(systemName: "person")
        
        img.clipsToBounds = true
        img.contentMode = .scaleAspectFill
        img.backgroundColor = .red
        
        
        return img
    }()
    
    
    // MARK: - Button
    private let changePhotoButton: UIButton = {
        let btn = UIButton()
        
        btn.setTitle("Change Profile Photo", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.addTarget(self, action: #selector(handleChangeProfilePhoto), for: .touchUpInside)

        
        return btn
    }()
    
    
    
    
    // MARK: - Label
    private let fullNameLabel: UILabel = {
        let lbl = UILabel()
        
        lbl.text = "Full Name"
        lbl.font = UIFont.systemFont(ofSize: 16)
        
        return lbl
    }()
    private let userNameLabel: UILabel = {
        let lbl = UILabel()
        
        lbl.text = "User Name"
        lbl.font = UIFont.systemFont(ofSize: 16)
        
        return lbl
    }()

    
    
    // MARK: - TextField
    private let fullNameTextField: UITextField = {
        let txt = UITextField()
        
        txt.textAlignment = .left
        txt.borderStyle = .none
        
        return txt
    }()
    
    private let userNameTextField: UITextField = {
        let txt = UITextField()
        
        txt.textAlignment = .left
        txt.borderStyle = .none
        
        return txt
    }()
    

    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.view.backgroundColor = .white

        
        configureNavigationBar()
        configureViewComponents()
    }
    private func configureViewComponents() {
        self.view.addSubview(self.backgroundView)
        self.view.addSubview(self.fullNameLabel)
        self.view.addSubview(self.userNameLabel)
        self.view.addSubview(self.fullNameTextField)
        self.view.addSubview(self.userNameTextField)
        self.view.addSubview(self.fullNameSeparatorView)
        self.view.addSubview(self.userNameSeparatorView)
        
        self.fullNameLabel.anchor(top: self.backgroundView.bottomAnchor, bottom: nil,
                                  leading: self.view.leadingAnchor,     trailing: nil,
                                  paddingTop: 20,                       paddingBottom: 0,
                                  paddingLeading: 12,                    paddingTrailing: 0,
                                  width: 0,                             height: 0)
        
        self.userNameLabel.anchor(top: self.fullNameLabel.bottomAnchor, bottom: nil,
                                  leading: self.view.leadingAnchor,     trailing: nil,
                                  paddingTop: 20,                       paddingBottom: 0,
                                  paddingLeading: 12,                    paddingTrailing: 0,
                                  width: 0,                             height: 0)
        
        self.fullNameTextField.anchor(top: self.backgroundView.bottomAnchor,        bottom: nil,
                                      leading: self.fullNameLabel.trailingAnchor,   trailing: self.view.trailingAnchor,
                                      paddingTop: 16,                               paddingBottom: 0,
                                      paddingLeading: 12,                           paddingTrailing: 12,
                                      width: self.view.frame.width / 1.6,             height: 0)
        
        self.userNameTextField.anchor(top: self.fullNameTextField.bottomAnchor,     bottom: nil,
                                      leading: self.userNameLabel.trailingAnchor,   trailing: self.view.trailingAnchor,
                                      paddingTop: 16,                               paddingBottom: 0,
                                      paddingLeading: 12,                           paddingTrailing: 12,
                                      width: self.view.frame.width / 1.6,           height: 0)
        
        self.fullNameSeparatorView.anchor(top: nil,                                 bottom: self.fullNameTextField.bottomAnchor,
                                          leading: self.fullNameTextField.leadingAnchor, trailing: self.view.trailingAnchor,
                                          paddingTop: 0,                            paddingBottom: -8,
                                          paddingLeading: 0,                        paddingTrailing: 12,
                                          width: 0,                                 height: 0.5)
        
        self.userNameSeparatorView.anchor(top: nil, bottom: self.userNameTextField.bottomAnchor,
                                          leading: self.userNameTextField.leadingAnchor, trailing: self.view.trailingAnchor,
                                          paddingTop: 0, paddingBottom: -8,
                                          paddingLeading: 0, paddingTrailing: 12,
                                          width: 0, height: 0.5)
    }
    
    
    
    private func configureNavigationBar() {
        self.navigationItem.title = "Edit Profile"
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "done", style: .done, target: self, action: #selector(handleDone))
        
    }
    @objc func handleCancel() {
        
    }
    @objc func handleDone() {
        
    }

    
    
    
    
    
    
}


extension EditProfileController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @objc func handleChangeProfilePhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
////        let info = convertFromUIImage
//
//    }
    
    
    
}
