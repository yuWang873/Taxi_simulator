//
//  LocationInputActivationView.swift
//  driver_api
//
//  Created by WY on 2021/6/3.
//

import UIKit

protocol LocationInputActivationViewDelegate: AnyObject {
    func presentLocationInputView()
}

class LocationInputActivationView: UIView{
    
    // MARK: - Properties
    
    weak var delegate: LocationInputActivationViewDelegate?
    
    private let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private let lbl_placeholder: UILabel = {
        let lbl = UILabel()
        lbl.text = "Where to?"
        lbl.font = UIFont.systemFont(ofSize: 18)
        lbl.textColor = .darkGray
        return lbl
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect){
        super.init(frame: frame)
        
        addShadow()
        
        backgroundColor = .white
        
        addSubview(indicatorView)
        indicatorView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 16)
        indicatorView.setDimensions(height: 6, width: 6)
        
        addSubview(lbl_placeholder)
        lbl_placeholder.centerY(inView: self, leftAnchor: indicatorView.rightAnchor, paddingLeft: 20)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(presentLocationInputView))
        addGestureRecognizer(tap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    
    @objc func presentLocationInputView(){
        delegate?.presentLocationInputView()
    }
}
