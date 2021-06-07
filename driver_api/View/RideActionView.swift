//
//  RideActionView.swift
//  driver_api
//
//  Created by WY on 2021/6/5.
//

import UIKit
import MapKit

protocol RideActionViewDelegate: AnyObject{
    func uploadTrip(_ view: RideActionView)
    func cancelTrip()
}

enum RideActionViewConfiguration {
    case requestRide
    case tripAccepted
    case pickupPassenger
    case tripInProgress
    case endTrip
    
    init() {
        self = .requestRide
    }
}

enum ButtonAction: CustomStringConvertible{
    case requestRide
    case cancel
    case getDirections
    case pickup
    case dropOff
    
    var description: String {
        switch self{
        case .requestRide: return "Confirm Ride"
        case .cancel: return "Cancel Ride"
        case .getDirections: return "Get Direction"
        case .pickup: return "Pickup Passenger"
        case .dropOff: return "Drop off Passenger"
        }
    }
    
    init(){
        self = .requestRide
    }
}

class RideActionView: UIView {

// MARK: - Properties
    
    var destination: MKPlacemark? {
        didSet{
            lbl_title.text = destination?.name
            lbl_address.text = destination?.address
        }
    }
    
    var config = RideActionViewConfiguration()
    var buttonAction = ButtonAction()
    weak var delegate: RideActionViewDelegate?
    var user: User?
    
    private let lbl_title: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 16)
        lbl.textAlignment = .center
        return lbl
    }()
    
    private let lbl_address: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .lightGray
        lbl.font = UIFont.systemFont(ofSize: 16)
        lbl.textAlignment = .center
        return lbl
    }()
    
    private lazy var infoView: UIView = {
        let view = UIView()
        view.backgroundColor = .mainBlueTint

        
        view.addSubview(lbl_infoView)
        lbl_infoView.centerX(inView: view)
        lbl_infoView.centerY(inView: view)
        return view
    }()
    
    private let lbl_infoView: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 30)
        lbl.textColor = .white
        lbl.text = "F"
        return lbl
    }()
    
    private let lbl_userInfo: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 18)
        lbl.text = "Find Driver"
        lbl.textAlignment = .center
        return lbl
    }()
    
    private let btn_action: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .mainBlueTint
        btn.setTitle("Confirm Ride", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        btn.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        return btn
    }()
    
// MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        addShadow()
        
        let stack = UIStackView(arrangedSubviews: [lbl_title, lbl_address])
        stack.axis = .vertical
        stack.spacing = 4
        stack.distribution = .fillEqually
        
        addSubview(stack)
        stack.centerX(inView: self)
        stack.anchor(top: topAnchor, paddingTop: 12)
        
        addSubview(infoView)
        infoView.centerX(inView: self)
        infoView.anchor(top: stack.bottomAnchor, paddingTop: 16)
        infoView.setDimensions(height: 60, width: 60)
        infoView.layer.cornerRadius = 60 / 2
        
        addSubview(lbl_userInfo)
        lbl_userInfo.anchor(top: infoView.bottomAnchor, paddingTop: 8)
        lbl_userInfo.centerX(inView: self)
        
        let separatorView = UIView()
        separatorView.backgroundColor = .lightGray
        addSubview(separatorView)
        separatorView.anchor(top: lbl_userInfo.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 4, height: 0.75)
        
        addSubview(btn_action)
        btn_action.anchor(left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor, paddingLeft: 12, paddingBottom: 12, paddingRight: 12, height: 50)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selector
    
    @objc func actionButtonPressed() {
        switch buttonAction{
        
        case .requestRide:
            delegate?.uploadTrip(self)
        case .cancel:
            delegate?.cancelTrip()
        case .getDirections:
            print("Handle Get Direction")
        case .pickup:
            print("Handle Pickup")
        case .dropOff:
            print("Handle Drop Off")
        }
    }
    
    // MARK: - Helper Functions
    
    func configureUI(withConfig config: RideActionViewConfiguration){
        switch config{
        case .requestRide:
            buttonAction = .requestRide
            btn_action.setTitle(buttonAction.description, for: .normal)
        case .tripAccepted:
            guard let user = user else{return}
            if user.accountType == .passenger{
                lbl_title.text = "Moving to passenger"
                lbl_title.font.withSize(32)
                buttonAction = .getDirections
                btn_action.setTitle(buttonAction.description, for: .normal)
            } else{
                buttonAction = .cancel
                btn_action.setTitle(buttonAction.description, for: .normal)
                lbl_title.text = "Driver is coming"
            }
            lbl_infoView.text = String(user.name.first ?? "Y")
            lbl_userInfo.text = user.name
        case .pickupPassenger:
            lbl_title.text = "Arrived At Passenger's Location"
            buttonAction = .pickup
            btn_action.setTitle(buttonAction.description, for: .normal)
        case .tripInProgress:
            guard let user = user else {return}
            if user.accountType == .driver{
                btn_action.setTitle("Trip in Progress", for: .normal)
                btn_action.isEnabled = false
            } else{
                buttonAction = .getDirections
                btn_action.setTitle(buttonAction.description, for: .normal)
            }
            lbl_title.text = "En Route to Destination"
        case .endTrip:
            guard let user = user else {return}
            if user.accountType == .driver{
                btn_action.setTitle("Arrived at Destination", for: .normal)
                btn_action.isEnabled = false
            } else {
                buttonAction = .dropOff
                btn_action.setTitle(buttonAction.description, for: .normal)
            }
        }
    }
    
}
