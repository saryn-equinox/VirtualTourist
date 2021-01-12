//
//  DetailViewController.swift
//  VirtualTourist
//
//  Created by 邱浩庭 on 7/1/2021.
//

import UIKit
import MapKit
import CoreData

class DetailViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var imageCollection: UICollectionView!
    @IBOutlet weak var newCollection: UIButton!
    
    var visibleRegion: MKMapRect!
    var pinLoctaion: Location!
    var newCollectionButtonEnabled: Bool = true

    var images: [Image]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.title = "Virtual Tourist"
        mapView.setVisibleMapRect(visibleRegion, animated: false)
        mapView.centerCoordinate = CLLocationCoordinate2D(latitude: pinLoctaion.lat, longitude: pinLoctaion.lon)
        let pin = MKPointAnnotation()
        pin.coordinate = mapView.centerCoordinate
        mapView.addAnnotation(pin)
        mapView.delegate = self
        imageCollection.delegate = self
        imageCollection.dataSource = self
        newCollection.isEnabled = newCollectionButtonEnabled
        NotificationCenter.default.addObserver(self, selector: #selector(reloadPhotoInfo), name: .didReceivePhotoInfoUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(finishedDownload), name: .didFinishedDownload, object: nil)
        reloadPhotoInfo()
    }
    
    @IBAction func newCollectionTapped(_ sender: Any) {
        newCollection.isEnabled = false
        deleteImages(pin: self.pinLoctaion)
        VTClient.searchForPhotoes(pin: self.pinLoctaion)
    }
    
    @objc func reloadPhotoInfo() {
        getImages()
        imageCollection.reloadData()
    }
    
    @objc func finishedDownload() {
        newCollection.isEnabled = true
    }
    
    func getImages(){
        let fetechRequest: NSFetchRequest<Image> = Image.fetchRequest()
        let predicate = NSPredicate(format: "locBelonging == %@", self.pinLoctaion)
        fetechRequest.predicate = predicate
        let results = try! AppData.dataController.viewContext.fetch(fetechRequest)
        self.images = results
    }
    
    func deleteImages(pin: Location) {
        let fetechRequest: NSFetchRequest<NSFetchRequestResult> = Image.fetchRequest()
        let predicate = NSPredicate(format: "locBelonging == %@", pin)
        fetechRequest.predicate = predicate
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetechRequest)
        do {
            try AppData.dataController.persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: AppData.dataController.viewContext)
            pinLoctaion.imagesCount = Int64(0)
            try AppData.dataController.viewContext.save()
        } catch let error as NSError {
            print("Fail to execute delete batch request \(error.localizedDescription)")
        }
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
        return Int(pinLoctaion.imagesCount)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCollectionViewCell
        cell.imageView.contentMode = .scaleAspectFill
        getImages()
        if (images?.count ?? 0) > indexPath.row {
            cell.imageView.image = UIImage(data: (images![indexPath.row]).image!)
            cell.image = images![indexPath.row]
        } else {
            cell.imageView.image = UIImage(named: "VirtualTourist_76")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Delete the item
        let cell = collectionView.cellForItem(at: indexPath) as! ImageCollectionViewCell
        collectionView.deleteItems(at: [indexPath])
        cell.image.locBelonging?.imagesCount -= 1
        AppData.dataController.viewContext.delete(cell.image)
        try! AppData.dataController.viewContext.save()
    }
}
