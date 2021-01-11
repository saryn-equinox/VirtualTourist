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
    
    var tapGestureRecognizer: UILongPressGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Create an instance of gesture recognizer
        tapGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleTap(gestureRecognizer:)))
        tapGestureRecognizer.delegate = self
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        mapSetting()
        VTClient.Auth.authorize() // Doesn't work
    }
    
    @objc func handleTap(gestureRecognizer: UILongPressGestureRecognizer) {
        let location = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        
        // Add annotation:
        let pins = getPinAt(lon: coordinate.longitude, lat: coordinate.latitude)
        
        if (pins == nil) || (pins?.count == 0) {
            addPin(lat: coordinate.latitude, lon: coordinate.longitude)
        } else {
            print("Pin already existed --- \(pins?.count)")
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
                print(pin.lat)
                print(pin.lon)
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
    
    /**
     Get pin(s) at specific location
     */
    func getPinAt(lon: Double, lat: Double) -> [Location]? {
        let fetechRequest: NSFetchRequest<Location> = Location.fetchRequest()
        let latPredicate = NSPredicate(format: "lat == %lf", lat)
        let lonPredicate = NSPredicate(format: "lon == %lf", lon)
        fetechRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [latPredicate, lonPredicate])
        do {
            let results = try AppData.dataController.viewContext.fetch(fetechRequest)
            return results
        } catch {
            print("Fetch error: \(error)")
        }
        return nil
    }
    
    
    func deleteImages(pin: Location) {
        let fetechRequest: NSFetchRequest<NSFetchRequestResult> = Image.fetchRequest()
        let predicate = NSPredicate(format: "Location == %@", pin)
        fetechRequest.predicate = predicate
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetechRequest)
        do {
            try AppData.dataController.persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: AppData.dataController.viewContext)
        } catch let error as NSError {
            print("Fail to execute delete batch request \(error.localizedDescription)")
        }
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
        var pinToUpdate: [Location]?
        if oldState == MKAnnotationView.DragState.starting {
            let oldLat = view.annotation!.coordinate.latitude
            let oldLon = view.annotation!.coordinate.longitude
            print("-------")
            print(oldLat)
            print(oldLon)
            pinToUpdate = getPinAt(lon: oldLon, lat: oldLat)
        }
        if newState == MKAnnotationView.DragState.ending {
            let newLat = view.annotation!.coordinate.latitude
            let newLon = view.annotation!.coordinate.longitude
            if let pinToUpdate = pinToUpdate {
                for pin in pinToUpdate {
                    deleteImages(pin: pin)
                    pin.setValue(newLat, forKey: "lat")
                    pin.setValue(newLon, forKey: "lon")
                    try? AppData.dataController.viewContext.save()
                }
            }
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
//        detailVC.pinLoctaion = pin![0]
        // download image in the background
//        VTClient.searchForPhotoes(lat: (view.annotation?.coordinate.latitude)! as Double, lon: (view.annotation?.coordinate.longitude)! as Double)
//        self.navigationController?.show(detailVC, sender: self)
    }
}
