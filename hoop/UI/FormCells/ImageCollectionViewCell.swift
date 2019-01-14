//
//  Customs.swift
//  formTests
//
//  Created by Clément on 13/12/2018.
//  Copyright © 2018 hoop. All rights reserved.
//

import Foundation
import Eureka

// Coded in nib
class PickerCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var actionButton: UIButton!
}

// Coded here
class DisplayCell: UICollectionViewCell {
    
    var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = false
        contentView.addSubview(imageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var frame = imageView.frame
        frame.size.height = self.frame.size.height
        frame.size.width = self.frame.size.width
        frame.origin.x = 0
        frame.origin.y = 0
        imageView.frame = frame
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class ImageCollectionViewCell: Cell<[UIImage]>, CellType, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var displayCollectionView: UICollectionView!
    @IBOutlet weak var pickerCollectionView: UICollectionView!
    @IBOutlet weak var displayPageControl: UIPageControl!
    
    fileprivate var longPressGesture: UILongPressGestureRecognizer!
    
    let DISPLAY_CV: Int = 1
    let PICKER_CV: Int = 2
    
    public override func setup() {
        super.setup()
        
        // set the page control
        if let imgs = (row as! ImageCollectionViewRow).value {
            displayPageControl.numberOfPages = imgs.count
        } else {
            displayPageControl.numberOfPages = 0
        }

        // configure display part of cell
        displayCollectionView.register(DisplayCell.self, forCellWithReuseIdentifier: "displayCell")
        displayCollectionView.tag = DISPLAY_CV
        displayCollectionView.dataSource = self
        displayCollectionView.delegate = self
        
        // configure picker part of cell
        pickerCollectionView.register(UINib(nibName: "PickerCell", bundle: nil), forCellWithReuseIdentifier: "pickerCell")
        pickerCollectionView.tag = PICKER_CV
        pickerCollectionView.dataSource = self
        pickerCollectionView.delegate = self
        
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(ImageCollectionViewCell.handleLongGesture(_:)))
        pickerCollectionView.addGestureRecognizer(longPressGesture)
    }

    public override func update() {
        super.update()
    }
    
    // =============== datasource ===================
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == DISPLAY_CV {
            if let img = (row as! ImageCollectionViewRow).value {
                return img.count
            } else {
                return 0
            }
        } else {
            return 5
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == DISPLAY_CV {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "displayCell", for: indexPath) as! DisplayCell
            cell.imageView.image = (row as! ImageCollectionViewRow).value?[indexPath.row]
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pickerCell", for: indexPath) as! PickerCell
            
            if let count = (row as! ImageCollectionViewRow).value?.count {
                if indexPath.row < count {
                    cell.imageView.image = (row as! ImageCollectionViewRow).value?[indexPath.row]
                    cell.actionButton.backgroundColor = UIColor.red
                } else {
                    cell.imageView.image = nil
                    cell.actionButton.backgroundColor = UIColor.green
                }
                // set call back
                cell.actionButton.tag = indexPath.row
                cell.actionButton.addTarget(self, action: #selector(actionTouched(_:)), for: .touchUpInside)
            }

            return cell
        }
    }
    
    // =============== layout ===================
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView.tag == DISPLAY_CV {
            return collectionView.frame.size
        } else {
            let width = collectionView.frame.size.width/5.0
            return CGSize(width: width, height: width)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    // =============== delegate ===================
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == PICKER_CV {
            if let count = (row as! ImageCollectionViewRow).value?.count {
                if indexPath.row < count {
                    self.displayCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
                    displayPageControl.currentPage = indexPath.row
                } else {
                    print("adding new image")
                }
            }
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.tag == DISPLAY_CV {
            let pageIndex = round((scrollView.contentOffset.x) / (scrollView.frame.size.width))
            displayPageControl.currentPage = Int(pageIndex)
        }
    }
    
    // =============== reorder ===================
    
    @objc func handleLongGesture(_ gesture: UILongPressGestureRecognizer) {

        switch(gesture.state) {
            
        case UIGestureRecognizer.State.began:
            guard let selectedIndexPath = pickerCollectionView.indexPathForItem(at: gesture.location(in: pickerCollectionView)) else {
                break
            }
            pickerCollectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
            print("start \(selectedIndexPath)")
            break
        case UIGestureRecognizer.State.changed:
            pickerCollectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
            print("changed")
            break
        case UIGestureRecognizer.State.ended:
            pickerCollectionView.endInteractiveMovement()
            print("end")
            break
        default:
            pickerCollectionView.cancelInteractiveMovement()
            print("cancel")
            break
        }
    }
    
    // Theses are never called
    public func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        print("Start index :- \(sourceIndexPath.item)")
        print("End index :- \(destinationIndexPath.item)")
    }
    
