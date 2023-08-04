//
//  EditProfileController.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/06.
//

import UIKit
import Firebase
import FirebaseStorage

final class EditProfileController: UIViewController {
    
    
    // MARK: - Properties
    var user: User?
    var userProfileController: UserProfileVC?
    var imageChanged: Bool = false
    var userNameChanged: Bool = false
    var updatedUserName: String?
    
    
    
    // MARK: - View
    private lazy var backgroundView: UIView = {
        let frame = CGRect(x: 0, y: 88, width: view.frame.width, height: 150)
        
        let view = UIView(frame: frame)
            view.backgroundColor = .systemGray4
        
        // profileImageView autoLayout
            view.addSubview(self.profileImageView)
            self.profileImageView.anchor(top: view.topAnchor, paddingTop: 16,
                                     width: 80, height: 80, centerX: view,
                                         cornerRadius: 80 / 2)
        // changePhotoButton autoLayout
            view.addSubview(self.changePhotoButton)
            self.changePhotoButton.anchor(top: self.profileImageView.bottomAnchor, paddingTop: 8,
                                          centerX: view)
        return view
    }()
    private lazy var fullNameSeparatorView: UIView = {
        return UIView().backgrouncColorView(backgroundColor: UIColor.lightGray)
    }()
    private lazy var userNameSeparatorView: UIView = {
        return UIView().backgrouncColorView(backgroundColor: UIColor.lightGray)
    }()
    
    
    
    // MARK: - ImageView
    private lazy var profileImageView: CustomImageView = {
        return CustomImageView().configureCustomImageView()
    }()
    
    
    
    // MARK: - Button
    private lazy var changePhotoButton: UIButton = {
        let btn = UIButton().button(title: "Change Profile Photo",
                                    titleColor: UIColor.blue,
                                    fontName: .system,
                                    fontSize: 14)
        btn.addTarget(self, action: #selector(self.handleChangeProfilePhoto),
                      for: .touchUpInside)
        return btn
    }()
    
    
    
    // MARK: - Label
    private lazy var fullNameLabel: UILabel = {
        return UILabel().label(labelText: "Full Name",
                                  fontName: .system,
                                  fontSize: 16)
    }()
    private lazy var userNameLabel: UILabel = {
        return UILabel().label(labelText: "User Name",
                                  fontName: .system,
                                  fontSize: 16)
    }()

    
    
    // MARK: - TextField
    private lazy var fullNameTextField: UITextField = {
        let txt = UITextField()
            txt.textAlignment = .left
            txt.borderStyle = .none
            txt.isUserInteractionEnabled = false
        return txt
    }()
    
    private lazy var userNameTextField: UITextField = {
        let txt = UITextField()
            txt.textAlignment = .left
            txt.borderStyle = .none
        return txt
    }()
    

    
    // MARK: - Helper Funcions
    private func configureNavigationBar() {
        self.navigationItem.title = "Edit Profile"
        self.navigationController?.navigationBar.tintColor = .black
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                                style: .plain,
                                                                target: self,
                                                                action: #selector(self.handleCancel))
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "done",
                                                                 style: .done,
                                                                 target: self,
                                                                 action: #selector(self.handleDone))
    }
    
    private func loadUserData() {
        guard let user = self.user else  { return }
        
        self.profileImageView.loadImageView(with: user.profileImageUrl)
        self.fullNameTextField.text = user.name
        self.userNameTextField.text = user.userName
    }
    
    
    
    // MARK: - Selectors
    @objc func handleCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    @objc func handleDone() {
        self.view.endEditing(true)
        
        if self.userNameChanged {
            self.updateUserName()
        }
        
        if self.imageChanged {
            self.updateProfileImage()
        }
    }

    
    
    // MARK: - API
    private func updateProfileImage() {
        guard self.imageChanged == true else { return }
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let user = self.user else { return }
        
        // 이전에 있던 이미지 지우기
        Storage.storage().reference(forURL: user.profileImageUrl).delete(completion: nil)
        
        let filename = NSUUID().uuidString
        guard let updatedProfileImage = profileImageView.image else { return    }
        
        let storageRef = Storage.storage().reference().child("profile_images").child(filename)
        
        guard let imageData = updatedProfileImage.jpegData(compressionQuality: 0.3) else { return }
        
        storageRef.putData(imageData, metadata: nil) { (metadata, err) in
            
            if let err = err {
                print("Failed to upload image to storage with error: ", err.localizedDescription)
            }
            
            storageRef.downloadURL(completion: { (downloadURL, err) in
                
                guard let updatedProfileImageUrl = downloadURL?.absoluteString else {return}
                
                
                USER_REF.child(currentUid).child("profileImageUrl").setValue(updatedProfileImageUrl, withCompletionBlock: { (err, ref) in
                    guard let userProfileController = self.userProfileController else {return}
                    
                    userProfileController.fetchCurrentUserData()
                    self.dismiss(animated: true, completion: nil)
                })
            })
        }
    }
    
