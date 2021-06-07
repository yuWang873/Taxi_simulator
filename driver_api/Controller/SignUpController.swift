//
//  SignUpController.swift
//  driver_api
//
//  Created by WY on 2021/6/2.
//

import UIKit
import Firebase
import GeoFire

class SignUpController: UIViewController{
    
    //MARK: - Properties
    
    private var location = LocationHandler.shared.locationManager.location
    
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
    
    //name container
    private lazy var nameContainerView: UIView = {
        let view =  UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_person_outline_white_2x"), textField: tf_name)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    //name text field
    private let tf_name: UITextField = {
        return UITextField().textField(withPlaceHolder:"Name", isSecureTextEntry: false)
    }()
    
    //account type
    private lazy var accountTypeContainerView: UIView = {
        let view =  UIView().inputContainerView(image:#imageLiteral(resourceName: "ic_account_box_white_2x"), segmentedControl: accountTypeSegementedControl)
        view.heightAnchor.constraint(equalToConstant: 80).isActive = true
        return view
    }()
    
    private let accountTypeSegementedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items:["Rider", "Driver"])
        sc.backgroundColor = .backgroundColor
        sc.tintColor = UIColor(white: 1, alpha: 0.87)
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    private let btn_signUp: AuthButton = {
        let btn = AuthButton(type: .system)
        btn.setTitle("Sign Up", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        btn.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return btn
    }()
    
    //sign in button
    let btn_alreadyHaveAccount: UIButton = {
        let btn = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Already have an account? ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        attributedTitle.append(NSAttributedString(string: "Sign In", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.mainBlueTint]))
        btn.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        btn.setAttributedTitle(attributedTitle, for: .normal)
        return btn
    }()
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
    }
    
    //MARK: - Selectors
    @objc func handleShowLogin(){
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleSignUp(){
        //Make sure the condition is met
        guard let email = tf_email.text else{return}
        guard let password = tf_password.text else {return}
        guard let name = tf_name.text else{return}
        let accountTypeIndex = accountTypeSegementedControl.selectedSegmentIndex
        
        Auth.auth().createUser(withEmail: email, password: password) {(result, error) in
            if let error = error{
                print("Failed to register user iwth error:  \(error.localizedDescription)")
                return
            }
            
            guard let uid = result?.user.uid else{return}
            let values = ["email": email, "name": name, "accountType": accountTypeIndex] as [String : Any]
            
            //create driver
            if accountTypeIndex == 1{
                let geofire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)
                guard let location = self.location else {return}
                geofire.setLocation(location, forKey: uid, withCompletionBlock:  { (error) in
                    self.uploadUserDataAndDismiss(uid: uid, values: values)
                })
            }
            //self.presentAlertController(withMessage: "Successfully Signed Up", title: "Signed Up")
            self.uploadUserDataAndDismiss(uid: uid, values: values)

            //self.present(LoginController(), animated: true, completion: nil)
            //self.navigationController?.popViewController(animated: true)

        }
    }
    
    // MARK: - Helper
    
    func uploadUserDataAndDismiss(uid: String, values: [String: Any]){
        REF_USERS.child(uid).updateChildValues(values, withCompletionBlock: {(error, ref) in
            guard let controller = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController as? HomeController else{return}
            controller.configure()
            
            self.dismiss(animated: true, completion: nil)

        })
    }
    
    func configureUI() {
        view.backgroundColor = .backgroundColor
        
        //logo
        view.addSubview(lbl_title)
        lbl_title.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 40)
        lbl_title.centerX(inView: view)
        
        let stack = UIStackView(arrangedSubviews: [emailContainerView, nameContainerView, passwordContainerView, accountTypeContainerView, btn_signUp])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 24
    
        view.addSubview(stack)
        stack.anchor(top:lbl_title.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 60, paddingLeft: 16, paddingRight: 16)
        
        
        view.addSubview(btn_alreadyHaveAccount)
        btn_alreadyHaveAccount.centerX(inView: view)
        btn_alreadyHaveAccount.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, height: 32)
    }
    
}
