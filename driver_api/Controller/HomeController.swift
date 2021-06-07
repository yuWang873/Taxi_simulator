//
//  HomeController.swift
//  driver_api
//
//  Created by WY on 2021/6/2.
//

import UIKit
import Firebase
import MapKit

private let reuseIdentifier = "LocationCell"
private let annotationIdentifer = "DriverAnnotation"
private enum ActionButtonConfiguration{
    case showMenu
    case dismissActionView
    
    init(){
        self = .showMenu
    }
}

class HomeController: UIViewController {
    
    //MARK: - Properties
    
    private let mapView = MKMapView()
    private let locationManager = LocationHandler.shared.locationManager
    private let inputActivationView = LocationInputActivationView()
    private let locationInputView = LocationInputView()
    private let rideActionView = RideActionView()
    private let tableView = UITableView()
    private final let locationInputViewHeight: CGFloat = 200
    private final let rideActionViewHeight: CGFloat = 300
    private var searchResults = [MKPlacemark]()
    private var actionButtonConfig = ActionButtonConfiguration()
    private var route:MKRoute?
    private let driverView = DriverView()
    
    private var user: User? {
        didSet{
            locationInputView.user = user
            if user?.accountType == .passenger{
                fetchDrivers()
                configureLocationInputActivationView()
                observeCurrentTrip()
            }else{
                configureDriverUI()
                
            }
        }
    }
    
    private var trip: Trip? {
        didSet{
            guard let user = user else{return}
            
            if user.accountType == .driver{
                guard let trip = trip else {return}
                let controller = PickupController(trip: trip)
                controller.delegate = self
                self.present(controller, animated: true, completion: nil)
            } else {
                print("show ride action view for accepted trip")
            }
        }
    }
    
    private var btn_action: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        return btn
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLoggedIn()
        enableLoctionServices()

        signOut()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard trip != nil else{return}
    }
    
    //MARK: - Selectors
    
    @objc func actionButtonPressed(){
        switch actionButtonConfig {
        case .showMenu:
            print("Handle show menu")
        case .dismissActionView:
            removeAnnotationsAndOverlays()
            mapView.showAnnotations(mapView.annotations, animated: true)
            UIView.animate(withDuration: 0.3) {
                self.inputActivationView.alpha = 1
                self.configureActionButton(config: .showMenu)
                self.animateRideActionView(shouldShow: false)

            }
        }
    }
    
    //MARK: - API
    
    func observeCurrentTrip(){
        Service.shared.observeCurrentTrip { trip in
            self.trip = trip
            
            if trip.state == .accepted{
                self.shouldPresentLoadingView(false)
                guard let driverUid = trip.driverUid else{return}
                Service.shared.fetchUserData(uid: driverUid) { driver in
                    self.animateRideActionView(shouldShow: true, config: .tripAccepted, user: driver)
                }
            }
        }
    }
    
    func fetchUserData(){
        guard let currentUid = Auth.auth().currentUser?.uid else{return}
        Service.shared.fetchUserData(uid: currentUid){user in
            self.user = user
        }
    }
    
    func fetchDrivers(){
        guard let location = locationManager?.location else{return}
        Service.shared.fetchDrivers(location: location) { (driver) in
            guard let coordinate = driver.location?.coordinate else {return}
            let annotation = DriverAnnotation(uid: driver.uid, coordinate: coordinate)
            
            var driverIsVisible: Bool{
                return self.mapView.annotations.contains(where: { annotation -> Bool in
                    guard let driverAnno = annotation as? DriverAnnotation else{return false}
                    if driverAnno.uid == driver.uid {
                        driverAnno.updateAnnotationPosition(withCoordinate: coordinate)
                        return true
                    }
                    return false
                })
            }
            if !driverIsVisible{
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
    func observeTrip() {
        Service.shared.observeTrips { (trip) in
            self.trip = trip
        }
    }
    
    func checkIfUserIsLoggedIn(){
        if Auth.auth().currentUser?.uid == nil {
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                self.present(nav, animated: true, completion: nil)
            }
            print("User not logged in.")
        }
        
        else{
            configure()
        }
    }
    
    func signOut(){
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                self.present(nav, animated: true, completion: nil)
            }
        } catch {
            print("Error with signing out")
        }
    }
    
    //MARK: - Helper Functions
    func configure(){
        configureUI()
        fetchUserData()

    }
    
    fileprivate func configureActionButton(config: ActionButtonConfiguration){
        switch config{
        case .showMenu:
            self.btn_action.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
            self.actionButtonConfig = .showMenu
        case .dismissActionView:
            btn_action.setImage(#imageLiteral(resourceName: "baseline_arrow_back_black_36dp-1").withRenderingMode(.alwaysOriginal), for: .normal)
            actionButtonConfig = .dismissActionView
        }
    }
    
    func configureUI() {
        configureMapView()
        configureRideActionView()
        
        view.addSubview(btn_action)
        btn_action.anchor(top:view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 16, paddingLeft: 20, width: 30, height: 30)
        
        configureTableView()
    }
    
    func configureDriverUI(){
        driverView.delegate = self
        view.addSubview(driverView)
        driverView.frame = CGRect(x: 0, y: view.frame.height - 180, width: view.frame.width, height: 180)
    }
    
    func configureLocationInputActivationView(){
        view.addSubview(inputActivationView)
        inputActivationView.centerX(inView: view)
        inputActivationView.setDimensions(height: 50, width: view.frame.width - 64)
        inputActivationView.anchor(top: btn_action.bottomAnchor, paddingTop: 32)
        inputActivationView.delegate = self
        
        inputActivationView.alpha = 0
        UIView.animate(withDuration: 2){
            self.inputActivationView.alpha = 1
        }
    }
    
    func configureMapView(){
        view.addSubview(mapView)
        mapView.frame = view.frame
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.delegate = self
    }
    
    func configureLocationInputView(){
        locationInputView.delegate = self
        view.addSubview(locationInputView)
        locationInputView.anchor(top: view.topAnchor, left:view.leftAnchor, right: view.rightAnchor, height: 200 )
        locationInputView.alpha = 0
        
        UIView.animate(withDuration: 0.5, animations: {self.locationInputView.alpha = 1}) { _ in
            UIView.animate(withDuration: 0.3, animations:{
                self.tableView.frame.origin.y = self.locationInputViewHeight
            })
        }
    }
    
    func configureRideActionView(){
        view.addSubview(rideActionView)
        rideActionView.delegate = self
        rideActionView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: rideActionViewHeight)
    }
    
    func configureTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(LocationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 60
        tableView.tableFooterView = UIView()
        
        let height = view.frame.height - locationInputViewHeight
        tableView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: height)
        
        view.addSubview(tableView)
    }
    
    func dismissLocationView(completion: ((Bool) -> Void)? = nil){
        UIView.animate(withDuration: 0.3, animations: {
            self.locationInputView.alpha = 0
            self.tableView.frame.origin.y = self.view.frame.height
            self.locationInputView.removeFromSuperview()

        }, completion: completion)
    }
    
    func animateRideActionView(shouldShow: Bool, destination: MKPlacemark? = nil, config: RideActionViewConfiguration? = nil, user: User? = nil){
        let yOrigin = shouldShow ? self.view.frame.height - self.rideActionViewHeight : self.view.frame.height
        
        UIView.animate(withDuration: 0.3) {
            self.rideActionView.frame.origin.y = yOrigin
        }
        
        if shouldShow{
            guard let config = config else {return}
            if let destination = destination {
                rideActionView.destination = destination
            }
            
            if let user = user {
                rideActionView.user = user
            }
            rideActionView.configureUI(withConfig: config)
        }

    }
}

