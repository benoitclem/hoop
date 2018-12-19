//
//  MapViewController.swift
//  hoop
//
//  Created by Clément on 19/12/2018.
//  Copyright © 2018 hoop. All rights reserved.
//

import UIKit
import MapKit
import Hero

class MapViewController: UIViewController {
    
    @IBOutlet weak var hoopBackground: UIView!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var profiles: UICollectionView!
    @IBOutlet weak var etHoopButton: UIButton!
    
    let profilePictures: [String] = ["aicha","iris","paula","clement","rachel","samie","sophie"]
    
    var selectedProfile: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //        if segue.identifier == "toProfile" {
    //            let profileView = segue.destination as! ProfileViewController
    //            profileView.imageheroId = selectedProfile
    //        }
    //        // Get the new view controller using segue.destination.
    //        // Pass the selected object to the new view controller.
    //    }
    
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
        let profilCartouche = cell.viewWithTag(3)!
        
        // Here try the localization stuffs
        profilName.text = "\(profilePictures[indexPath.row]) 27"
        profilImage.image = UIImage(imageLiteralResourceName: profilePictures[indexPath.row])
        profilImage.hero.id = profilePictures[indexPath.row]
        profilCartouche.hero.id = "\(profilePictures[indexPath.row])cartouche"
        
        return cell
    }
}

extension MapViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width-64, height: collectionView.frame.size.height-32)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16.0, left: 32.0, bottom: 16.0, right: 32.0)
    }
}


