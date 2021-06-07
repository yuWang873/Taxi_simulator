//
//  LocationCell.swift
//  driver_api
//
//  Created by WY on 2021/6/4.
//

import UIKit
import MapKit

class LocationCell: UITableViewCell {

    // MARK: - Properties
    var placemark: MKPlacemark?{
        didSet{
            lbl_title.text = placemark?.name
            lbl_address.text = placemark?.address
        }
    }
    
    var lbl_title: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 14)
        return lbl
    }()
    
    var lbl_address: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 14)
        lbl.textColor = .lightGray
        return lbl
    }()
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        let stack = UIStackView(arrangedSubviews: [lbl_title, lbl_address])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 4
        
        addSubview(stack)
        stack.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 12)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