// MARK: - Map Helper Functions

private extension HomeController{
    func searchBy(naturalLanguageQuery: String, completion: @escaping([MKPlacemark]) -> Void){
        var results = [MKPlacemark]()
        
        let request = MKLocalSearch.Request()
        request.region = mapView.region
        request.naturalLanguageQuery = naturalLanguageQuery
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error)in
            guard let response = response else{return}
            response.mapItems.forEach ({ item in
                results.append(item.placemark)
            })
            
            completion(results)
        }
    }
    
    func generatePolyline(toDestination destination: MKMapItem){
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = destination
        request.transportType = .automobile
        
        let directionRequest = MKDirections(request: request)
        directionRequest.calculate { (response, error) in
            guard let response = response else{return}
            self.route = response.routes[0]
            guard let polyline = self.route?.polyline else {return}
            self.mapView.addOverlay(polyline)
            
        }
    }
    
    func removeAnnotationsAndOverlays(){
        mapView.annotations.forEach { (annotation) in
            if let anno = annotation as? MKPointAnnotation{
                mapView.removeAnnotation(anno)
            }
        }
        
        if mapView.overlays.count > 0 {
            mapView.removeOverlay(mapView.overlays[0])
        }
    }
    
    func centerMapOnUserLocation(){
        guard let coordinate = locationManager?.location?.coordinate else{return}
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
        mapView.setRegion(region, animated: true)
    }
}

// MARK: - MapView Delegate

extension HomeController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        guard let user  = self.user else{return}
        guard user.accountType == .driver else{return}
        guard let location = userLocation.location else{return}
        Service.shared.updateDriverLocation(location: location)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? DriverAnnotation{
            let view = MKAnnotationView(annotation: annotation, reuseIdentifier: "DriverAnno")
            view.image = #imageLiteral(resourceName: "chevron-sign-to-right")
            return view
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let route = self.route{
            let polyline = route.polyline
            let lineRenderer = MKPolylineRenderer(overlay: polyline)
            lineRenderer.strokeColor = .mainBlueTint
            lineRenderer.lineWidth = 4
            return lineRenderer
        }
        return MKOverlayRenderer()        
    }
}