    // =============== custom target ===================

    @objc public func actionTouched(_ control:UIButton) {
        if let count = (row as! ImageCollectionViewRow).value?.count {
            if control.tag < count {
                print("delete \(control.tag)")
                deleteImage(at: control.tag)
            } else {
                print("add new images")
                (row as! ImageCollectionViewRow).showPictureSourceDialog(self)
            }
        }
    }
    
    // =============== Image actions ===================
    
    public func deleteImage(at index: Int) {
        if let imgs = (row as! ImageCollectionViewRow).value {
            if index < imgs.count {
                (row as! ImageCollectionViewRow).value?.remove(at: index)
                // TODO: handle empty arrays?
                pickerCollectionView.reloadData()
                displayCollectionView.reloadData()
                // TODO: Do a nice reselection?
                displayPageControl.currentPage = 0
                displayPageControl.numberOfPages -= 1
            }
        }
    }
    
    public func appendImage(image: UIImage) {
        if let _ = (row as! ImageCollectionViewRow).value {
            (row as! ImageCollectionViewRow).value?.append(image)
            // TODO: handle empty arrays?
            pickerCollectionView.reloadData()
            displayCollectionView.reloadData()
            // TODO: Do a nice reselection?
            displayPageControl.currentPage = 0
            displayPageControl.numberOfPages += 1
        }
    }
    
    // ============ PICKER
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //print(info)
        if var pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            // If the edited version exists pick it
            if let pickedEditedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                pickedImage = pickedEditedImage
            }
            // print(info)
            //let fixedImage = pickedImage.fixedOrientation()
            print(pickedImage.size)
            var ratio = 1500 / max(pickedImage.size.width,pickedImage.size.height)
            print(ratio)
            if (ratio > 1.0) {
                ratio = 1.0
            }
            let resizedImage = ImageManipulator.imageWithImage(pickedImage,withScale: ratio)!
            // Add the image to the datasource
            appendImage(image: resizedImage)
            // Dismiss the picker
            (row as! ImageCollectionViewRow).delegate?.dismissViewController()
        }
    }
    
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        dismiss(animated: true, completion: nil)
//    }
}

// The custom Row also has the cell: CustomCell and its correspond value
public final class ImageCollectionViewRow: Row<ImageCollectionViewCell>, RowType {
    
    var delegate: DisplayPictureSourceProtocol?
    
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<ImageCollectionViewCell>(nibName: "CollectionViewCell")
    }
}

public protocol DisplayPictureSourceProtocol {
    func showViewController(_ vc: UIViewController)
    func dismissViewController()
}

extension ImageCollectionViewRow {
    
    func showPictureSourceDialog(_ pickerDelegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate)) {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = pickerDelegate
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Annuler", style: .cancel)
        alertController.addAction(cancelAction)
        
        let LibrairieAction = UIAlertAction(title: "Choisir une photo", style: .`default`) { action in
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .photoLibrary
            self.delegate?.showViewController(imagePicker)
        }
        alertController.addAction(LibrairieAction)
        
        let CameraAction = UIAlertAction(title: "Prendre une photo", style: .`default`) { action in
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .camera
            imagePicker.cameraDevice = .front
            self.delegate?.showViewController(imagePicker)
        }
        alertController.addAction(CameraAction)
        
        delegate?.showViewController(alertController)
    }
}
