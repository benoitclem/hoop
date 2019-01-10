//
//  MapViewController.swift
//  hoop
//
//  Created by Clément on 19/12/2018.
//  Copyright © 2018 hoop. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Hero
import Futures

class MapViewController: UIViewController {
    
    @IBOutlet weak var hoopBackground: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var profiles: UICollectionView!
    @IBOutlet weak var etHoopButton: UIButton!
    @IBOutlet weak var hoopNameLabel: UILabel!
    
    var returnFromBackground: Bool = false
    
    var locationManager: CLLocationManager = CLLocationManager()
    
    var currentLocation: CLLocation!
    var lastLocation: CLLocation?
    
    var currentHoopNetwork: [hoop] = [hoop]()
    var lastHoopNetworkTimestamp: TimeInterval = Timestamp - 6000
    
    var currentHoopIds: [Int] = [Int]()
    var currentHoops: [hoop] = [hoop]()
    var lastHoopsContentTimestamp: TimeInterval = Timestamp - 6000
    
    var currentHoopsAreaOverlay: CirclesOverlay? = nil
    
    var currentSelectedHoop: hoop? = nil
    var currentHoopSelectedOverlay: MKCircle? = nil
    
    var currentHoopsContent: [String:[profile]]? = nil
    var currentProfiles = [profile]()
    
    let profilePictures: [String] = ["aicha","iris","paula","clement","rachel","samie","sophie"]
    var selectedProfile: String?
    
    // /!\ becarefull the LOW_ mean poor accurate + less frequent location updates
    
    static let HIGH_DISTANCE_FILTER = 40.0
    static let LOW_DISTANCE_FILTER = 200.0
    
    static let HIGH_REQUESTED_ACCURACY: CLLocationAccuracy = kCLLocationAccuracyNearestTenMeters
    static let LOW_REQUESTED_ACCURACY: CLLocationAccuracy = kCLLocationAccuracyHundredMeters
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkup() // Some controls on
        setup() // Configure delegates and initialize some internal states
        etHoopButton.setTitle("Bonjour", for: .normal)
        hoopNameLabel.text = "Autour du marché Saint-Germain"
    }
    
    func viewDidEnterForeground(notification: Notification) {
        
        returnFromBackground = true
        mapView.showsUserLocation = true
        
        self.locationManager.distanceFilter = MapViewController.HIGH_DISTANCE_FILTER
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    
    func viewDidEnterBackground(notification: Notification) {
        
        self.mapView.showsUserLocation = false

        self.locationManager.distanceFilter = MapViewController.LOW_DISTANCE_FILTER
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    func checkup() {
        
    }
    
    func setup() {
        setupUserInterface()
        setupLocation()
        setupMapKit()
    }
    
    func goToSettings(){
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                print("Settings opened: \(success)") // Prints true
            })
        }
    }

}

extension MapViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedProfile = profilePictures[indexPath.row]
        if let vc = try? Router.shared.matchControllerFromStoryboard("/profile/1?imageheroId=\(selectedProfile!)",storyboardName: "Main") {
            self.present(vc as! UIViewController, animated: true)
        }
        //performSegue(withIdentifier: "toProfile", sender: nil)
    }
}

extension MapViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return profilePictures.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Retrieve the object composing the cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "profileThumbIdent", for: indexPath)
        let profilName = cell.viewWithTag(1) as! UILabel
        let profilImage = cell.viewWithTag(2) as! UIImageView
        //let profilCartouche = cell.viewWithTag(3)!
        
        // Here try the localization stuffs
        profilName.text = "\(profilePictures[indexPath.row]) 27"
        profilImage.image = UIImage(imageLiteralResourceName: profilePictures[indexPath.row])
        profilImage.hero.id = profilePictures[indexPath.row]
        //profilCartouche.hero.id = "\(profilePictures[indexPath.row])cartouche"
        
        return cell
    }
}

extension MapViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width-64, height: collectionView.frame.size.height-16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 32.0, bottom: 16.0, right: 32.0)
    }
}

extension MapViewController: CLLocationManagerDelegate {

