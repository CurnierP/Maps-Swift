//
//  ShowDetailViewController.swift
//  TD5-DAM-Curnier-Martin
//
//  Created by CURNIER Pierre on 27/02/2017.
//  Copyright © 2017 CURNIER Pierre. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class ShowDetailViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate{

    let locationManager = CLLocationManager()
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var maps: MKMapView!
    
    var imagePassed: String = ""
    var titre: String = ""
    var coordLatitude: Double = 0.0
    var coordLongitude: Double =  0.0
    var telephoneNumber: String = ""
    
    var positionUser = MKPointAnnotation()
    
    var myRoute : MKRoute!

    
   override func viewDidLoad() {
        super.viewDidLoad()
   
        locationManager.delegate = self
        self.navigationItem.title = titre
    
    
        // Do any additional setup after loading the view pour afficher l'image
        if let checkedUrl = URL(string: imagePassed) {
            image.contentMode = .scaleAspectFit
            downloadImage(url: checkedUrl)
        }
    
    //Position utilisateur
    self.locationManager.requestAlwaysAuthorization()
    self.locationManager.requestWhenInUseAuthorization()
    
    if CLLocationManager.locationServicesEnabled(){
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        
    }
    
    
    //placement des 2 pin sur la maps
    let destination = MKPointAnnotation()
   
    var locValue: CLLocationCoordinate2D = (locationManager.location?.coordinate)!
    
    positionUser.coordinate = CLLocationCoordinate2DMake(locValue.latitude, locValue.longitude)
    maps.addAnnotation(positionUser)
    
    destination.coordinate = CLLocationCoordinate2D(latitude: coordLatitude, longitude: coordLongitude)
    maps.addAnnotation(destination)
    maps.delegate = self
    
    //zoom de la maps
    maps.setRegion(MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: 43.551534, longitude: 7.016659), CLLocationDistance(5000), CLLocationDistance(5000)), animated: true)
    
    let directionsRequest = MKDirectionsRequest()
    let markTaipei = MKPlacemark(coordinate: CLLocationCoordinate2DMake(positionUser.coordinate.latitude, positionUser.coordinate.longitude), addressDictionary: nil)
    let markChungli = MKPlacemark(coordinate: CLLocationCoordinate2DMake(destination.coordinate.latitude, destination.coordinate.longitude), addressDictionary: nil)
    
    directionsRequest.source = MKMapItem(placemark: markChungli)
    directionsRequest.destination = MKMapItem(placemark: markTaipei)
    
    directionsRequest.transportType = MKDirectionsTransportType.automobile
    let directions = MKDirections(request: directionsRequest)
    
    directions.calculate(completionHandler: {
        response, error in
        
        if error == nil {
            self.myRoute = response!.routes[0] as MKRoute
            self.maps.add(self.myRoute.polyline)
        }
        
    })
    
    
   }
    
    //Fonction pour afficher l'itineaire en bleu sur la maps
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let myLineRenderer = MKPolylineRenderer(polyline: myRoute.polyline)
        myLineRenderer.strokeColor = UIColor.blue
        myLineRenderer.lineWidth = 3
        return myLineRenderer
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Focntion pour la pos de l'utilisateur
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        
        var locValue: CLLocationCoordinate2D = (manager.location?.coordinate)!
        
        
        positionUser.coordinate = CLLocationCoordinate2DMake(locValue.latitude, locValue.longitude)
        positionUser.title = "Vous êtes ici"
        maps.addAnnotation(positionUser)
        locationManager.stopUpdatingLocation()
    }
    
    
    //Affichage de l'image
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
    func downloadImage(url: URL) {
        print("Download Started")
        getDataFromUrl(url: url) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() { () -> Void in
                self.image.image = UIImage(data: data)
            }
        }
    }
    
    //fonction pour passer l'appel
    @IBAction func Call(_ sender: Any) {
       
        let phone = telephoneNumber.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
        let telPhone = phone.replacingOccurrences(of: "+33(0)", with: "0")
        
        if let url = URL(string: "telprompt://\(telPhone)"){
            
             UIApplication.shared.open(url, options: [:], completionHandler: nil)
            print("Appel en cours")
     
        }
    }
    
    //Bouton pour ouvrir la maps
    @IBAction func openMaps(_ sender: Any) {
        

         openMapForPlace()

       }

    //On cree une fonction pour afficher l'appli maps
    func openMapForPlace() {
        
        //Position utilisateur
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            
        }
        
        //destination
        var destination = CLLocationCoordinate2D(latitude: coordLatitude, longitude: coordLongitude)
        
        
        let latitude: CLLocationDegrees = destination.latitude
        let longitude: CLLocationDegrees = destination.longitude
        
        let regionDistance:CLLocationDistance = 5000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        
        
        var selectedPoi = MKPointAnnotation()
        
        //Placement du poi de destination
        selectedPoi.coordinate = CLLocationCoordinate2D(latitude: coordLatitude, longitude: coordLongitude)
        maps.addAnnotation(selectedPoi)
        
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = titre
        
        //Ouverture de l'appli Maps
        mapItem.openInMaps(launchOptions: options)
    }
    
    
    //Partage de la maps
    @IBAction func Share(_ sender: Any) {
        
        let imageToShare = UIImageView();
        
        if let data = try? Data(contentsOf: NSURL(string: imagePassed) as! URL) {
            imageToShare.alpha = 0
            
            UIView.transition(with: image, duration: 0.5, options: UIViewAnimationOptions(), animations: { () -> Void in
                imageToShare.image = UIImage(data: data)
                imageToShare.alpha = 1
            }, completion: { (ended) -> Void in
                
            })
        }
        let imageShared = imageToShare.image
        let textToShare = "Voici une petite image: \(titre) qui se trouve à Cannes"
       
        let activity:UIActivityViewController  =  UIActivityViewController(activityItems: [(imageShared),textToShare], applicationActivities: nil)
        self.present(activity, animated: true, completion: nil)
   
    }
   
 
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
