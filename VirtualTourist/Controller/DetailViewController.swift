//
//  DetailViewController.swift
//  VirtualTourist
//
//  Created by 邱浩庭 on 7/1/2021.
//

import UIKit
import MapKit

class DetailViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var imageCollection: UICollectionView!
        
    var visibleRegion: MKMapRect!
    var pin: MKAnnotation!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.title = "Virtual Tourist"
        mapView.setVisibleMapRect(visibleRegion, animated: false)
        mapView.centerCoordinate = pin.coordinate
        mapView.addAnnotation(pin)
        mapView.delegate = self
        imageCollection.delegate = self
        imageCollection.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(reloadPhotoInfo), name: .didReceivePhotoInfoUpdate, object: nil)
    }
    
    @IBAction func newCollectionTapped(_ sender: Any) {
        VTClient.searchForPhotoes(lat: pin.coordinate.latitude as Double, lon: pin.coordinate.longitude as Double)
    }
    
    @objc func reloadPhotoInfo() {
        imageCollection.reloadData()
    }
}

extension DetailViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.isDraggable = false
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }
}

extension DetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return AppData.photos?.photos.photo.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCollectionViewCell
        cell.imageView.contentMode = .scaleAspectFill
        if AppData.images.count > indexPath.row {
            cell.imageView.image = AppData.images[indexPath.row]
//            cell.photoInfo = AppData.
        } else {
            cell.imageView.image = UIImage(named: "VirtualTourist_76")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Delete the item
        print(indexPath.row)
    }
}