    func setupUserInterface() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func setupLocation() {
        // Ask user permissio nto use location
        self.locationManager.requestAlwaysAuthorization()
        
        // Tell locationManager that we receive the location updates
        self.locationManager.delegate = self
        
        // Mandatory to background modes
        self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.pausesLocationUpdatesAutomatically = true
        self.locationManager.activityType = .fitness
        
        //self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.desiredAccuracy = MapViewController.HIGH_REQUESTED_ACCURACY
        //self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        // @ start - Every 40 meters we receive a location update,
        // later if the speed increase put the distance filter to other value
        self.locationManager.distanceFilter = MapViewController.HIGH_DISTANCE_FILTER
        
        self.locationManager.startUpdatingLocation()
    }

    func checkUpdateType(_ currentLocation: CLLocation) -> (network: Bool,content: Bool) {
        var doHoopNetWorkUpdate = false
        var doHoopContentUpdate = false
        if let nOptLastLocation = lastLocation {
            print("Reasons for hoop update - ", nOptLastLocation.distance(from: currentLocation), (Timestamp - lastHoopNetworkTimestamp), (Timestamp - lastHoopsContentTimestamp), returnFromBackground)
            doHoopNetWorkUpdate = (((nOptLastLocation.distance(from: currentLocation) > 400.0) && ((Timestamp - self.lastHoopNetworkTimestamp) > 5000)) || returnFromBackground )
            doHoopContentUpdate = (((Timestamp - self.lastHoopsContentTimestamp) > 5000) || returnFromBackground)
        } else {
            print("Reasons for hoop update - no location")
            doHoopNetWorkUpdate = true
        }
        return (doHoopNetWorkUpdate, doHoopContentUpdate)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // Save location, if location not valid return immediately
        guard let location = locations.last else {
            return
        }
        
        currentLocation = location
        
        // Check speed is valid (>-1) && not gps drift (>1kmh) && nor to high (<20kmh)
        let currentSpeed = currentLocation.speed
        
        // If speed goes at more that 20 kmh do nothing
        if (currentSpeed > (20/3.6)){
            //PopupProvider.showInformPopup()
            self.removeCurrentHoopsArea()
            self.removeSelectedHoop()
        } else {
            if(currentLocation.horizontalAccuracy < 250) {
                // retrieve the running state of app
                let state = UIApplication.shared.applicationState
                
                if (state == .background) {
                    locationDidUpdateBackground(with: currentLocation.coordinate)
                } else {
                    let results = checkUpdateType(currentLocation)
                    if(results.network) {
                        locationDidUpdateForegroundNet(with: currentLocation.coordinate)
                    } else if(results.content) {
                        locationDidUpdateForegroundNoNet(with: currentLocation.coordinate)
                    }
                    returnFromBackground = false
                }
                // Tell server where we are
                
                
            }
        }
        
        // Adaptative distance filter according to current speed
        if(currentSpeed >= 0) {
            if(currentSpeed > (10/3.6)) {
                //print("set distance filter to 400, and accuracy to hundreds")
                self.locationManager.distanceFilter = MapViewController.LOW_DISTANCE_FILTER
                self.locationManager.desiredAccuracy = MapViewController.LOW_REQUESTED_ACCURACY
            } else {
                //print("set distance filter to 100, and accuracy to hundreds")
                self.locationManager.distanceFilter = MapViewController.HIGH_DISTANCE_FILTER
                self.locationManager.desiredAccuracy = MapViewController.HIGH_REQUESTED_ACCURACY
            }
        }
        
        //print(self.hm)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("==============")
        print(status)
        print("==============")
        switch(status) {
        case .restricted, .denied, .authorizedWhenInUse:
            showBadLocationPopup()
        default:
            print("ok then")
        }
    }

}

// Where all the popup messages are called
extension MapViewController {
    func showBadLocationPopup() {
        PopupProvider.showTwoChoicesPopup(icon: UIImage(named: "sadscreen"),
                                            title: "Hoop ne peux pas te présenter tous les profils qui t'entourent 😢",
                                            content: "Si la géolocalisation n'est pas \'Toujours\' active dans les réglages de l'application, tu ne profiteras pas de Hoop au maximum. Et ne t'inquiète pas nous avons bien bossé pour être gentil avec ta batterie. 😁",
                                            okTitle: "Activate",
                                            nokTitle: "Cancel",
                                            okClosure: {
                                                self.goToSettings()
                                            },
                                            nokClosure: {
                                                print("do nothing")
                                            })
    }
    
