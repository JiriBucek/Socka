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
    //  SuperClass s vypocetnimi metodami pro hlavni interface controller.
    
    public var aktualneZobrazovanaZastavka: String = ""
    var device: String = "hodinky"
    var triNejblizsiZastavky = [String]()
    var zastavkySwitch: Int = 0
    var triNejblizsiZastavkyPrepinaciArray = [String]()
        // Pomocny array pro změnu polohy uživatele a nejbližších stanic metra.
    var prepinaciPomocnaZastavka = ""
    //  Pomocna promenna pro pripad zmeny zobrazovane stanice.
    
    let databaze = Databaze(zarizeni: .HODINKY)
    var lokace = Lokace()
    var metroData = MetroDataClass()

    
    override func awake(withContext context: Any?) {
        lokace = Lokace.shared
        // Singleton lokace
        lokace.start()
        
        triNejblizsiZastavky = lokace.triNejblizsiZastavkyArray
        
        if triNejblizsiZastavky.count == 3{
            //pro pripad, ze by se lokace jeste nechytila
            aktualneZobrazovanaZastavka = triNejblizsiZastavky[0]
        }
        
        prepinaciPomocnaZastavka = aktualneZobrazovanaZastavka
        fillMetroDataObject()
    }
    
    func fillMetroDataObject(){
        // Vytvoří objekt se všemi informacemi pro screen
        
        var metro_times = [[Any]]()
        var konecna1 = String()
        var konecna2 = String()
        var arrayPristichZastavek2 = [String]()
        var arrayPristichZastavek1 = [String]()
        
        metro_times = get_metro_times(jmenoZastavky: aktualneZobrazovanaZastavka)
        //  Fetch do databaze.
        
        if metro_times.indices.contains(2){
            //  sezene konecne a nasledne zastavky ke konecnym
            
            konecna2 = String(describing: metro_times[0][2])
            arrayPristichZastavek2 = (lokace.getDalsiTriZastavkyKeKonecne(jmenoZastavky: aktualneZobrazovanaZastavka, jmenoKonecneZastavky: konecna2))
            
            konecna1 = String(describing: metro_times[2][2])
            arrayPristichZastavek1 = (lokace.getDalsiTriZastavkyKeKonecne(jmenoZastavky: aktualneZobrazovanaZastavka, jmenoKonecneZastavky: konecna1))
            
            metroData.jmenoZastavky = aktualneZobrazovanaZastavka
            metroData.konecna1 = konecna2
            metroData.konecna2 = konecna1
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
        //  Vrátí array s dvěmi konečnými stanicemi a čtyřmi časy.
        
        if let station_ids = zastavkyIDs[jmenoZastavky]{
            //  Dva ID kody pro danou zastavku a dvě konecne
            let time = current_time()
            // Aktuální čas jako INT
            
            let today = getDayOfWeek()
            
            var service_id = getServiceId(day: today)
            
            var times1 = databaze.fetchData(station_id: station_ids[0], service_id: service_id, results_count: 2, current_time: time)
            var times2 = databaze.fetchData(station_id: station_ids[1], service_id: service_id, results_count: 2, current_time: time)
            
            //  Přiřazení časů při přechodu přes půlnoc
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
            
            return times
            
        }else{
            return []
        }
        
    }
    
    func getServiceId(day: Int) -> Int{
        //  Vrátí service ID pro daný den.
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
        //  Vrátí současný čas jako Int.
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
        //  Vrátí den v týdnu jako Int od 1 do 7.
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
    
    func printDocumentsDirectory() {
        //  Vypíše cestu do dokumentu
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        print("Dokument folder na hodinkach:  \(documentsDirectory)")
    }
    
    func zjistiDostupnostNoveDatabaze() -> Bool{
        let verzeVHodinakch = databaze.zjistiVerziDtbzVDefaults()
        let verzeNaNetu = databaze.zjistiVerziDtbzNaWebu()
        
        print("Verze na netu: \(verzeNaNetu)")
        print("Verze v hodinkách \(verzeVHodinakch)")
        
        if verzeVHodinakch < verzeNaNetu{
            print("Je dostupná nová verze!!")
            return true
        }else{
            return false
        }
        
    }
    
    func myTimeDifference(to targetTime: Int) -> Int{
        //  Spočitá rozdíl mezi časem metra a současným časem
        let time = targetTime - current_time()
        return time
    }
    
    func rozdilCasuTypuDate(datum1: Date, datum2: Date) -> Int{
        //  Vrati rozdil dvou objektu typu Date v sekundach
        
        let datum1prevedeno = datum1.timeIntervalSince1970
        let datum2prevedeno = datum2.timeIntervalSince1970
        
        return Int(datum1prevedeno - datum2prevedeno)
    }
    
    func timeDifference(arrivalTime: Int) -> String {
        //  Odpočítávadlo času ... vezme si Int ve formátu 153421 a dopočítává, kolik zbývá minut a sekund do toho času.
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        //  Velke hacka znamenaji, ze misto 4pm budu mit 16:00.
        
        let time = formatTime(time: arrivalTime)
        var stopTime = timeFormatter.date(from: time)
        
        let date = Date()
        let calendar = Calendar.current
        
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let hour = calendar.component(.hour, from: stopTime!)
        let minute = calendar.component(.minute, from: stopTime!)
        let second = calendar.component(.second, from: stopTime!)
        
        stopTime = calendar.date(bySetting: .year, value: year, of: stopTime!)
        stopTime = calendar.date(bySetting: .month, value: month, of: stopTime!)
        stopTime = calendar.date(bySetting: .day, value: day, of: stopTime!)
        stopTime = calendar.date(bySetting: .hour, value: hour, of: stopTime!)
        stopTime = calendar.date(bySetting: .minute, value: minute, of: stopTime!)
        stopTime = calendar.date(bySetting: .second, value: second, of: stopTime!)
        
        let timeDifference = calendar.dateComponents([.minute, .second], from: date, to: stopTime!)
        //  Spočítá časový rozdíl mezi from a to.
        var minuty = String(describing: timeDifference.minute!)
        var sekundy = String(describing: timeDifference.second!)
        
        
        if let minutyWrap = Int(minuty){
            if minutyWrap < -1000{
                //  Úprava kvůli přepočtu přes půlnoc, aby to neukazovalo minusove casy.
                minuty = String(Int(minuty)! + 1439)
                sekundy = String(59 + Int(sekundy)!)
            }else if minutyWrap < 0 && minutyWrap > -1000{
                //  Kvůli nezobrazování minusovych hodnot pri chybnem nacteni casu.
                minuty = "0"
                sekundy = "0"
            }
        }
        
        if sekundy.count == 1{
            // Přihodí nulu, pokud sekundy mají jen jeden znak.
            let index = sekundy.startIndex
            sekundy.insert("0", at: index)
        }
        
        return "\(minuty):\(sekundy)"
    }
    
    func formatTime(time: Int) -> String{
        //  Vezme cas v INT a preklopi ho do stringu s dvojteckama.
        var time = String(describing: time)
        
        while time.count < 5{
            let index = time.startIndex
            time.insert("0", at: index)
        }
        
        let index = time.index(time.endIndex, offsetBy: -2)
        time.insert(":", at: index)
        let index2 = time.index(time.endIndex, offsetBy: -5)
        time.insert(":", at: index2)
        
        return time
    }

    func lokaceDostupnaPopUp(){
        
        if CLLocationManager.locationServicesEnabled() {
            
            switch CLLocationManager.authorizationStatus() {
                
            case .notDetermined, .restricted, .denied:
                print("Lokalizace vypnuta!")
                
                let action1 = WKAlertAction(title: "Zrušit", style: .cancel){}
                
                presentAlert(withTitle: "GPS vypnuta.", message: "Zapni polohové služby pro Socku na svém iPhonu v Nastavení/Socka/Poloha/Vždy. Jinak nelze určit nejbližší zastávku metra.", preferredStyle: .actionSheet, actions: [action1])
                
            case .authorizedAlways, .authorizedWhenInUse:
                print("Lokalizační služby povoleny.")
                return
            }
            
        }else{
            let action1 = WKAlertAction(title: "Zrušit", style: .cancel){}
            
            presentAlert(withTitle: "GPS vypnuta.", message: "Zapni polohové služby na svém iPhonu v Nastavení/Soukromí/Polohové služby. Jinak nelze určit nejbližší zastávku metra.", preferredStyle: .actionSheet, actions: [action1])
            
        }
        
    }
}
