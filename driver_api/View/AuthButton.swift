//
//  AuthButton.swift
//  driver_api
//
//  Created by WY on 2021/6/2.
//

import UIKit

class AuthButton: UIButton {

    override init(frame: CGRect){
        super.init(frame: frame)
        
        setTitleColor(UIColor(white: 1, alpha: 0.5), for: .normal)
        backgroundColor = .mainBlueTint
        layer.cornerRadius = 5
        heightAnchor.constraint(equalToConstant: 50).isActive = true

    }
    
    required init?(coder: NSCoder) {
        fatalError("not been imeplemnted")
    }

}
