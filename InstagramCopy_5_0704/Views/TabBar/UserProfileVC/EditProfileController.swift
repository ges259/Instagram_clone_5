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
        
        view.addSubview(self.profileImageView)
        view.addSubview(self.changePhotoButton)
        
        // profileImageView autoLayout
        self.profileImageView.anchor(top: view.topAnchor, bottom: nil, leading: nil, trailing: nil, paddingTop: 16, paddingBottom: 0, paddingLeading: 0, paddingTrailing: 0, width: 80, height: 80)
        self.profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.profileImageView.clipsToBounds = true
        self.profileImageView.layer.cornerRadius = 80 / 2
        
        // changePhotoButton autoLayout
        self.changePhotoButton.anchor(top: self.profileImageView.bottomAnchor, bottom: nil, leading: nil, trailing: nil, paddingTop: 8, paddingBottom: 0, paddingLeading: 0, paddingTrailing: 0, width: 0, height: 0)
        self.changePhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.backgroundColor = .systemGray4
        
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
    private let profileImageView: CustomImageView = {
        let img = CustomImageView()
        
        img.clipsToBounds = true
        img.contentMode = .scaleAspectFill
        img.backgroundColor = .lightGray
        
        
        return img
    }()
    
    
    // MARK: - Button
    private let changePhotoButton: UIButton = {
        let btn = UIButton()
        
        btn.setTitle("Change Profile Photo", for: .normal)
        btn.titleLabel?.textColor = .blue
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
        txt.isUserInteractionEnabled = false
        
        return txt
    }()
    
    private let userNameTextField: UITextField = {
        let txt = UITextField()
        
        txt.textAlignment = .left
        txt.borderStyle = .none
        
        return txt
    }()
    

    
    // MARK: - Handlers
    private func configureNavigationBar() {
        self.navigationItem.title = "Edit Profile"
        self.navigationController?.navigationBar.tintColor = .black
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "done", style: .done, target: self, action: #selector(handleDone))
        
    }
    @objc func handleCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    @objc func handleDone() {
        self.view.endEditing(true)
        
        if userNameChanged {
            self.updateUserName()
        }
        
        if imageChanged {
            self.updateProfileImage()
        }
    }
    private func loadUserData() {
        guard let user = self.user else  { return }
        
        self.profileImageView.loadImageView(with: user.profileImageUrl)
        self.fullNameTextField.text = user.name
        self.userNameTextField.text = user.userName
        
    }
    
    
    // MARK: - API
    
    
    
    private func updateProfileImage() {
        guard imageChanged == true else { return }
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let user = self.user else { return }
        
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
//    private func updateProfileImage() {
//        guard imageChanged == true else { return }
//        guard let currentUid = Auth.auth().currentUser?.uid else { return }
//        guard let user = self.user else { return }
//
//        Storage.storage().reference(forURL: user.profileImageUrl).delete(completion: nil)
//
//        let filename = NSUUID().uuidString
//
//        guard let updatedProfileImage = profileImageView.image else { return }
//
//        guard let imageData = updatedProfileImage.jpegData(compressionQuality: 0.3) else { return }
//
//        STORAGE_PROFILE_IMAGES_REF.child(filename).putData(imageData, metadata: nil) { (metadata, error) in
//
//            if let error = error {
//                print("Failed to upload image to storage with error: ", error.localizedDescription)
//            }
//
//            STORAGE_PROFILE_IMAGES_REF.downloadURL(completion: { (url, error) in
//                USER_REF.child(currentUid).child("profileImageUrl").setValue(url?.absoluteString, withCompletionBlock: { (err, ref) in
//
//                    guard let userProfileController = self.userProfileController else { return }
//                    userProfileController.fetchCurrentUserData()
//
//                    self.dismiss(animated: true, completion: nil)
//                })
//            })
//        }
//    }
//
    private func updateUserName() {
        guard let updatedUsername = self.updatedUserName else { return }
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard userNameChanged == true else { return }
        
        USER_REF.child(currentUid).child("userName").setValue(updatedUsername) { (err, ref) in
            
            guard let userProfileController = self.userProfileController else { return }
            userProfileController.fetchCurrentUserData()
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    
    
    
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white

        self.configureNavigationBar()
        self.configureViewComponents()
        
        self.userNameTextField.delegate = self
        
        self.loadUserData()
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
        
        self.fullNameSeparatorView.anchor(top: nil, bottom: self.fullNameTextField.bottomAnchor,
                                          leading: self.fullNameTextField.leadingAnchor, trailing: self.view.trailingAnchor,
                                          paddingTop: 0, paddingBottom: -8,
                                          paddingLeading: 0, paddingTrailing: 12,
                                          width: 0, height: 0.5)
        
        self.userNameSeparatorView.anchor(top: nil, bottom: self.userNameTextField.bottomAnchor,
                                          leading: self.userNameTextField.leadingAnchor, trailing: self.view.trailingAnchor,
                                          paddingTop: 0, paddingBottom: -8,
                                          paddingLeading: 0, paddingTrailing: 12,
                                          width: 0, height: 0.5)
    }
}




// MARK: - PickerView
extension EditProfileController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @objc func handleChangeProfilePhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        
        if let selectedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage {
            profileImageView.image = selectedImage
            self.imageChanged = true
        }
        
        dismiss(animated: true, completion: nil)
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






extension EditProfileController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let user = self.user else { return }
        
        let trimmedString = userNameTextField.text?.replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression)
        
        guard user.userName != trimmedString else {
            print("You did not change you userName")
            userNameChanged = false
            return
        }
        
        guard trimmedString != "" else {
            print("ERROR: Please enter a valid userName")
            userNameChanged = false
            return
        }
        
        self.updatedUserName = trimmedString?.lowercased()
        self.userNameChanged = true
    }
}
