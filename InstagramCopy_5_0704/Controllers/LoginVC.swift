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
        let view = UIView()

        view.addSubview(self.logoImage)

        logoImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        logoImage.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        logoImage.anchor(top: view.topAnchor, bottom: nil, leading: nil, trailing: nil,
                         paddingTop: 80, paddingBottom: 0, paddingLeading: 0, paddingTrailing: 0,
                         width: 250, height: 70)

        logoImage.contentMode = .scaleAspectFill



        view.backgroundColor = UIColor(red: 0/255, green: 120/255, blue: 175/255, alpha: 1)

        return view
    }()
    // MARK: - ImageView
    private let logoImage: UIImageView = {
        let img = UIImageView(image: UIImage(named: "Instagram_logo_white"))
        return img
    }()
    
    
    
    
    
    
    
    
    // MARK: - TextView
    private let emailTextField: InsetTextField = {
        let tf = InsetTextField()
        
        tf.placeholder = "Email"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.font = UIFont.systemFont(ofSize: 14)
        
        tf.insetX = 16
        
        tf.clipsToBounds = true
        tf.layer.cornerRadius = 10
        
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        
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
        
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none

        
        tf.clipsToBounds = true
        tf.layer.cornerRadius = 10
        
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)

        
        return tf
    }()
    
    
    
    
    
    // MARK: - Button
    private let loginButton: UIButton = {
        let btn = UIButton(type: .system)
        
        btn.setTitle("Login", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
        btn.isEnabled = false
        
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 10
         
        btn.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        
        return btn
    }()
    
    private let dontHaveAccountButton: UIButton = {
        let btn = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "Dont't have an account?   ", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        attributedTitle.append(NSAttributedString(string: "Sign Up", attributes: [.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor(red: 7/255, green: 154/255, blue: 237/255, alpha: 1)]))
        
        btn.setAttributedTitle(attributedTitle, for: .normal)
        
        btn.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        
        return btn
    }()
    
    
    
    // MARK: - StackView
    private lazy var stackView: UIStackView = {
        let stv = UIStackView(arrangedSubviews: [self.emailTextField, self.passwordTextField, self.loginButton])
        
        stv.axis = .vertical
        stv.spacing = 10
        stv.alignment = .fill
        stv.distribution = .fillEqually
        
        return stv
    }()
    
    
    
    
    
    
    // MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // background color
        self.view.backgroundColor = .white
        
        
        
        self.navigationController?.navigationBar.isHidden = true
        
        configureUI()
        
        
        
    }
    
    
    
    
    // MARK: - configureUI()
    private func configureUI() {
        self.view.addSubview(self.logoContainerView)
        self.view.addSubview(self.stackView)
        self.view.addSubview(self.dontHaveAccountButton)
        
        self.logoContainerView.anchor(top: self.view.topAnchor, bottom: nil, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor, paddingTop: 0, paddingBottom: 0, paddingLeading: 0, paddingTrailing: 0, width: 0, height: 200)
        
        self.stackView.anchor(top: self.logoContainerView.bottomAnchor, bottom: nil, leading: view.leadingAnchor, trailing: view.trailingAnchor, paddingTop: 40, paddingBottom: 0, paddingLeading: 20, paddingTrailing: 20, width: 0, height: 150)
        
        
        self.dontHaveAccountButton.anchor(top: nil, bottom: self.view.bottomAnchor, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor, paddingTop: 0, paddingBottom: 0, paddingLeading: 0, paddingTrailing: 0, width: 0, height: 50)
    }
    
    
    
    
    
    
    
    
    
    // MARK: - @objc
    @objc func handleShowSignUp() {
        let signUpVC = SignUpVC()
        navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    @objc func formValidation() {
        
        // ensures that email and password text fields have text
        guard
            self.emailTextField.hasText,
            self.passwordTextField.hasText
        else {
            
            // handle case for above conditions not met
            self.loginButton.isEnabled = false
            self.loginButton.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
            return
        }
        
        // handle case for conditions were met
        self.loginButton.isEnabled = true
        self.loginButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        
        
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
//
            
            // dismiss login controller
            self.dismiss(animated: true, completion: nil)
            
            // handle success
            print("Successfully signed user in")
        }
    }
    
    
    
}