    func showNoHoopPopup() {
        PopupProvider.showTwoChoicesPopup(icon: UIImage(named: "sadscreen"),
                                          title: "Désolé",
                                          content: "Hoop est encore jeune et malheureusement ta zone n'est pas encore couverte par l'application, contacte la Team Hoop pour nous faire une demande :). Plus il y aura de demande dans ton secteur et plus il y a de chance que ça arrive vite ;)",
                                          okTitle: "ok",
                                          nokTitle: nil,
                                          okClosure: nil,
                                          nokClosure: nil)
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func setupMapKit() {
        self.mapView.showsPointsOfInterest = false
        self.mapView.showsCompass = false
        self.mapView.showsBuildings = false
        self.mapView.showsUserLocation = true
        self.mapView.delegate = self
        // Here We define the real content view of the map
        self.mapView.layoutMargins = UIEdgeInsets(top: 50, left: 0.0, bottom: 400.0, right: 0.0)
    }
    
    // Focus stuffs
    
    func focusOnHoop(withId id:Int) {
        // Spoof location for the moment
        let latitude: CLLocationDegrees = 4.2
        let longitude: CLLocationDegrees = 20.2
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        self.mapFocus(at: coordinates, withAnimation: true)
    }
    
    func focusOnUser(withAnimation animated: Bool) {
        self.mapFocus(at: self.mapView.userLocation.coordinate, withAnimation: animated)
    }
    
    func mapFocus(at coordinates: CLLocationCoordinate2D, withAnimation animated: Bool) {
        // Keeping parameters
        let keepHeading = self.mapView.camera.heading
        let keepPitch =  Double(self.mapView.camera.pitch)
        let keepAltitude = self.mapView.camera.altitude
        var keepDistance = keepAltitude/(sin((90-keepPitch)*Double.pi/180.0))
        if( keepDistance > 10000.0 ) {
            keepDistance = 10000
        }
        
        // Apply value
        let camera = MKMapCamera(lookingAtCenter: coordinates, fromDistance: keepDistance, pitch: 60.0, heading: keepHeading)
        self.mapView.setCamera(camera, animated: animated)
    }
    
    // Overlays
    
    func addCurrentHoopsArea(with circles: [Circle]) {
        currentHoopsAreaOverlay = CirclesOverlay(withiCircles: circles, color: .red)
        self.mapView.addOverlay(currentHoopsAreaOverlay!)
    }
    
    func removeCurrentHoopsArea() {
        if let hoopAreaOverlay = currentHoopsAreaOverlay {
            self.mapView.removeOverlay(hoopAreaOverlay)
            currentHoopsAreaOverlay = nil
        }
    }
    
    func addCurrentSelectedHoop() {
        if let selectedHoop = currentSelectedHoop {
            if let lat = selectedHoop.latitude, let lon = selectedHoop.longitude {
                let coordinates = CLLocationCoordinate2DMake(lat, lon)
                currentHoopSelectedOverlay = MKCircle(center: coordinates, radius: Double(selectedHoop.radius ?? 700))
                self.mapView.addOverlay(currentHoopSelectedOverlay!)
            }
        }
    }
    
    func removeSelectedHoop() {
        if let selectedHoopOverlay = currentHoopSelectedOverlay {
            self.mapView.removeOverlay(selectedHoopOverlay)
            currentHoopSelectedOverlay = nil
        }
    }
    
    func updateCurrentHoopArea() {
        // Remove the current circle overlay
        self.removeCurrentHoopsArea()
        self.removeSelectedHoop()
        // get the current active Stops
        var circles = [Circle]()
        for hoop in currentHoops {
            if let hoopRadius = hoop.radius {
                if let lat = hoop.latitude, let lon = hoop.longitude {
                    let coordinates = CLLocationCoordinate2DMake(lat, lon)
                    circles.append(Circle(center: coordinates, width: Double(hoopRadius*2), height: Double(hoopRadius*2)))
                }
            }
        }
        addCurrentHoopsArea(with: circles)
        addCurrentSelectedHoop()
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is CirclesOverlay {
            // Our nice au custom area
            return CirclesOverlayRenderer(withCircleOverlay: overlay as! CirclesOverlay)
        } else {
            // Basic circle
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.fillColor = UIColor.red.withAlphaComponent(0.2)
            return circleRenderer
        }
        
    }
    
}

// The calls to net stack
extension MapViewController {
    
