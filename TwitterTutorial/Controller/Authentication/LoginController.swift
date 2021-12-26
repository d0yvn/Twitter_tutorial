//
//  LoginController.swift
//  TwitterTutorial
//
//  Created by doyun on 2021/12/21.
//

import UIKit

class LoginController: UIViewController {
    
    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.image = UIImage(named: "TwitterLogo")
        
        return iv
    }()
    
    private lazy var emailContainerView: UIView = {
        let image = UIImage(named: "ic_mail_outline_white_2x-1")
        let view = Utilities().inputContrainerView(withImage: image, textField: emailTextField)
        return view
        
    }()
    
    private lazy var passwordContainerView: UIView = {
        let image = UIImage(named: "ic_lock_outline_white_2x")
        let view = Utilities().inputContrainerView(withImage: image, textField: passwordTextField)
        
        return view
    }()
    
    private let emailTextField : UITextField = {
        let tf = Utilities().textField(withPlaceholder: "Email")
        tf.autocapitalizationType = .none
        return tf
    }()
    
    private let passwordTextField : UITextField = {
        let tf = Utilities().textField(withPlaceholder: "Password")
        tf.isSecureTextEntry = true
        
        return tf
    }()
    
    private let loginButton : UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log in", for: .normal)
        button.setTitleColor(.twitterBlue, for: .normal)
        button.backgroundColor = .white
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
    
    private let donthaveAccountButton:UIButton = {
        let button = Utilities().attributedButton("Don't have an account?", " Sign up")
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        // Do any additional setup after loading the view.
    }
    //MARK: - selectors
    
    @objc func handleLogin() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        AuthService.shared.logUserIn(withEmail: email, password: password) { (result,error) in
            if let error = error {
                print("DEBUG : Error logging in \(error.localizedDescription)")
            }
            print("DEBUG : Successfully log in")
            
            guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
            guard let tab = window.rootViewController as? MainTapController else { return }
            tab.authenticateUserAndConfigureUI()
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    @objc func handleShowSignUp() {
        let controller = RegisterController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    //MARK: - helper
    
    func configureUI(){
        view.backgroundColor = .twitterBlue
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isHidden = true
        
        view.addSubview(logoImageView)
        logoImageView.centerX(inView: view, topAnchor: view.safeAreaLayoutGuide.topAnchor)
        
        logoImageView.setDimensions(width: 150 , height: 150)
        
        let stackView = UIStackView(arrangedSubviews: [emailContainerView,passwordContainerView,loginButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fillEqually 
        
        view.addSubview(stackView)
        stackView.anchor(top: logoImageView.bottomAnchor, left : view.leftAnchor,
                         right: view.rightAnchor,paddingLeft: 32, paddingRight: 32)
        
        view.addSubview(donthaveAccountButton)
        donthaveAccountButton.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor,
                                     paddingLeft: 40, paddingRight: 40)
        
        
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
