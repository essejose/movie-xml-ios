//
//  TheatesViewController.swift
//  MoviesLib
//
//  Created by Usuário Convidado on 06/09/17.
//  Copyright © 2017 EricBrito. All rights reserved.
//

import UIKit
import MapKit


class TheatesViewController: UIViewController {
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapview: MKMapView!
    
    lazy var locationManage = CLLocationManager()

    
    var currentElement : String!
    var theater: Theater!
    var theaters: [Theater] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapview.delegate = self
        searchBar.delegate = self
        

        loadXML();
        //print(theaters.count)
        
        requestUserLocationAuthorization()
        
    }
    
    
    func requestUserLocationAuthorization(){
        
        if CLLocationManager.locationServicesEnabled(){
        
            locationManage.delegate = self
            locationManage.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManage.allowsBackgroundLocationUpdates = true
            locationManage.pausesLocationUpdatesAutomatically = true
            
            switch CLLocationManager.authorizationStatus(){
                case .authorizedAlways, .authorizedWhenInUse:
                    print("tudo liberado bro")
            case .denied:
                    print(" ele nao liberou a localizacacao >(")
                
            case .notDetermined:
                    print("ainda nao pedi")
                locationManage.requestWhenInUseAuthorization()
            
            case .restricted:
                    print("nao tem acesso a localizacao")
            
            } 
            
            
        }
        
    
    }
    
    func addTheaters(){
        
        for theater in theaters {
            
            let coordinate = CLLocationCoordinate2D(latitude: theater.latitude,longitude: theater.longitude)
            let annotation  = TheaterAnotation(coordinate: coordinate)
            
            annotation.title = theater.name
            annotation.subtitle = theater.address
            mapview.addAnnotation(annotation)
            
        }
        
        mapview.showAnnotations(mapview.annotations, animated: true)
        
    }
    
    
    func loadXML(){
    
       if let xmlURL = Bundle.main.url(forResource: "theaters", withExtension: "xml"), let xmlParser =
        XMLParser(contentsOf : xmlURL){
            xmlParser.delegate = self
            xmlParser.parse()
        
        }
    }
    
   

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  

}


extension TheatesViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .authorizedWhenInUse:
                mapview.showsUserLocation = true
        default:
            break
        }
        
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        print(userLocation.location?.speed)
        
        let region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 500, 500)
        
        mapview.setRegion(region, animated: true)
        
        
    }

}


extension TheatesViewController : UISearchBarDelegate{

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
    }
    
}


extension TheatesViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView: MKAnnotationView!
        
        if annotation is TheaterAnotation{
            
            annotationView  = mapview.dequeueReusableAnnotationView(withIdentifier: "Theater")
            
            if annotationView  == nil {
                annotationView =  MKAnnotationView(annotation: annotation, reuseIdentifier: "Theater")
                annotationView.image = UIImage(named: "theaterIcon")
                annotationView.canShowCallout = true
            } else{
                
                annotationView.annotation = annotation
            
            }
        }
        return annotationView
    }
    
}

extension TheatesViewController: XMLParserDelegate{
    
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        print(elementName)
        
        currentElement = elementName
        
        if elementName == "Theater"{
            
            theater = Theater()
        
        }
    }
    

    func parserDidEndDocument(_ parser: XMLParser) {
        //theaters.append(theater)
        addTheaters()
    }
    
    
    func parser( _ parser: XMLParser, foundCharacters string : String){
            print(string)
            
            let content = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            if !content.isEmpty{
                
                switch currentElement {
                case "name":
                    theater.name = content
                case "address":
                    theater.address = content
                case "latitude":
                
                    theater.latitude = Double(content)!
                
                case "longitude":
                    theater.longitude = Double(content)!
                case "url":
                    theater.address = content
                    
                default:
                    break
                }
                
            }
            
            
        }
        
        func parser( _ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?){
            
            print(elementName)
            
            
            if elementName == "Theater"{
                
                theaters.append(theater)
            
            }

        }
    
}