    func computeCurrentHoops() {
        self.currentHoops = currentHoopNetwork.filter { hoop in
            if let id = hoop.id {
                return self.currentHoopIds.contains(id)
            } else {
                return false
            }
        }
    }
    
    func computeCurrentProfiles() -> [profile] {
        var exhaustiveCurrentProfiles = [profile]()
        // Create a list of current profiles which contains their actual hoop ids
        if let hoopContent = currentHoopsContent{
            for (hoopId,profiles) in hoopContent {
                if let strHoopId = Int(hoopId) {
                    for profile in profiles {
                        if let foundProfile = exhaustiveCurrentProfiles.first(where: {$0.id == profile.id}) {
                            // Profile exist in current profiles
                            if profile.activeInHoop == 1 {
                                foundProfile.current_active_hoop_ids.append(strHoopId)
                            } else {
                                foundProfile.current_inactive_hoop_ids.append(strHoopId)
                            }
                        } else {
                            // Profile does not exist so add it
                            if profile.activeInHoop == 1 {
                                profile.current_active_hoop_ids.append(strHoopId)
                            } else {
                                profile.current_inactive_hoop_ids.append(strHoopId)
                            }
                            exhaustiveCurrentProfiles.append(profile)
                        }
                    }
                }
            }
        }
        // Tell if the profile is active or inactive in the list
        exhaustiveCurrentProfiles.forEach({$0.current_displayed_status = $0.current_active_hoop_ids.count != 0 })
        // Sort them by active inactive
        exhaustiveCurrentProfiles.sort(by: { $0.current_displayed_status && !$1.current_displayed_status })
        // Return the list
        return exhaustiveCurrentProfiles
    }
    
    func updateDisplayableCurrentProfiles(_ newCurrentProfiles: [profile]) -> (toRemove: [Int], toAdd: [Int]) {
        var idsToRemove = [Int]()
        var idsToKeep = [Int]()
        var idsToAdd = [Int]()
        // Deal with the deletion
        for (index,profile) in currentProfiles.enumerated() {
            // the id is not in the new profile
            if let existingProfile = newCurrentProfiles.first(where: { $0.id == profile.id }) {
                // If the profile does exist in the newCurrentProfile
                if existingProfile.current_displayed_status != profile.current_displayed_status{
                    // If the profile changed in status remove it as well
                    idsToRemove.append(index)
                } else {
                    // Simpler to use
                    idsToKeep.append(index)
                }
            } else {
                // The profile does not exist in newCurrentProfile so we need a deletion
                idsToRemove.append(index)
            }
        }
        // Do the deletion
        let idsToKeepIndexSet = IndexSet(idsToKeep)
        // Make a temporary (don't know if its necessary)
        let intermediateCurrentProfiles = idsToKeepIndexSet.map { currentProfiles[$0] }
        // Replace the currentProfile
        currentProfiles = intermediateCurrentProfiles
        // Do the model update
        // Deal with the appending
        for profile in newCurrentProfiles {
            // je cherche le profil dans les currentActive
            if let existing = currentProfiles.first(where: {$0.id == profile.id}) {
                if existing.current_displayed_status {
                    // Je vérifie si l'id de l'existant fait partie des actifs
                    if !profile.current_active_hoop_ids.contains(where: {$0 == existing.current_hoop_id}){
                        // Si non je recherche
                        if let randHoopId = profile.current_active_hoop_ids.randomElement() {
                            profile.current_hoop_id = randHoopId
                        }
                    }
                } else {
                    // Je vérifie si l'id de l'existant fait partie des inactifs
                    if !profile.current_inactive_hoop_ids.contains(where: {$0 == existing.current_hoop_id}){
                        // Si non je recherche
                        if let randHoopId = profile.current_inactive_hoop_ids.randomElement() {
                            profile.current_hoop_id = randHoopId
                        }
                    }
                }
            } else {
                // le profile n'est pas dans la liste de profile
                // Compute where to insert the profile
                var indexToInsert = 0
                if profile.current_displayed_status {
                    if currentProfiles.count != 0 {
                        if let foundIndex = currentProfiles.firstIndex(where: { !$0.current_displayed_status }) {
                            // if we found a transition from active to inactive
                            indexToInsert = foundIndex
                        } else {
                            // Otherwise it the end of the list
                            indexToInsert = currentProfiles.count
                        }
                    }
                } else {
                    indexToInsert = currentProfiles.count
                }
                idsToAdd.append(indexToInsert)
                currentProfiles.insert(profile, at: indexToInsert)
                if profile.current_displayed_status {
                    if let randHoopId = profile.current_active_hoop_ids.randomElement() {
                        profile.current_hoop_id = randHoopId
                    }
                } else {
                    if let randHoopId = profile.current_inactive_hoop_ids.randomElement() {
                        profile.current_hoop_id = randHoopId
                    }
                }
            }
        }
        return (idsToRemove,idsToAdd)
    }
    
