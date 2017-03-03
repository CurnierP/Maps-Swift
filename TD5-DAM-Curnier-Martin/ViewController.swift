//
//  ViewController.swift
//  TD5-DAM-Curnier-Martin
//
//  Created by CURNIER Pierre on 20/02/2017.
//  Copyright © 2017 CURNIER Pierre. All rights reserved.
//

import UIKit
import SWXMLHash

struct Poi{
    
    var id: String
    var name: String
    var image: String
    var latitude: String
    var longitude: String
    var phone: String
    var mail: String
    var url: String
    var description: String
}

class ViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        activityIndicator.startAnimating()
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            
            
            if let url = URL(string: "http://dam.lanoosphere.com/poi.xml")
            {
                
                if let data = try? Data(contentsOf: url)
                {
                    var pois = [Poi]()
                    var xml = SWXMLHash.parse(data)
                    for child in xml["Data"]
                    {
                        
                        for poi in child["POI"]
                        {
                            pois.append(Poi(id :(poi.element?.attributes["id"])!, name :(poi.element?.attributes["name"])!, image :(poi.element?.attributes["image"])!,
                                                    latitude :(poi.element?.attributes["latitude"])!, longitude :(poi.element?.attributes["longitude"])!, phone :(poi.element?.attributes["phone"])!, mail :(poi.element?.attributes["mail"])!, url :(poi.element?.attributes["url"])!, description :(poi.element?.attributes["description"])!))
                        }
                        
                        
                        
                    }
                    DispatchQueue.main.async(execute: {
                        
                        //Push de la view
                        
                        
                        let monNav = self.storyboard?.instantiateViewController(withIdentifier: "mapNavigation") as! UINavigationController
                        let maVue = monNav.viewControllers[0] as! MapViewController
                       
                       
                        for poi in pois
                        {
                            maVue.poiMarkers.append(PoiMarker(id: poi.id, name: poi.name, image: poi.image, latitude: poi.latitude, longitude: poi.longitude, phone: poi.phone, mail: poi.mail, url: poi.url, desc: poi.description))
                        }
                        
                        self.activityIndicator.stopAnimating()
                        
                        //self.navigationController?.pushViewController(maVue, animated: true)
                        
                        self.present(monNav, animated: true, completion: nil)
                    })
                }
                
            }
            
            

        
        
    }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
