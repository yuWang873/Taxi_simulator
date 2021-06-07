//
//  PickUpController.swift
//  driver_api
//
//  Created by WY on 2021/6/6.
//

import UIKit
import MapKit

protocol PickupControllerDelegate: AnyObject {
    func didAcceptTrip(_ trip: Trip)
}

class PickupController: UIViewController{
    
    // MARK: - Properties
    
    private let mapView = MKMapView()
    let trip: Trip
    weak var delegate: PickupControllerDelegate?
    
    private let btn_cancel: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "baseline_clear_white_36pt_2x").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
        return btn
    }()
    
    private let lbl_pickup: UILabel = {
        let lbl = UILabel()
        lbl.text = "Would you like to pickup this passenger?"
        lbl.font = UIFont.systemFont(ofSize: 18)
        lbl.textColor = .white
        return lbl
    }()
    
    private let btn_acceptTrip: UIButton = {
        let btn = UIButton(type: .system)
        btn.addTarget(self, action: #selector(handleAcceptTrip), for: .touchUpInside)
        btn.backgroundColor = .white
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        btn.setTitleColor(.black, for: .normal)
        btn.setTitle("ACCEPT TRIP", for: .normal)
        return btn
    }()
    // MARK: - Lifecycle
    
    init(trip:Trip){
        self.trip = trip
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        configureUI()
        configureMapView()
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    // MARK: - Selectors
    
    @objc func handleDismissal(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleAcceptTrip(){
        Service.shared.acceptTrip(trip: trip) { (error, ref) in
            self.delegate?.didAcceptTrip(self.trip)
        }
    }
    
    // MARK: - API
    
    // MARK: - Helper Functions
    
    func configureUI(){
        view.backgroundColor = .backgroundColor

        //Cancel button at top left corner
        view.addSubview(btn_cancel)
        btn_cancel.anchor(top:view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 16, paddingLeft: 16)
        
        //Round map view
        view.addSubview(mapView)
        mapView.setDimensions(height: 270, width: 270)
        mapView.layer.cornerRadius = 270/2
        mapView.centerX(inView: view)
        mapView.centerY(inView: view, constant: -126)
        
        //Pickup message
        view.addSubview(lbl_pickup)
        lbl_pickup.centerX(inView: view)
        lbl_pickup.anchor(top:mapView.bottomAnchor, paddingTop: 16)
        
        //Accept trip button
        view.addSubview(btn_acceptTrip)
        btn_acceptTrip.anchor(top: lbl_pickup.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 16, paddingLeft: 32, paddingRight: 32, height: 50)
        
    }
    
    func configureMapView(){
        let region = MKCoordinateRegion(center: trip.pickupCoordinates, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: false)
        
        let anno = MKPointAnnotation()
        anno.coordinate = trip.pickupCoordinates
        mapView.addAnnotation(anno)
        mapView.selectAnnotation(anno, animated: true)
    }
    
}