    func locationDidUpdateBackground(with coordinate:CLLocationCoordinate2D) {
        let promise = HoopNetworkApi.sharedInstance.getHoopIn(byLatLong: coordinate)
        promise.whenFulfilled { _ in }
    }
    
    func locationDidUpdateForegroundNet(with coordinate:CLLocationCoordinate2D) {
        self.lastHoopNetworkTimestamp = Timestamp
        self.lastHoopsContentTimestamp = Timestamp
        
        let promise = HoopNetworkApi.sharedInstance.getHoopIn(byLatLong: coordinate)
        
        promise.then { ids -> Future<[hoop]> in
            self.currentHoopIds = ids
            return HoopNetworkApi.sharedInstance.getHoopInfo(byLatLong: coordinate)
        }.then { hoops -> Future<[String:[profile]]> in
            self.currentHoopNetwork = hoops
            self.computeCurrentHoops()
            self.updateCurrentHoopArea()
            self.focusOnUser(withAnimation: true)
            return HoopNetworkApi.sharedInstance.getHoopContent(withIds: self.currentHoopIds)
        }.whenFulfilled(on: .main) { content in
            print("got content")
            print("content")
            self.currentHoopsContent = content
            var exhaustiveCurrentProfiles = self.computeCurrentProfiles()
            let ids = self.updateDisplayableCurrentProfiles(exhaustiveCurrentProfiles)
            print(ids)
            print(self.currentProfiles.map({ "#\($0.id!) \($0.name!) \($0.current_displayed_status!)"}))
            // Choose one
        }
        
        promise.whenRejected(on: .main) { error in
            // remove loading indicator
            print("got error")
            print(error)
            switch (error as NSError).code {
            case HoopNetworkApi.API_ERROR_NO_IDS:
                self.locationManager.stopUpdatingLocation()
                self.showNoHoopPopup()
            default:
                break
            }
        }
    }
    
    func locationDidUpdateForegroundNoNet(with coordinate:CLLocationCoordinate2D) {
        self.lastHoopsContentTimestamp = Timestamp
        
        let promise = HoopNetworkApi.sharedInstance.getHoopIn(byLatLong: coordinate)
        
        promise.then { ids -> Future<[String:[profile]]> in
            self.currentHoopIds = ids
            return HoopNetworkApi.sharedInstance.getHoopContent(withIds: self.currentHoopIds)
        }.whenFulfilled(on: .main) { content in
            print("got content")
            print("content")
            self.computeCurrentHoops()
            self.updateCurrentHoopArea()
            self.focusOnUser(withAnimation: true)
        }
        
        promise.whenRejected(on: .main) { error in
            // remove loading indicator
            print("got error")
            print(error)
            switch (error as NSError).code {
            case HoopNetworkApi.API_ERROR_NO_IDS:
                self.locationManager.stopUpdatingLocation()
                self.showNoHoopPopup()
            default:
                break
            }
        }
    }
}
