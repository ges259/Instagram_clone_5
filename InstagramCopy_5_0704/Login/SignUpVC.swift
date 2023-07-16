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
    

    
    // MARK: - View
    private lazy var logoContainerView: UIView = {
        let view = UIView()

        view.addSubview(self.logoImage)

        logoImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        logoImage.anchor(top: view.topAnchor, bottom: nil, leading: nil, trailing: nil,
                         paddingTop: 80, paddingBottom: 0, paddingLeading: 0, paddingTrailing: 0,
                         width: 250, height: 70)
        logoImage.contentMode = .scaleAspectFill

        view.backgroundColor = UIColor(red: 0/255, green: 120/255, blue: 175/255, alpha: 1)

        return view
    }()
    
    
    // MARK: - ImageView
    private let logoImage: UIImageView = {
        let img = UIImageView(image: UIImage(named: "logo2"))
        return img
    }()
    
    
    // MARK: - TextView
    private let emailTextField: InsetTextField = {
        let tf = InsetTextField()
        
        tf.placeholder = "Email"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.font = UIFont.systemFont(ofSize: 14)
        
        tf.insetX = 16
        
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        
        tf.clipsToBounds = true
        tf.layer.cornerRadius = 10
        
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)

        return tf
    }()
    private let passwordTextField: InsetTextField = {
        let tf = InsetTextField()
        
        tf.placeholder = "Password"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.isSecureTextEntry = true
        
        tf.insetX = 16
        
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        
        tf.clipsToBounds = true
        tf.layer.cornerRadius = 10
        
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        
        return tf
    }()
    private let fullNameTextField: InsetTextField = {
        let tf = InsetTextField()
        
        tf.placeholder = "Full Name"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.font = UIFont.systemFont(ofSize: 14)
        
        tf.insetX = 16
        
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no

        tf.clipsToBounds = true
        tf.layer.cornerRadius = 10
        
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)

        return tf
    }()
    private let userNameTextField: InsetTextField = {
        let tf = InsetTextField()
        
        tf.placeholder = "User Name"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.font = UIFont.systemFont(ofSize: 14)
        
        tf.insetX = 16
        
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no

        tf.clipsToBounds = true
        tf.layer.cornerRadius = 10
        
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)

        return tf
    }()
    
    
    // MARK: - Button
    private let plusButton: UIButton = {
        let btn = UIButton()
        
        btn.setImage(UIImage(named: "plus_photo"), for: .normal)
        btn.imageView?.contentMode = .scaleAspectFit
        
        btn.addTarget(self, action: #selector(handleSelectProfilePhoto), for: .touchUpInside)
        
        return btn
    }()
    private let signUpButton: UIButton = {
        let btn = UIButton(type: .system)
        
        btn.setTitle("Login", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
        
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 10
        
        btn.isEnabled = false
        btn.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        
        return btn
    }()
    private let alreadyHaveAccountButton: UIButton = {
        let btn = UIButton(type: .system)

        let attributedTitle = NSMutableAttributedString(string: "Already have an account?   ", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])

        attributedTitle.append(NSAttributedString(string: "Sign in",
                                                  attributes: [.font: UIFont.systemFont(ofSize: 14),
                                                               NSAttributedString.Key.foregroundColor: UIColor(red: 7/255, green: 154/255, blue: 237/255, alpha: 1)]))
        btn.setAttributedTitle(attributedTitle, for: .normal)

        btn.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)

        return btn
    }()
    
    
    // MARK: - StackView
    private lazy var stackView: UIStackView = {
        let stv = UIStackView(arrangedSubviews: [self.emailTextField, self.passwordTextField,
                                                 self.fullNameTextField, self.userNameTextField,
                                                 self.signUpButton])
        stv.axis = .vertical
        stv.spacing = 10
        stv.alignment = .fill
        stv.distribution = .fillEqually
        
        return stv
    }()
    
    
    
    
    
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // background color
        self.view.backgroundColor = .white
        
        // configure UI
        configureUI()
    }
    
    
    private func configureUI() {
        
        self.view.addSubview(self.plusButton)
        self.plusButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.plusButton.anchor(top: self.view.topAnchor, bottom: nil,
                               leading: nil, trailing: nil,
                               paddingTop: 80, paddingBottom: 0,
                               paddingLeading: 0, paddingTrailing: 0,
                               width: 140, height: 140)
        
        self.view.addSubview(self.stackView)
        self.stackView.anchor(top: self.plusButton.bottomAnchor, bottom: nil,
                              leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor,
                              paddingTop: 30, paddingBottom: 0,
                              paddingLeading: 40, paddingTrailing: 40,
                              width: 0, height: 240)
        
        self.view.addSubview(self.alreadyHaveAccountButton)
        self.alreadyHaveAccountButton.anchor(top: nil, bottom: view.bottomAnchor,
                                             leading: view.leadingAnchor, trailing: view.trailingAnchor,
                                             paddingTop: 0, paddingBottom: 0,
                                             paddingLeading: 0, paddingTrailing: 0,
                                             width: 0, height: 50)
    }
    
    
    
    // MARK: - Handlers
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
            self.signUpButton.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
            return
        }
        self.signUpButton.isEnabled = true
        self.signUpButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
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
