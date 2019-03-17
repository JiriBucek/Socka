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
import SystemConfiguration

class SockaBaseVC: UIViewController, CLLocationManagerDelegate{
    //Superclass Model pro hlavní VC.
    
    public var aktualneZobrazovanaZastavka: String = ""
    var prepinaciPomocnaZastavka = ""
    var device: String = "mobil"
    var triNejblizsiZastavky = [String]()
    var zastavkySwitch: Int = 0
    var metroData = MetroDataClass()
    var triNejblizsiZastavkyPrepinaciArray = [String]()
    let databaze = Databaze(zarizeni: .MOBIL)
    var lokace = Lokace()
    
    override func viewDidLoad() {
        lokace = Lokace.shared
        // Singleton lokace
        lokace.start()
        triNejblizsiZastavky = lokace.triNejblizsiZastavkyArray
        
        if triNejblizsiZastavky.count == 3{
        // Pro pripad, ze by se lokace jeste nechytila
            aktualneZobrazovanaZastavka = triNejblizsiZastavky[0]
        }
        
        prepinaciPomocnaZastavka = aktualneZobrazovanaZastavka
        fillMetroDataObject()
    }
    
    func fillMetroDataObject(){
        // Vytvoří objekt MetroDataClass se všemi informacemi pro screen.
        
        var metro_times = [[Any]]()
        var konecna1 = String()
        var konecna2 = String()
        var arrayPristichZastavek2 = [String]()
        var arrayPristichZastavek1 = [String]()
        
        metro_times = get_metro_times(jmenoZastavky: aktualneZobrazovanaZastavka)
        
        if metro_times.indices.contains(2){
            //  Konecne a nasledne zastavky ke konecnym.
            
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
            print("Nemám žádná data z databáze, nevytvořil jsem objekt metroDataClass.")
        }
    }
    
    
    func get_metro_times(jmenoZastavky: String) -> [[Any]]!{
        // Vrátí array s dvěmi konečnými zastávkami a jejich čtyřmi časy příjezdů.
        
        if let station_ids = zastavkyIDs[jmenoZastavky]{
        // Dva ID kody pro danou zastavku a dvě konecne
        
        let time = current_time()
        // Soucasny cas jako INT.
        
        let today = getDayOfWeek()
        var service_id = getServiceId(day: today)
        var times1 = databaze.fetchData(station_id: station_ids[0], service_id: service_id, results_count: 2, current_time: time)
        var times2 = databaze.fetchData(station_id: station_ids[1], service_id: service_id, results_count: 2, current_time: time)
        
        // Přiřazení časů po půlnoci.
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
        // Vrátí service ID pro daný den.
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
            print("Nepodařilo se získat service IDs")
        }
        return service_id
    }
    
    func current_time() -> Int{
        // Vrátí přítomný čas jako Int.
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
        // Vrátí den v týdnu jako Int od 1 do 7. 1 pondělí.
        let date = Date()
        let calendar = Calendar.current
        var day = calendar.component(.weekday, from: date) - 1
        if day == 0{
            day = 7
        }
        return day
    }
    
    func isAppAlreadyLaunchedOnce()->Bool{
        // Detektor prvního spuštění aplikace. 
        let defaults = UserDefaults.standard
        if let _ = defaults.string(forKey: "isAppAlreadyLaunchedOnce"){
            print("Aplikace již byla v minulosti spuštěna.")
            return true
        }else{
            defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
            print("První spuštění aplikace.")
            return false
        }
    }
    
