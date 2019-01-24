//
//  ProfileViewController.swift
//  uxTests
//
//  Created by Clément on 12/12/2018.
//  Copyright © 2018 hoop. All rights reserved.
//

import UIKit
import Hero

class ProfileViewController: UIViewController {

    @IBOutlet weak var profileScrollView: UIScrollView!
    @IBOutlet weak var hoopBackground: UIView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profilepicturePager: UIPageControl!
    @IBOutlet weak var profileDescription: UITextView!
    @IBOutlet weak var etHoopButton: UIButton!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var profilePictureCollectionView: UICollectionView!
    
    
    @objc var profileId: String!
    
    var profile: profile!
    
    var panGR: UIPanGestureRecognizer!
    
    var pm: profileManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGeneralUI()
        
        pm = profileManager.get()
        if pm == nil {
            pm = profileManager()
            pm.save()
        }
        
        if let profile = pm.getProfile(with: Int(profileId)!) {
            setupProfileUI(with: profile)
        } else {
            HoopNetworkApi.sharedInstance.getHoopProfile(with: Int(profileId)!).whenFulfilled(on: .main) { profile in
                self.pm.update(withProfile: profile)
                self.pm.save()
                self.setupProfileUI(with: profile)
                self.profilePictureCollectionView.reloadData()
            }
        }
        
        
    }
    
    func setupGeneralUI() {
        etHoopButton.setTitle("Bonjour", for: .normal)
        dismissButton.setTitle("X", for: .normal)
        dismissButton.hero.modifiers = [.fade, .translate(x:+100, y:0)]
        profileScrollView.contentInset.bottom = 100.0
    }
    
    func setupProfileUI(with profile: profile) {
        self.profile = profile
        
        if let fullTitle = self.profile.fullTitle {
            profilePictureCollectionView.hero.id = fullTitle
            profileName.text = fullTitle
        } else if self.profile.id == 1 {
            profilePictureCollectionView.hero.id = "th"
            profileName.text = "Team Hoop"
        }
        
        if var description = self.profile.description {
            if description.contains("&*/<>/*&") {
                let descriptionArray = description.components(separatedBy: "&*/<>/*&")
                if let me = AppDelegate.me {
                    description = descriptionArray[(me.gender == 1) ? 0 : 1]
                }
            }
            profileDescription.text = description
        }  else {
            profileDescription.text = "pas de description"
        }
        
        profilepicturePager.numberOfPages = self.profile.pictures_urls.count
        profilepicturePager.currentPage = 0
    }
    
    @IBAction func dismissView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ProfileViewController {
    @objc func handlePan(gestureRecognizer:UIPanGestureRecognizer) {
        switch panGR.state {
        case .began:
            // begin the transition as normal
            dismiss(animated: true, completion: nil)
        default:
            break
        }
    }
}


extension ProfileViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let profile = self.profile {
            return profile.pictures_urls.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Retrieve the object composing the cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "profilePictureIdent", for: indexPath)
        
        let profilImage = cell.viewWithTag(2) as! UIImageView
        
        let srcUrl = self.profile.pictures_urls[indexPath.row]
        profilImage.af_setImage(withURL: srcUrl)

        // Here try the localization stuffs
        
        return cell
    }
}

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
}

extension ProfileViewController: UICollectionViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        print(scrollView.contentOffset)
        print(targetContentOffset)
    }
}

// Put in another file

extension UIView {
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue.cgColor
        }
    }
}

