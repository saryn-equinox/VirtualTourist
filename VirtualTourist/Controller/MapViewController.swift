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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Create an instance of gesture recognizer
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(gestureRecognizer:)))
        tapGestureRecognizer.delegate = self
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        mapSetting()
        VTClient.Auth.authorize() // Doesn't work
    }
    
    @objc func handleTap(gestureRecognizer: UITapGestureRecognizer) {
        let location = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        
        // Add annotation:
        if getPinAt(lon: coordinate.longitude, lat: coordinate.latitude)?.count == 0 {
            addPin(lat: coordinate.latitude, lon: coordinate.longitude)
            print("New Pin added")
        } else {
            print("Pin already existed")
        }
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
        
        loadPins()
    }
    
    /**
     Load pins store in the coredata
     */
    func loadPins() {
        let fetechRequest: NSFetchRequest<Location> = Location.fetchRequest()
        do {
            let results = try AppData.dataController.viewContext.fetch(fetechRequest)
            for pin in results {
                let newPin = MKPointAnnotation()
                newPin.coordinate = CLLocationCoordinate2D(latitude: pin.lat, longitude: pin.lon)
                mapView.addAnnotation(newPin)
            }
        } catch {
            print("Fetch error: \(error)")
        }
    }
    
    /**
     Add new pin to the coredata
     */
    func addPin(lat: Double, lon: Double) {
        let pin = Location(context: AppData.dataController.viewContext)
        pin.lat = lat
        pin.lon = lon
        try? AppData.dataController.viewContext.save()
        let annotaion = MKPointAnnotation()
        annotaion.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        mapView.addAnnotation(annotaion)
    }
    
    func getPinAt(lon: Double, lat: Double) -> [Location]? {
        let fetechRequest: NSFetchRequest<Location> = Location.fetchRequest()
        let latPredicate = NSPredicate(format: "lat == %@", lat)
        let lonPredicate = NSPredicate(format: "lon == %@", lon)
        fetechRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [latPredicate, lonPredicate])
        do {
            let results = try AppData.dataController.viewContext.fetch(fetechRequest)
            print(results.count)
            return results
        } catch {
            print("Fetch error: \(error)")
        }
        return nil
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
        // get the pinLocation
        let pin = getPinAt(lon: view.annotation!.coordinate.longitude, lat: view.annotation!.coordinate.latitude)
        // download image in the background
        VTClient.searchForPhotoes(lat: (view.annotation?.coordinate.latitude)! as Double, lon: (view.annotation?.coordinate.longitude)! as Double)
//        self.navigationController?.show(detailVC, sender: self)
    }
}
