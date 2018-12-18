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
    
    static let shared = Lokace()
    var currentLocation = CLLocation()
    
    let locationManager : CLLocationManager
    
    override init() {
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        super.init()
        locationManager.delegate = self
    }
    
    func start() {
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last!
    
        print(currentLocation)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        locationManager.stopUpdatingLocation()
    }
    
    
    func getTriNejblizsiZastavky() -> [String]{
        //vrátí název tří nejbližších zastávek metra a vzdálenosti od usera
        var zastavkyArray = [String:Double]()
        
        for (jmeno_zastavky, lokace_zastavky) in zastavkyGPS{
            let poloha_zastavky = CLLocation(latitude: lokace_zastavky[0], longitude: lokace_zastavky[1])
            let temporary_distance = currentLocation.distance(from: poloha_zastavky)
            
            zastavkyArray[jmeno_zastavky] = temporary_distance
        }
        
        let zastavkyTuple = zastavkyArray.sorted(by: { (a, b) in (a.value ) < (b.value ) })
        
        var triNejblizsiZastavky = [String]()
        
        for i in 0...2{
            //první tři pozice jsou jména zastávek
            triNejblizsiZastavky.append(zastavkyTuple[i].key)
        }
        
        for i in 0...2{
            //další tři pozice jsou vzdálenosti
            triNejblizsiZastavky.append(String(format: "%.f",zastavkyTuple[i].value))
        }
        
        return triNejblizsiZastavky
    }
    
    func getDalsiTriZastavkyKeKonecne(jmenoZastavky: String, jmenoKonecneZastavky: String) -> [String]{
        //dostanu array s dalsima trema zastavkama ve smeru ke konecne
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
    
    func getLinkaMetraZastavky(jmenoZastavky: String) -> String{
        //returne linku metra
        let linkaMetra = zastavkyIDs[jmenoZastavky]?[2]
        return linkaMetra!
    }
    
    
    
    
    
    
    
    
    
    /*
    var currentLocation: CLLocation?
    var manager: CLLocationManager?
    
    override init() {
        super.init()
        
        //globalni promenna, kam si vlozim soucasnou pozici ve fci location manager
        
        manager = CLLocationManager()
        //první proměnná nutná pro práci s polohovým službama
        manager?.delegate = self
        manager!.desiredAccuracy = kCLLocationAccuracyBest //nejlepší možná přesnost
        manager?.requestWhenInUseAuthorization() //hodí request na užívání
        manager?.startUpdatingLocation() //updatuje polohu
        print(CLLocationManager.locationServicesEnabled())
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }
    
    
    func getTriNejblizsiZastavky() -> [String]{
        //vrátí název tří nejbližších zastávek metra a vzdálenosti od usera
        var zastavkyArray = [String:Double]()
        
        for (jmeno_zastavky, lokace_zastavky) in zastavkyGPS{
            let poloha_zastavky = CLLocation(latitude: lokace_zastavky[0], longitude: lokace_zastavky[1])
            let temporary_distance = currentLocation?.distance(from: poloha_zastavky)
            
            zastavkyArray[jmeno_zastavky] = temporary_distance
        }
        
        let zastavkyTuple = zastavkyArray.sorted(by: { (a, b) in (a.value ) < (b.value ) })
        
        var triNejblizsiZastavky = [String]()
        
        for i in 0...2{
            //první tři pozice jsou jména zastávek
            triNejblizsiZastavky.append(zastavkyTuple[i].key)
        }
        
        for i in 0...2{
            //další tři pozice jsou vzdálenosti
            triNejblizsiZastavky.append(String(format: "%.f",zastavkyTuple[i].value))
        }
        
        return triNejblizsiZastavky
    }
    
    func getDalsiTriZastavkyKeKonecne(jmenoZastavky: String, jmenoKonecneZastavky: String) -> [String]{
        //dostanu array s dalsima trema zastavkama ve smeru ke konecne
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
    
    func getLinkaMetraZastavky(jmenoZastavky: String) -> String{
        //returne linku metra
        let linkaMetra = zastavkyIDs[jmenoZastavky]?[2]
        return linkaMetra!
    }
    
    
    */
    
}




