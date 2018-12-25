//
//  SockaBaseVC.swift
//  MHD APP
//
//  Created by Boocha on 14.12.18.
//  Copyright © 2018 Boocha. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import WatchKit




class SockaWatchBaseVC: WKInterfaceController, CLLocationManagerDelegate{
    
    public var aktualneZobrazovanaZastavka: String = ""
    var prepinaciPomocnaZastavka = ""
    var device: String = "hodinky"
    var triNejblizsiZastavky = [String]()
    var zastavkySwitch: Int = 0
    var metroData = MetroDataClass()
    var triNejblizsiZastavkyPrepinaciArray = [String]()
    //objekt, který obsahuje veškeré informace pro zobrazení na displeji
    
    let databaze = Databaze()
    var lokace = Lokace()
    
    
    
    override func awake(withContext context: Any?) {
        lokace = Lokace.shared
        //shared je singleton lokace
        lokace.start()
        //zacne updatovat polohu
        
        triNejblizsiZastavky = lokace.triNejblizsiZastavkyArray
        
        if triNejblizsiZastavky.count == 3{
            //pro pripad, ze by se lokace jeste nechytila
            aktualneZobrazovanaZastavka = triNejblizsiZastavky[0]
        }
        
        prepinaciPomocnaZastavka = aktualneZobrazovanaZastavka
        fillMetroDataObject()
        
    }
    
    func fillMetroDataObject(){
        //vytvoří objekt se všemi informacemi pro screen
        
        var metro_times = [[Any]]()
        var konecna1 = String()
        var konecna2 = String()
        var arrayPristichZastavek2 = [String]()
        var arrayPristichZastavek1 = [String]()
        
        
        metro_times = get_metro_times(jmenoZastavky: aktualneZobrazovanaZastavka)
        
        if metro_times.indices.contains(2){
            //sezene konecne a nasledne zastavky ke konecnym
            
            konecna2 = String(describing: metro_times[0][2])
            arrayPristichZastavek2 = (lokace.getDalsiTriZastavkyKeKonecne(jmenoZastavky: aktualneZobrazovanaZastavka, jmenoKonecneZastavky: konecna2))
            
            konecna1 = String(describing: metro_times[2][2])
            arrayPristichZastavek1 = (lokace.getDalsiTriZastavkyKeKonecne(jmenoZastavky: aktualneZobrazovanaZastavka, jmenoKonecneZastavky: konecna1))
            
            metroData.jmenoZastavky = aktualneZobrazovanaZastavka
            metroData.konecna1 = konecna1
            metroData.konecna2 = konecna2
            metroData.nextZastavka11 = arrayPristichZastavek1[0]
            metroData.nextZastavka12 = arrayPristichZastavek1[1]
            metroData.nextZastavka13 = arrayPristichZastavek1[2]
            metroData.nextZastavka21 = arrayPristichZastavek2[0]
            metroData.nextZastavka22 = arrayPristichZastavek2[1]
            metroData.nextZastavka23 = arrayPristichZastavek2[2]
            metroData.cas11 = metro_times[0][1] as? Int
            metroData.cas12 = metro_times[1][1] as? Int
            metroData.cas21 = metro_times[2][1] as? Int
            metroData.cas22 = metro_times[3][1] as? Int
            
            
        }else{
            print("Nemám žádná data z databáze, nevytvořil jsem objekt metroDataClass v hodinkách.")
        }
        
        
        
        
    }
    
    
    func get_metro_times(jmenoZastavky: String) -> [[Any]]!{
        //vrátí array s dvěma konecnyma a ctyrma casama
        
        if let station_ids = zastavkyIDs[jmenoZastavky]{
            //dva ID kody pro danou zastavku a dvě konecne
            
            let time = current_time()
            //soucasny cas jako INT
            
            let today = getDayOfWeek()
            
            var service_id = getServiceId(day: today)
            
            var times1 = databaze.fetchData(station_id: station_ids[0], service_id: service_id, results_count: 2, current_time: time)
            var times2 = databaze.fetchData(station_id: station_ids[1], service_id: service_id, results_count: 2, current_time: time)
            
            //přiřazení časů po půlnoci
            if times1.count < 2{
                let resultCount = times1.count
                
                var tomorrow = today + 1
                if tomorrow == 8{
                    tomorrow = 1
                }
                
                service_id = getServiceId(day: tomorrow)
                
                let times11 = databaze.fetchData(station_id: station_ids[0], service_id: service_id, results_count: 2 - resultCount, current_time: 0)
                
                times1 = times1 + times11
            }
            
            if times2.count < 2{
                let resultCount = times2.count
                
                var tomorrow = today + 1
                if tomorrow == 8{
                    tomorrow = 1
                }
                service_id = getServiceId(day: tomorrow)
                let times21 = databaze.fetchData(station_id: station_ids[1], service_id: service_id, results_count: 2 - resultCount, current_time: 0)
                times2 = times2 + times21
            }
            
            
            let times = times1 + times2
            
            //print(times)
            return times
            
        }else{
            return []
        }
        
    }
    
    func getServiceId(day: Int) -> Int{
        //vrátí service ID pro daný den
        var service_id = Int()
        
        switch day {
        case 1:
            service_id = 1
        case 2:
            service_id = 1
        case 3:
            service_id = 1
        case 4:
            service_id = 1
        case 5:
            service_id = 1
        case 6:
            service_id = 3
        case 7:
            service_id = 5
        default:
            print("Nepodařilo se získat service IDs v hodinkách")
        }
        return service_id
    }
    
    func current_time() -> Int{
        //vrátísoučasný čas jako Int
        let date = NSDate()
        let calendar = NSCalendar.current
        let hour = calendar.component(.hour, from: date as Date)
        var minutes = String(calendar.component(.minute, from: date as Date))
        if minutes.count == 1{
            minutes = "0" + minutes
        }
        var seconds = String(calendar.component(.second, from: date as Date))
        if seconds.count == 1{
            seconds = "0" + seconds
        }
        let final = Int("\(hour)\(minutes)\(seconds)")
        return final!
    }
    
    func getDayOfWeek() -> Int{
        //vrátí den v týdnu jako Int od 1 do 7. Musím od toho odečíst jedničku, protože začínají nedělí jako jedna
        let date = Date()
        let calendar = Calendar.current
        var day = calendar.component(.weekday, from: date) - 1
        if day == 0{
            day = 7
        }
        return day
    }
    
    func isAppAlreadyLaunchedOnce()->Bool{
        let defaults = UserDefaults.standard
        if let _ = defaults.string(forKey: "isAppAlreadyLaunchedOnce"){
            print("Aplikace již byla v minulosti v hodinkách spuštěna.")
            return true
        }else{
            defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
            print("První spuštění aplikace v hodinkách.")
            return false
        }
    }
    
    
}
