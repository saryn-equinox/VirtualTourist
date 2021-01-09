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
        mapView.setVisibleMapRect(visibleRegion, animated: false)
        mapView.centerCoordinate = pin.coordinate
        mapView.addAnnotation(pin)
        mapView.delegate = self
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