// MARK: - Location Service
extension HomeController{
    func enableLoctionServices(){
        
        switch locationManager?.authorizationStatus{
        case .notDetermined:
            print("Authentication Not Determined")
            locationManager?.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        case .authorizedAlways:
            print("Authentication Always")
            locationManager?.startUpdatingLocation()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
            print("Authentication when in use")
            locationManager?.requestAlwaysAuthorization()
        case .none:
            break
        @unknown default:
            break
        }
    }
    
}

// MARK: - Location Input View Delegate

extension HomeController: LocationInputActivationViewDelegate{
    func presentLocationInputView() {
        inputActivationView.alpha = 0
        configureLocationInputView()
    }
}

extension HomeController: LocationInputViewDelegate {
    func executeSearch(query: String) {
        searchBy(naturalLanguageQuery: query) { (results) in
            self.searchResults = results
            self.tableView.reloadData()
        }
    }
    
    func dismissLocationInputView() {
        dismissLocationView{_ in
            UIView.animate(withDuration: 0.3, animations:{
                self.inputActivationView.alpha = 1
            })
        }
    }
}

extension HomeController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return section == 0 ? 2 : searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LocationCell
        if indexPath.section == 1{
            cell.placemark = searchResults[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlacemark = searchResults[indexPath.row]
        
        configureActionButton(config: .dismissActionView)
        
        let destination = MKMapItem(placemark: selectedPlacemark)
        generatePolyline(toDestination: destination)
        
        dismissLocationView{ _ in
            let annotation = MKPointAnnotation()
            annotation.coordinate = selectedPlacemark.coordinate
            self.mapView.addAnnotation(annotation)
            self.mapView.selectAnnotation(annotation, animated: true)
            let annotations = self.mapView.annotations.filter ({ !$0.isKind(of: DriverAnnotation.self)})
            self.mapView.zoomToFit(annotations: annotations)
            
            self.animateRideActionView(shouldShow: true, destination: selectedPlacemark, config: .requestRide)
        }
    }
    

}

// MARK: - Driver Action Delegate
extension HomeController: DriverActionDelegate{
    func DriverGoOnline() {
        observeTrip()
        self.driverView.frame.origin.y = self.view.frame.height
    }
    
}

// MARK: - Ride Action View Delegate

extension HomeController: RideActionViewDelegate{
    func uploadTrip(_ view: RideActionView) {
        guard let pickupCoordinates = locationManager?.location?.coordinate else{return}
        guard let destinationCoordinates = view.destination?.coordinate else{return}
        
        shouldPresentLoadingView(true, message: "Finding the driver")
        
        Service.shared.uploadTrip(pickupCoordinates, destinationCoordinates) { (error, ref) in
            if let error = error{
                print("Failed to upload trip with error: \(error)")
                return
            }
            
            UIView.animate(withDuration: 0.3, animations: {
                self.rideActionView.frame.origin.y = self.view.frame.height
            })
        }
    }
    
    func cancelTrip() {
        Service.shared.cancelTrip { (error, ref) in
            if error != nil{
                print("Error occured for canceling trip")
                return
            }
            self.centerMapOnUserLocation()
            
            self.animateRideActionView(shouldShow: false)
            self.removeAnnotationsAndOverlays()
            //self.actionButton.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
            self.actionButtonConfig = .dismissActionView
        }
    }
}

// MARK: - Pickup Controller Delegate

extension HomeController: PickupControllerDelegate{
    func didAcceptTrip(_ trip: Trip) {
        let anno = MKPointAnnotation()
        anno.coordinate = trip.pickupCoordinates
        mapView.addAnnotation(anno)
        mapView.selectAnnotation(anno, animated: true)
        
        let placemark = MKPlacemark(coordinate: trip.pickupCoordinates)
        let mapItem = MKMapItem(placemark: placemark)
        generatePolyline(toDestination: mapItem)
        
        mapView.zoomToFit(annotations: mapView.annotations)
        Service.shared.observeTripCancel(trip: trip){
            self.removeAnnotationsAndOverlays()
            self.animateRideActionView(shouldShow: false)
            self.centerMapOnUserLocation()
            self.presentAlertController(withMessage: "The passenger has cencelled the trip", title: "Trip Cancelled")
        }
    
        self.dismiss(animated: true) {
            Service.shared.fetchUserData(uid: trip.passengerUid, completion: { passenger in
                self.animateRideActionView(shouldShow: true, config: .tripAccepted, user: passenger)
            })
            
        }
    }
}
