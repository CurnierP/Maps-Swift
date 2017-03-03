//
//  MapViewController.swift
//  TD5-DAM-Curnier-Martin
//
//  Created by CURNIER Pierre on 20/02/2017.
//  Copyright © 2017 CURNIER Pierre. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class PoiMarker: NSObject, MKAnnotation {
    
    var id: String
    var title: String?
    var subtitle: String?
    var image: String
    var coordinate: CLLocationCoordinate2D
    var phone: String
    var mail: String
    var url: String
    var desc: String
    
    init(id: String, name: String, image: String, latitude: String, longitude: String, phone: String, mail: String, url: String, desc: String)
    {
        self.id = id
        self.title = name
        self.image = image
        self.coordinate = CLLocationCoordinate2D(latitude: Double(latitude)!, longitude: Double(longitude)!)
        self.phone = phone
        self.mail = mail
        self.url = url
        self.desc = desc
    }
}

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var poiMarkers = [PoiMarker]()
    let locationManager = CLLocationManager()
    
    
   // @IBOutlet weak var maps: MKMapView!
    
    @IBOutlet weak var maps: MKMapView!
    
    func getPlacemark(forLocation location: CLLocation, completionHandler: @escaping (CLPlacemark?, String?) -> ()){
        let geocoder = CLGeocoder()
        
        
        geocoder.reverseGeocodeLocation(location, completionHandler:{
            
            placemark, error in
            
            if let err = error {
                completionHandler(nil, err.localizedDescription)
            }
            else if let placemarkArray = placemark {
                
                if let placemarks = placemarkArray.first
                {
                    completionHandler(placemarks, nil)
                }else{
                    completionHandler(nil, "Placemark was nil!")
                }
            }else{
                completionHandler(nil, "unknow error")
            }
            
        })
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        maps.delegate = self
        
        //Mis en place des annotations siur tout les pins
        for marker in poiMarkers{
            
            getPlacemark(forLocation: CLLocation(latitude: marker.coordinate.latitude, longitude: marker.coordinate.longitude)){
                (originPlacemark, error) in
                if let err = error{
                    print(err)
                }else if let placemark = originPlacemark{
                    
                   
                    if placemark.subThoroughfare != nil && placemark.thoroughfare != nil{
                        
                        marker.subtitle = "\(placemark.subThoroughfare!), \(placemark.thoroughfare!) \(placemark.postalCode!) \(placemark.locality!)"
                    }
                    else{
                        
                           marker.subtitle = "\(placemark.postalCode!) \(placemark.locality!)"
                        }
                    
                }
            }
            
            maps.addAnnotation(marker)

           
        }
        
        //Position utilisateur
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            
        }
            
       
        maps.setRegion(MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: 43.551534, longitude: 7.016659), CLLocationDistance(5000), CLLocationDistance(5000)), animated: true)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Postion de l'utilisateur
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        
        var locValue: CLLocationCoordinate2D = (manager.location?.coordinate)!
        
        var positionUser = MKPointAnnotation()
        
        positionUser.coordinate = CLLocationCoordinate2DMake(locValue.latitude, locValue.longitude)
               
        maps.addAnnotation(positionUser)
        
       locationManager.stopUpdatingLocation()
        
    }
    
    //Bouton i
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if view == nil {
            //print("view was nil")
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            view?.canShowCallout = true
            view?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            //print("view wasn't nil")
            view?.annotation = annotation
        }
        return view
    }

    //Bouton i
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
       
        let selectedAnnotation = view.annotation as! PoiMarker
       /* print(selectedAnnotation.title!)
        print(selectedAnnotation.image)
        print(selectedAnnotation.coordinate)*/
        
        self.performSegue(withIdentifier: "showDetail", sender: selectedAnnotation)
        /*if control == view.rightCalloutAccessoryView {
           
         
            print(view.annotation!)
        }*/
        
        /*var test = ShowDetailViewController()
        
        self.navigationController?.pushViewController(test, animated: true)*/
        
    }
    
    //envoie des données sur une autre page
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        var selected = sender as! PoiMarker
        
        if segue.identifier == "showDetail"
        {
            if let destination = segue.destination as? ShowDetailViewController{
                destination.imagePassed = selected.image
                destination.titre = selected.title!
                
                destination.coordLatitude = selected.coordinate.latitude
                destination.coordLongitude = selected.coordinate.longitude
                destination.telephoneNumber = selected.phone
                                               
            }
        }
       
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
    

