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
    
    
    @IBOutlet weak var mapview: MKMapView!

    var currentElement : String!
    var theater: Theater!
    var theaters: [Theater] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadXML();
        //print(theaters.count)
        
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



