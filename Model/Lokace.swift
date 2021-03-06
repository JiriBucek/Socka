//
//  Lokace.swift
//  MHD APP
//
//  Created by Boocha on 13.12.18.
//  Copyright © 2018 Boocha. All rights reserved.
//

import Foundation
import CoreLocation


class Lokace: NSObject, CLLocationManagerDelegate{
    // Vrací polohu uživatele.
    
    static let shared = Lokace()
    var currentLocation = CLLocation()
    let locationManager : CLLocationManager
    var triNejblizsiZastavkyArray = [String]()
    
    override init() {
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        super.init()
        locationManager.delegate = self
    }
    
    func start() {
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last!
        triNejblizsiZastavkyArray = getTriNejblizsiZastavky()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
     print(error)
     }
 
    
    func getTriNejblizsiZastavky() -> [String]{
        // Vrátí název tří nejbližších zastávek metra.
        var zastavkyArray = [String:Double]()
        
        for (jmeno_zastavky, lokace_zastavky) in zastavkyGPS{
            let poloha_zastavky = CLLocation(latitude: lokace_zastavky[0], longitude: lokace_zastavky[1])
            let temporary_distance = currentLocation.distance(from: poloha_zastavky)
            
            zastavkyArray[jmeno_zastavky] = temporary_distance
        }
        
        let zastavkyTuple = zastavkyArray.sorted(by: { (a, b) in (a.value ) < (b.value ) })
        
        var triNejblizsiZastavky = [String]()
        
        for i in 0...2{
            triNejblizsiZastavky.append(zastavkyTuple[i].key)
        }
        
        return triNejblizsiZastavky
    }
    
    func getDalsiTriZastavkyKeKonecne(jmenoZastavky: String, jmenoKonecneZastavky: String) -> [String]{
        // Vrátí array s dalšími třemi zastavkami ve směru ke konečné.
        let linkaMetra = getLinkaMetraZastavky(jmenoZastavky: jmenoZastavky)
        var arrayVsechZastavekLinky = [String]()
        var arrayTriZastavek = [String]()
        
        switch linkaMetra{
            case "A":
                arrayVsechZastavekLinky = linka_A
            
            case "B":
                arrayVsechZastavekLinky = linka_B
            
            case "C":
                arrayVsechZastavekLinky = linka_C
            
            default:
                print("Nepodařilo se načíst array stanic metra")
        }
        
        let indexZastavky = Int(arrayVsechZastavekLinky.index(of: jmenoZastavky)!)
        let indexKonecne = Int(arrayVsechZastavekLinky.index(of: jmenoKonecneZastavky)!)
        
        var i: Int
        
        if indexZastavky > indexKonecne{
            i = -1
        }else{
            i = 1
        }
        
        var pocetZastavekDoKonecne = abs(indexZastavky - indexKonecne) - 1
        if pocetZastavekDoKonecne > 3{
            pocetZastavekDoKonecne = 3
        }
        
        if pocetZastavekDoKonecne > 0{
            var x = i
            for _ in 1...pocetZastavekDoKonecne{
                arrayTriZastavek.append(arrayVsechZastavekLinky[indexZastavky + x])
                x += i
            }}
        
        while arrayTriZastavek.count < 3{
            arrayTriZastavek.append("...")
        }
        return arrayTriZastavek
    }
    
    func getLinkaMetraZastavky(jmenoZastavky: String) -> String?{
        // Vrací linku metra pro danou zastávku.
        
        if let linka = zastavkyIDs[jmenoZastavky]?[2]{
            return linka
        }else{
            print("Nepodařilo se zjistit linku metra pro zastávku:", jmenoZastavky)
            return nil
        }
        
    }
    
}




