//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by 邱浩庭 on 7/1/2021.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var tapGestureRecognizer: UITapGestureRecognizer!
    var annotaions: Array<CLLocationCoordinate2D> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Create an instance of gesture recognizer
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(gestureRecognizer:)))
        tapGestureRecognizer.delegate = self
        mapSetting()
        VTClient.Auth.authorize()
    }
    
    @objc func handleTap(gestureRecognizer: UITapGestureRecognizer) {
        let location = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        
        // Add annotation:
        // Set doesn't work correctly
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        if !annotaions.contains(coordinate) {
            mapView.addAnnotation(annotation)
            annotaions.append(coordinate)
//            print("New pin added")
        }
        
        // Download images for associate with this location
        // https://www.flickr.com/services/api/flickr.photos.geo.photosForLocation.html
        
    }
    
    // Setting the map paramters
    private func mapSetting() {
        mapView.addGestureRecognizer(tapGestureRecognizer)
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.showsScale = true
        mapView.delegate = self
        var latitudeDelta = mapView.region.span.latitudeDelta
        var longitudeDelta = mapView.region.span.longitudeDelta
        var centerLoc = mapView.region.center
        
        if UserDefaults.standard.bool(forKey: "centerLoc") {
            centerLoc = CLLocationCoordinate2D(dict: UserDefaults.standard.value(forKey: "centerLoc") as! CLLocationCoordinate2D.CLLocationDictionary)
            mapView.region.center = centerLoc
        }
        
        if UserDefaults.standard.bool(forKey: "longitudeDelta") {
            longitudeDelta = UserDefaults.standard.value(forKey: "longitudeDelta") as! CLLocationDegrees
        }
        
        if UserDefaults.standard.bool(forKey: "latitudeDelta") {
            latitudeDelta = UserDefaults.standard.value(forKey: "latitudeDelta") as! CLLocationDegrees
        }
        
        mapView.setRegion(MKCoordinateRegion(center: centerLoc, span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)), animated: true)
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // update the map settings
        UserDefaults.standard.setValue(mapView.region.center.asDictionary, forKey: "centerLoc")
        UserDefaults.standard.setValue(mapView.region.span.latitudeDelta, forKey: "latitudeDelta")
        UserDefaults.standard.setValue(mapView.region.span.longitudeDelta, forKey: "longitudeDelta")
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        if newState == MKAnnotationView.DragState.ending {
//            print(view.annotation?.coordinate.asDictionary)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.isDraggable = true
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let detailVC = self.storyboard?.instantiateViewController(identifier: "detailViewController") as! DetailViewController
        detailVC.visibleRegion = mapView.visibleMapRect
        detailVC.pin = view.annotation
        self.navigationController?.show(detailVC, sender: self)
    }
}
