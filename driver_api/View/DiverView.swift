//
//  DiverView.swift
//  driver_api
//
//  Created by WY on 2021/6/7.
//

import UIKit

protocol DriverActionDelegate: AnyObject {
    func DriverGoOnline()
}

class DriverView: UIView {
    // MARK: - Property
    weak var delegate: DriverActionDelegate?
    private let btn_listen: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .mainBlueTint
        btn.setTitle("Go Online", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        btn.addTarget(self, action: #selector(listenButtonPressed), for: .touchUpInside)
        return btn
    }()
    // MARK: - Lifecycle
    override init(frame: CGRect){
        super.init(frame: frame)
        backgroundColor = .white
        addShadow()
        
        addSubview(btn_listen)
        btn_listen.anchor(left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor, paddingLeft: 12, paddingBottom:10, paddingRight: 12, height: 100)
        btn_listen.layer.cornerRadius = 60/2
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selector
    @objc func listenButtonPressed(){
        delegate?.DriverGoOnline()
        print("Driver looking for passenger")
    }
}
