//
//  LocationInputView.swift
//  driver_api
//
//  Created by WY on 2021/6/3.
//

import UIKit

protocol LocationInputViewDelegate: AnyObject {
    func dismissLocationInputView()
    func executeSearch(query: String)
}

class LocationInputView: UIView {

    // MARK: - Properties
    
    var user: User?{
        didSet{ lbl_title.text = user?.name}
    }
    
    weak var delegate: LocationInputViewDelegate?
    
    private let btn_back: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "baseline_arrow_back_black_36dp-1").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(handleBackTapped), for: .touchUpInside)
        return btn
    }()
    
    private let lbl_title: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .darkGray
        lbl.font = UIFont.systemFont(ofSize: 16)
        return lbl
    }()
    
    private let startLocationIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    private let linkingView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        return view
    }()
    
    private let destinationIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private lazy var tf_startingLocation: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Current Location"
        tf.backgroundColor = .systemGroupedBackground
        tf.isEnabled = false
        tf.font = UIFont.systemFont(ofSize: 14)
        
        let paddingView = UIView()
        paddingView.setDimensions(height: 30, width: 8)
        tf.leftView = paddingView
        tf.leftViewMode = .always
        
        return tf
    }()
    
    private lazy var tf_destinationLocation: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter Destination"
        tf.backgroundColor = .lightGray
        tf.returnKeyType = .search
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.delegate = self
        
        let paddingView = UIView()
        paddingView.setDimensions(height: 30, width: 8)
        tf.leftView = paddingView
        tf.leftViewMode = .always
        
        return tf
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addShadow()
        backgroundColor = .white
        
        addSubview(btn_back)
        btn_back.anchor(top:topAnchor, left: leftAnchor, paddingTop: 44, paddingLeft: 12, width: 24, height: 25)
        
        addSubview(lbl_title)
        lbl_title.centerY(inView: btn_back)
        lbl_title.centerX(inView: self)
        
        addSubview(tf_startingLocation)
        tf_startingLocation.anchor(top: btn_back.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 40, paddingRight: 40, height: 30)
        
        addSubview(tf_destinationLocation)
        tf_destinationLocation.anchor(top: tf_startingLocation.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 12, paddingLeft: 40, paddingRight: 40, height:30)
        
        addSubview(startLocationIndicatorView)
        startLocationIndicatorView.centerY(inView: tf_startingLocation, leftAnchor: leftAnchor, paddingLeft: 20)
        startLocationIndicatorView.setDimensions(height: 6, width: 6)
        startLocationIndicatorView.layer.cornerRadius = 6/2
        
        addSubview(destinationIndicatorView)
        destinationIndicatorView.centerY(inView: tf_destinationLocation, leftAnchor: leftAnchor, paddingLeft: 20)
        destinationIndicatorView.setDimensions(height: 6, width: 6)
        
        addSubview(linkingView)
        linkingView.centerX(inView: startLocationIndicatorView)
        linkingView.anchor(top:startLocationIndicatorView.bottomAnchor, bottom: destinationIndicatorView.topAnchor, paddingTop: 4, paddingBottom: 4, width: 0.5)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selector
    
    @objc func handleBackTapped(){
        delegate?.dismissLocationInputView()
    }
    
}

// MARK: - Delegate

extension LocationInputView: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let query = textField.text else{return false}
        delegate?.executeSearch(query: query)
        return true
        
    }
}
