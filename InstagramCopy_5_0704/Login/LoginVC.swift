//
//  LoginVC.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/04.
//

import UIKit
import FirebaseAuth

final class LoginVC: UIViewController {
    
    // MARK: - View
    private lazy var logoContainerView: UIView = {
        return UIView().backgrouncColorView(backgroundColor: UIColor.rgb(red: 0, green: 120, blue: 175))
    }()
    
    
    
    // MARK: - ImageView
    private lazy var logoImage: UIImageView = {
        return UIImageView(image: UIImage(named: "Instagram_logo_white"))
    }()
    
    
    
    // MARK: - TextField
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
    
    
    
    // MARK: - Button
    private lazy var loginButton: UIButton = {
        let btn = UIButton().button(title: "Login",
                                    titleColor: .white,
                                    
                                    fontName: .bold,
                                    fontSize: 18,
                                    backgroundColor: UIColor.textFieldGray,
                                    
                                    cornerRadius: 10,
                                    isEnable: false)
        
        btn.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return btn
    }()
    private lazy var dontHaveAccountButton: UIButton = {
        let btn = UIButton().mutableAttributedString(buttonType: .system,
                                                     
                                                     type1TextString: "Dont't have an account?   ",
                                                     type1FontName: .system,
                                                     type1FontSize: 14,
                                                     type1Foreground: .lightGray,
                                                     
                                                     type2TextString: "Sign in",
                                                     type2FontName: .bold,
                                                     type2FontSize: 14,
                                                     type2Foreground: .instaBlue)
 
        btn.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        return btn
    }()
    
    
    
    // MARK: - StackView
    private lazy var stackView: UIStackView = {
        return UIStackView().stackView(arrangedSubviews:
                                            [self.emailTextField,
                                             self.passwordTextField,
                                             self.loginButton],
                                          axis: .vertical,
                                          spacing: 10,
                                          alignment: .fill,
                                          distribution: .fillEqually)
    }()
    
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configre UI
        self.configureUI()
    }
    
    
    
    // MARK: - configureUI()
    private func configureUI() {
        // background color
        self.view.backgroundColor = .white
        // hide navigationBar
        self.navigationController?.navigationBar.isHidden = true
        
        // logoContainerView
        self.view.addSubview(self.logoContainerView)
        self.logoContainerView.anchor(top: self.view.topAnchor,
                                      leading: self.view.leadingAnchor,
                                      trailing: self.view.trailingAnchor,
                                      height: 200)
        // logoImage
        self.logoContainerView.addSubview(self.logoImage)
        self.logoImage.contentMode = .scaleAspectFill
        self.logoImage.anchor(top: self.logoContainerView.topAnchor, paddingTop: 80,
                              width: 250, height: 70,
                              centerX: self.logoContainerView)
        // stackView
        self.view.addSubview(self.stackView)
        self.stackView.anchor(top: self.logoContainerView.bottomAnchor, paddingTop: 40,
                              leading: view.leadingAnchor, paddingLeading: 20,
                              trailing: view.trailingAnchor, paddingTrailing: 20,
                              height: 150)
        // dontHaveAccountButton
        self.view.addSubview(self.dontHaveAccountButton)
        self.dontHaveAccountButton.anchor(bottom: self.view.bottomAnchor, paddingBottom: 15,
                                          leading: self.view.leadingAnchor,
                                          trailing: self.view.trailingAnchor,
                                          height: 50)
    }
    
    
    
    // MARK: - Selectors
    @objc func handleShowSignUp() {
        let signUpVC = SignUpVC()
        self.navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    
    @objc func formValidation() {
        // ensures that email and password text fields have text
        guard
            self.emailTextField.hasText,
            self.passwordTextField.hasText
        else {
            // handle case for above conditions not met
            self.loginButton.isEnabled = false
            self.loginButton.backgroundColor = UIColor.textFieldGray
            return
        }
        // handle case for conditions were met
        self.loginButton.isEnabled = true
        self.loginButton.backgroundColor = UIColor.buttonBlue
    }
    
    
    @objc func handleLogin() {
        // properties
        guard
            let email = self.emailTextField.text,
            let password = self.passwordTextField.text
        else {
            return
        }
        // sign user in with email and password
        Auth.auth().signIn(withEmail: email, password: password) { user, error in
            // handle error
            if let error = error {
                print("Unalbe to sign user in with error")
                return
            }
            
            guard let mainTabVC = UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.rootViewController as? MainTabVC else { return }

            mainTabVC.configureViewControllers()

            // dismiss login controller
            self.dismiss(animated: true, completion: nil)
            
            // handle success
            print("Successfully signed user in")
        }
    }
    
}