    func jeDnesSvatek(){
        // Zjití, zda je tento den státní svátek a pokud ano, vyhodí o tom hlášku
        var svatek = false
        
        let svatky = [[1,1],[30,3],[1,5],[8,5],[5,7],[6,7],[28,9],[28,10],[17,11],[24,12],[25,12],[26,12],[1,4]]
        let now = Date()
        let kalendar = Calendar.current
        let den = kalendar.component(.day, from: now)
        let mesic = kalendar.component(.month, from: now)
        let dnesniDen = [den, mesic]
        
        if svatky.contains(where: {$0 == dnesniDen}){
            print("Dnes je svátek")
            svatek = true
        }else{
            svatek = false
        }
        
        if svatek{
            let alertSvatky = UIAlertController(title: "Dnes je svátek.", message: "Ve dnech svátků je možné, že se časy odjezdu metra budou lišit. Tyto změny není možné ošetřit offline databází. Děkuji za pochopení", preferredStyle: .alert)
            
            alertSvatky.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alertSvatky, animated: true)
        }
        
    }
    
    func checkLocationEnabled() {
        // Zkontroluje zapnutí polohových služeb. Ty mohou být vypnuty konkrétně pro Socku nebo globálně.
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
                
            case .notDetermined, .restricted, .denied:
                print("Lokalizace pro Socku vypnuta!")
                
                let alert = UIAlertController(title: "Lokalizační služby nedostupné", message: "Máš vypnuty lokalizační služby, bez nichž nemůže Socka určit tvou polohu a nejbližší zastávku metra. Zapni je prosím v Nastavení/Socka/Poloha/", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
                    self.dismiss(animated: true, completion: nil)
                }
                ))
                
                self.present(alert, animated: true, completion: nil)
                
            case .authorizedAlways, .authorizedWhenInUse:
                print("Lokalizační služby povoleny.")
            }
        }else{
            let alert = UIAlertController(title: "Lokalizační služby nedostupné", message: "Máš vypnuty lokalizační služby, bez nichž nemůže Socka určit tvou polohu a nejbližší zastávku metra. Zapni je prosím v Nastavení/Soukromí/Polohové služby/", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
                self.dismiss(animated: true, completion: nil)
            }
            ))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func isInternetAvailable() -> Bool {
        // Checkne pripojeni k internetu.
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
    
    func zjistiDostupnostNoveDatabaze() -> Bool{
        let verzeVtelefonu = databaze.zjistiVerziDtbzVDefaults()
        let verzeNaNetu = databaze.zjistiVerziDtbzNaWebu()
        
        if verzeVtelefonu < verzeNaNetu{
            print("Je dostupná nová verze!")
            return true
        }else{
            return false
        }
    }
    
    func getDocumentsDirectory() -> URL {
        //Vypíše cestu do dokumentu
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    
    func myTimeDifference(to targetTime: Int) -> Int{
        //spočitá rozdíl mezi časem metra a současným časem
        let time = targetTime - current_time()
        return time
    }
    
    func rozdilCasuTypuDate(datum1: Date, datum2: Date) -> Int{
        //vrati rozdil dvou objektu typu Date v sekundach
        let datum1prevedeno = datum1.timeIntervalSince1970
        let datum2prevedeno = datum2.timeIntervalSince1970
        return Int(datum1prevedeno - datum2prevedeno)
    }
    
    func formatTime(time: Int) -> String{
        // Cas v INT formatu preklopi do Stringu 00:00.
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
    
    func timeDifference(arrivalTime: Int) -> String {
        // Odpočítávadlo času ... vezme si Int ve formátu 153421 a dopočítává, kolik zbývá minut a sekund do toho času.
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        // Velke hacka znamenaji, ze misto 4pm budu mit 16:00.
        
        let time = formatTime(time: arrivalTime)
        
        var stopTime = timeFormatter.date(from: time)
        print("StopTime: ", stopTime)
        
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
        // Spočítá časový rozdíl mezi from a to
        var minuty = String(describing: timeDifference.minute!)
        var sekundy = String(describing: timeDifference.second!)
        
        if Int(minuty)! < -1000{
            // Úprava kvůli přepočtu přes půlnoc, aby to neukazovalo minusove casy
            minuty = String(Int(minuty)! + 1439)
            sekundy = String(59 + Int(sekundy)!)
        }
        
        if sekundy.count == 1{
            // Přihodí nulu, pokud sekundy mají jen jeden znak
            let index = sekundy.startIndex
            sekundy.insert("0", at: index)
        }
        
        return "\(minuty):\(sekundy)"
    }
    
}
