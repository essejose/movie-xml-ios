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
    
    
    func getRoute (destination: CLLocationCoordinate2D){
        let request = MKDirectionsRequest()
        
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: locationManage.location!.coordinate))
        
        let directions = MKDirections(request: request)
        
        directions.calculate { ( response : MKDirectionsResponse?, error : Error?) in
            
            if error == nil{
                
                guard let response =  response else {return}
            
                let route = response.routes.first!
                
                print("Distancia", route.distance)
                print("expectedTravelTime", route.expectedTravelTime)
                print("name", route.name)
                
                
                for step in route.steps{
                    
                    print("Em \(step.distance) metros, \(step.instructions)")
                
                }
                
                self.mapview.add(route.polyline, level: .aboveRoads)
                self.mapview.showAnnotations(self.mapview.annotations, animated: true)
                
                
            
            }else{
            
                print(error!.localizedDescription)
            }
            
        }
    
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
            annotation.subtitle = theater.url
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
        
        //mapview.setRegion(region, animated: true)
        
        
    }

}


extension TheatesViewController : UISearchBarDelegate{

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        
        
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let resquest = MKLocalSearchRequest()

        resquest.naturalLanguageQuery = searchBar.text
        
        resquest.region = mapview.region
        let search = MKLocalSearch(request: resquest)
        search.start { (response : MKLocalSearchResponse?, error: Error?) in
            
            if(error == nil){
                
                guard let response = response else {return}
                
                var placeMarks: [MKPointAnnotation] = []
                
                
                for item in response.mapItems{
                
                    let annotation = MKPointAnnotation()
                    
                    annotation.coordinate = item.placemark.coordinate
                    annotation.title = item.name
                    annotation.subtitle = item.phoneNumber
                    
                    placeMarks.append(annotation)
                }
                
                self.mapview.removeAnnotations(self.mapview.annotations)
                self.mapview.addAnnotations(placeMarks)
                
                
                
            }else{
                print("Deu erro", error!.localizedDescription)
            }
            
        }
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
                
                let btLeft = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30 ))
                
                    btLeft.setImage(UIImage(named:"car"),for: .normal)
                    annotationView.leftCalloutAccessoryView = btLeft
                
                let btRight = UIButton(type: .infoLight)
                annotationView.rightCalloutAccessoryView = btRight
                
                
                
            } else{
                
                annotationView.annotation = annotation
            
            }
        }
        else if annotation is MKPointAnnotation{
                
                annotationView  = mapview.dequeueReusableAnnotationView(withIdentifier: "POI")
                
                if annotationView  == nil {
                    annotationView =  MKPinAnnotationView(annotation: annotation, reuseIdentifier: "POI")
                    annotationView.image = UIImage(named: "theaterIcon")
                    annotationView.canShowCallout = true
                    (annotationView as! MKPinAnnotationView).pinTintColor = .blue
                    (annotationView as! MKPinAnnotationView).animatesDrop = true
                    annotationView.canShowCallout = true
                    
                    
                    
                    
                    
                } else{
                    
                    annotationView.annotation = annotation
                    
                }
                
            }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.leftCalloutAccessoryView{
            
            print("Traca rota")
            getRoute(destination: view.annotation!.coordinate)
            
            mapview.removeOverlays(mapview.overlays)
            mapview.deselectAnnotation(view.annotation, animated: true)
            
            
        } else{
        
            print("Mostra site")
            
            let vc = storyboard?.instantiateViewController(withIdentifier:
                "WebViewController") as! WebViewController
            
            vc.url = view.annotation?.subtitle!
            present(vc, animated: true, completion: nil)
            

        }
        
    
        
    
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if overlay is MKPolyline{
            
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .blue
            renderer.lineWidth = 6.0
            
            return renderer
            
        }else{
            
            return MKOverlayRenderer(overlay: overlay)
        }
        
        
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
                    theater.url = content
                    
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