    private func updateUserName() {
        guard let updatedUsername = self.updatedUserName else { return }
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        // userNameChanged가 true 일 때만 진행
        guard userNameChanged == true else { return }
        
        USER_REF.child(currentUid).child("userName").setValue(updatedUsername) { (err, ref) in
            
            guard let userProfileController = self.userProfileController else { return }
            userProfileController.fetchCurrentUserData()
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureNavigationBar()
        self.configureViewComponents()
        
        self.userNameTextField.delegate = self
        
        self.loadUserData()
    }
    
    
    
    // MARK: - Configure UI
    private func configureViewComponents() {
        // background Color
        self.view.backgroundColor = .white
        
        // backgroundView
        self.view.addSubview(self.backgroundView)
        
        // fullNameLabel
        self.view.addSubview(self.fullNameLabel)
        self.fullNameLabel.anchor(top: self.backgroundView.bottomAnchor, paddingTop: 20,
                                  leading: self.view.leadingAnchor, paddingLeading: 12)
        
        // userNameLabel
        self.view.addSubview(self.userNameLabel)
        self.userNameLabel.anchor(top: self.fullNameLabel.bottomAnchor, paddingTop: 20,
                                  leading: self.view.leadingAnchor, paddingLeading: 12)
        
        // fullNameTextField
        self.view.addSubview(self.fullNameTextField)
        self.fullNameTextField.anchor(top: self.backgroundView.bottomAnchor, paddingTop: 16,
                                      leading: self.fullNameLabel.trailingAnchor, paddingLeading: 12,
                                      trailing: self.view.trailingAnchor, paddingTrailing: 12,
                                      width: self.view.frame.width / 1.6)
        
        // userNameTextField
        self.view.addSubview(self.userNameTextField)
        self.userNameTextField.anchor(top: self.fullNameTextField.bottomAnchor, paddingTop: 16,
                                      leading: self.userNameLabel.trailingAnchor, paddingLeading: 12,
                                      trailing: self.view.trailingAnchor, paddingTrailing: 12,
                                      width: self.view.frame.width / 1.6)
        
        // fullNameSeparatorView
        self.view.addSubview(self.fullNameSeparatorView)
        self.fullNameSeparatorView.anchor(bottom: self.fullNameTextField.bottomAnchor, paddingBottom: -8,
                                          leading: self.fullNameTextField.leadingAnchor,
                                          trailing: self.view.trailingAnchor, paddingTrailing: 12,
                                          height: 0.5)
        
        // userNameSeparatorView
        self.view.addSubview(self.userNameSeparatorView)
        self.userNameSeparatorView.anchor(bottom: self.userNameTextField.bottomAnchor, paddingBottom: -8,
                                          leading: self.userNameTextField.leadingAnchor,
                                          trailing: self.view.trailingAnchor, paddingTrailing: 12,
                                          height: 0.5)
    }
}



// MARK: - PickerView
extension EditProfileController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    // changePhotoButton - Selector
    @objc func handleChangeProfilePhoto() {
        let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        if let selectedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage {
            self.profileImageView.image = selectedImage
            self.imageChanged = true
        }
        self.dismiss(animated: true, completion: nil)
    }
}



// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}



// MARK: - UITextFieldDelegate
extension EditProfileController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let user = self.user else { return }
        
        let trimmedString = userNameTextField.text?.replacingOccurrences(of: "\\s+$",
                                                                         with: "",
                                                                         options: .regularExpression)
        
        guard user.userName != trimmedString else {
            print("You did not change you userName")
            self.userNameChanged = false
            return
        }
        
        guard trimmedString != "" else {
            print("ERROR: Please enter a valid userName")
            self.userNameChanged = false
            return
        }
        
        self.updatedUserName = trimmedString?.lowercased()
        self.userNameChanged = true
    }
}
