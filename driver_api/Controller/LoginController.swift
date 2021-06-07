//
//  loginController.swift
//  driver_api
//
//  Created by WY on 2021/6/1.
//

import UIKit
import Firebase

class LoginController: UIViewController {
    //MARK: - Properties
    
    //title
    private let lbl_title: UILabel = {
        let lbl = UILabel()
        lbl.text = "Taxi Simulator"
        lbl.font = UIFont.systemFont(ofSize: 36)
        lbl.textColor = UIColor(white:1, alpha:0.87)
        return lbl
    }()
    
    //login container
    private lazy var emailContainerView: UIView = {
        let view =  UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_mail_outline_white_2x"), textField: tf_email)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    //login text field
    private let tf_email: UITextField = {
        return UITextField().textField(withPlaceHolder:"Email", isSecureTextEntry: false)
    }()
    
    //password container
    private lazy var passwordContainerView: UIView = {
        let view =  UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_lock_outline_white_2x"), textField: tf_password)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    //password text field
    private let tf_password: UITextField = {
        return UITextField().textField(withPlaceHolder: "Password", isSecureTextEntry: true)
    }()
    
    private let btn_login: AuthButton = {
        let btn = AuthButton(type: .system)
        btn.setTitle("Log In", for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        btn.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return btn
    }()
    
    //sign up button
    let btn_doNotHaveAccount: UIButton = {
        let btn = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account? ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        attributedTitle.append(NSAttributedString(string: "Sign Up", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.mainBlueTint]))
        btn.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        btn.setAttributedTitle(attributedTitle, for: .normal)
        return btn
    }()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        //change status bar to be white
        return .lightContent
    }
    
    // MARK: - Selectors
    
    @objc func handleShowSignUp(){
        let controller = SignUpController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleLogin(){
        guard let email = tf_email.text else{return}
        guard let password = tf_password.text else {return}
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error{
                print("Failed to log user in with error:  \(error.localizedDescription)")
                return
            }
            guard let controller =  UIApplication.shared.windows.first!.rootViewController as? HomeController else{return}
            //self.presentAlertController(withMessage: "Successfully signed in!", title: "Signed In")
            controller.configure()
            self.dismiss(animated: true, completion: nil)
        }
    }
    // MARK: - Helper
    
    func configureUI() {
        configureNavigationBar()
        
        view.backgroundColor = .backgroundColor
        
        //logo
        view.addSubview(lbl_title)
        lbl_title.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 40)
        lbl_title.centerX(inView: view)
        
        let stack = UIStackView(arrangedSubviews: [emailContainerView, passwordContainerView, btn_login])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 24
        
        view.addSubview(stack)
        stack.anchor(top:lbl_title.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingLeft: 16, paddingRight: 16)
        
        view.addSubview(btn_doNotHaveAccount)
        btn_doNotHaveAccount.centerX(inView: view)
        btn_doNotHaveAccount.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, height: 32)
    }
    
    func configureNavigationBar(){
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
        
    }


}
