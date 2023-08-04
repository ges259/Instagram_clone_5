//
//  SignUpVC.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/05.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage


final class SignUpVC: UIViewController, UINavigationControllerDelegate {
    
    
    // MARK: - Properties
    private var imageSelected: Bool = false
    
    // MARK: - TextView
    private lazy var emailTextField: UITextField = {
        let tf = UITextField().textField(withPlaceholder: "Email",
                                         fontSize: 14,
                                         backgroundColor: UIColor(white: 0, alpha: 0.03),
                                         paddingLeftView: true,
                                         cornerRadius: 10)
 
            tf.addTarget(self, action: #selector(self.formValidation), for: .editingChanged)

        return tf
    }()
    private lazy var passwordTextField: UITextField = {
        let tf = UITextField().textField(withPlaceholder: "Password",
                                         fontSize: 14,
                                         backgroundColor: UIColor(white: 0, alpha: 0.03),
                                         isSecureTextEntry: true,
                                         paddingLeftView: true,
                                         cornerRadius: 10)
        
            tf.addTarget(self, action: #selector(self.formValidation), for: .editingChanged)
        return tf
    }()
    private lazy var fullNameTextField: UITextField = {
        let tf = UITextField().textField(withPlaceholder: "Full Name",
                                         fontSize: 14,
                                         backgroundColor: UIColor(white: 0, alpha: 0.03),
                                         paddingLeftView: true,
                                         cornerRadius: 10)
        
            tf.addTarget(self, action: #selector(self.formValidation), for: .editingChanged)
        return tf
    }()
    private lazy var userNameTextField: UITextField = {
        let tf = UITextField().textField(withPlaceholder: "User Name",
                                         fontSize: 14,
                                         backgroundColor: UIColor(white: 0, alpha: 0.03),
                                         paddingLeftView: true,
                                         cornerRadius: 10)
        
            tf.addTarget(self, action: #selector(self.formValidation), for: .editingChanged)
        return tf
    }()
    
    
    
    // MARK: - Button
    private lazy var plusButton: UIButton = {
        let btn = UIButton().button(title: nil, fontSize: nil,
                                    image: "plus_photo")
        
            btn.addTarget(self, action: #selector(self.handleSelectProfilePhoto), for: .touchUpInside)
        return btn
    }()
    private lazy var signUpButton: UIButton = {
        let btn = UIButton().button(title: "Sign Up",
                                    titleColor: .white,
                                    
                                    fontName: .bold,
                                    fontSize: 18,
                                    backgroundColor: UIColor.rgb(red: 149, green: 204, blue: 244),
                                    
                                    cornerRadius: 10,
                                    isEnable: false)
        
            btn.addTarget(self, action: #selector(self.handleSignUp), for: .touchUpInside)
        return btn
    }()
    private lazy var alreadyHaveAccountButton: UIButton = {
        let btn = UIButton().mutableAttributedString(buttonType: .system,
                                                     
                                                     type1TextString: "Already have an account?   ",
                                                     type1FontName: .system,
                                                     type1FontSize: 14,
                                                     type1Foreground: .lightGray,
                                                     
                                                     type2TextString: "Sign in",
                                                     type2FontName: .bold,
                                                     type2FontSize: 14,
                                                     type2Foreground: UIColor.rgb(red: 7, green: 154, blue: 237))

            btn.addTarget(self, action: #selector(self.handleShowLogin), for: .touchUpInside)
        return btn
    }()
    
    
    // MARK: - StackView
    private lazy var stackView: UIStackView = {
        return UIStackView().stackView(arrangedSubviews:
                                        [self.emailTextField, self.passwordTextField,
                                         self.fullNameTextField, self.userNameTextField,
                                         self.signUpButton],
                                       axis: .vertical,
                                       spacing: 10,
                                       alignment: .fill,
                                       distribution: .fillEqually)
    }()
    
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure UI
        self.configureUI()
    }
    
    private func configureUI() {
        // background color
        self.view.backgroundColor = .white
        
        // plusButton
        self.view.addSubview(self.plusButton)
        self.plusButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.plusButton.anchor(top: self.view.topAnchor, paddingTop: 80,
                               width: 140, height: 140)
        // stackView
        self.view.addSubview(self.stackView)
        self.stackView.anchor(top: self.plusButton.bottomAnchor, paddingTop: 30,
                              leading: self.view.leadingAnchor, paddingLeading: 40,
                              trailing: self.view.trailingAnchor, paddingTrailing: 40,
                              height: 240)
        // alreadyHaveAccountButton
        self.view.addSubview(self.alreadyHaveAccountButton)
        self.alreadyHaveAccountButton.anchor(bottom: view.bottomAnchor, paddingBottom: 15,
                                             leading: view.leadingAnchor,
                                             trailing: view.trailingAnchor,
                                             height: 50)
    }
    
    
    
    // MARK: - Selectors
    // 뒤로가기
    @objc func handleShowLogin() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // 회원가입
    @objc func handleSignUp() {
        guard let email = self.emailTextField.text else { return }
        guard let password = self.passwordTextField.text else { return }
        guard let fullName = self.fullNameTextField.text else { return }
        guard let userName = self.userNameTextField.text?.lowercased() else { return }
        
        // authentication: 인증
        // 유저를 만듦
        Auth.auth().createUser(withEmail: email, password: password) { user, error in
            // error
            if let error = error {
                print("Failed to create user with error", error.localizedDescription)
                return
            }
            
            // set profile image
            guard let profileImage = self.plusButton.imageView?.image else { return }
            // upload data
                //지정한 이미지를 포함하는 데이터 개체를 JPEG 형식으로 반환, 0.8은 데이터의 품질을 나타낸것 1에 가까울수록 품질이 높은 것
            guard let uploadData = profileImage.jpegData(compressionQuality: 0.3) else { return }
            
            // profile image in firebase storage
            let fileName = NSUUID().uuidString
            
            // 이미지를 저장할 경로 설정
            let storageRef = STORAGE_PROFILE_IMAGES_REF.child(fileName)
            // 이미지 저장
            storageRef.putData(uploadData, metadata: nil) { metaData, error in
                // handle error
                if let error = error {
                    print("Failed to upload image to Firebase storage with error", error.localizedDescription)
                    return
                }
                // profile image url
                    
                storageRef.downloadURL { downloadURL, error in
                    
                    guard let profileImagURL = downloadURL?.absoluteString else {
                        print("DEBUG: Profile image url is nil")
                        return
                    }
                    // 사용자에 대한 사전 값
                    let dictionaryValues = ["name": fullName,
                                            "userName": userName,
                                            "profileImageUrl": profileImagURL]
                    // userID 만들기
                    guard let uid = user?.user.uid else { return }
                    
                    let values = [uid: dictionaryValues]
                    // realtime database에 저장
                    // save user info to database
                    USER_REF.updateChildValues(values) { error, ref in
                        
                        guard let mainTabVC = UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.rootViewController as? MainTabVC else { return }

                        mainTabVC.configureViewControllers()
                        
                        // dismiss login controller
                        self.dismiss(animated: true, completion: nil)
                        
                        // success
                        print("Successfully create user and saved information to database")
                    }
                }
            }
        }
    }
    
    // 아이디 / 비번이 다 차면 로그인 버튼 활성화
    @objc func formValidation() {
        guard
            self.imageSelected == true,
            self.emailTextField.hasText,
            self.passwordTextField.hasText,
            self.fullNameTextField.hasText,
            self.userNameTextField.hasText
        else {
            self.signUpButton.isEnabled = false
            self.signUpButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
            return
        }
        self.signUpButton.isEnabled = true
        self.signUpButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
    }
    
    @objc func handleSelectProfilePhoto() {
        // configure imagePicker
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        // present iamge picker
        self.present(imagePicker, animated: true)
    }
    
}



// MARK: - UIImagePickerControllerDelegate
extension SignUpVC: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // 이미지를 선택하면 타입을 UIImage로 바꿈
        guard let profileImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            self.imageSelected = false
            return
        }
        
        // 이미지가 존재한다고 표시
        self.imageSelected = true
        
        // configre plusPhotoButton with selected image
        plusButton.layer.cornerRadius = plusButton.frame.width / 2
        plusButton.clipsToBounds = true
        plusButton.layer.borderColor = UIColor.black.cgColor
        plusButton.layer.borderWidth = 2
        plusButton.setImage(profileImage.withRenderingMode(.alwaysOriginal), for: .normal)
        
        
        self.dismiss(animated: true, completion: nil)
    }
    
}
