//
//  InterfaceController.swift
//  Socka Extension
//
//  Created by Boocha on 18.11.18.
//  Copyright © 2018 Boocha. All rights reserved.
//

import WatchKit
import Foundation
import UIKit
import CoreLocation
import CoreData

extension UIColor{
    // rozšíření klasické UIColot, abych mohl zadávat rovnou HEX kod barvy
    func HexToColor(hexString: String, alpha:CGFloat? = 1.0) -> UIColor {
        // Convert hex string to an integer
        let hexint = Int(self.intFromHexString(hexStr: hexString))
        let red = CGFloat((hexint & 0xff0000) >> 16) / 255.0
        let green = CGFloat((hexint & 0xff00) >> 8) / 255.0
        let blue = CGFloat((hexint & 0xff) >> 0) / 255.0
        let alpha = alpha!
        // Create color object, specifying alpha as well
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return color
    }
    
    func intFromHexString(hexStr: String) -> UInt32 {
        var hexInt: UInt32 = 0
        // Create scanner
        let scanner: Scanner = Scanner(string: hexStr)
        // Tell scanner to skip the # character
        scanner.charactersToBeSkipped = NSCharacterSet(charactersIn: "#") as CharacterSet
        // Scan hex value
        scanner.scanHexInt32(&hexInt)
        return hexInt
    }
}

//MARK - global vars

var nearestZastavkaIndex: Int = 0
// globalni var pro prehazovani zastavky, pro kterou maji byt zobrazeny casove udaje

var aktualneZobrazovanaStanice: String = ""
//globalni vars urcene pro predavani info vedlejsimu VC, ktery zobrazuje stanice pro projeti

var metro_data = [[Any]]()
var arrayPristichZastavek1 = [String]()
var arrayPristichZastavek2 = [String]()
var konecna1 = ""
var konecna2 = ""
var existujeNovaVerzeDTBZ = false
var prestupniStaniceVybrana = ""

let cervena = UIColor().HexToColor(hexString: "F30503", alpha: 1.0)
let zluta = UIColor().HexToColor(hexString: "FFA100", alpha: 1.0)
let zelena = UIColor().HexToColor(hexString: "008900", alpha: 1.0)


class InterfaceController: WKInterfaceController, CLLocationManagerDelegate {

    
    @IBOutlet var nearestZastavkaBtn: WKInterfaceButton!
    
    @IBAction func nearestZastavkaBtnPressed() {
        //prepinani trech nejblizsich stanic
        nearestZastavkaIndex += 1
        if nearestZastavkaIndex == 3{
            nearestZastavkaIndex = 0
        }
        
        if prestupniStaniceVybrana != ""{
            nearestZastavkaIndex = 0
        }
        prestupniStaniceVybrana = ""
        //po kliknutí na ručně vybranou přestupní stanici se zobrazí zase první dle GPS
    }
    

    @IBOutlet var konecna1outlet: WKInterfaceLabel!
    @IBOutlet var konecna2outlet: WKInterfaceLabel!
    
    @IBOutlet var countdown1: WKInterfaceLabel!
    @IBOutlet var countdown2: WKInterfaceLabel!
    
    @IBOutlet var cas12: WKInterfaceLabel!
    
    @IBOutlet var cas22: WKInterfaceLabel!
    
    var currentLocation = CLLocation()
    //globalni promenna, kam si vlozim soucasnou pozici ve fci location manager
    
    let manager = CLLocationManager()
    //první proměnná nutná pro práci s polohovým službama
    
    
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        getDocumentsDirectory()
        
        var _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(displayAllValues), userInfo: nil, repeats: true)
        //každou sekundu updatuje funkci displayAllValue
        
        
        ////   LOKACE   ////
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest //nejlepší možná přesnost
        manager.requestWhenInUseAuthorization() //hodí request na užívání
        manager.startUpdatingLocation() //updatuje polohu
        
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        
        
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //vrátí aktuální polohu a vykreslí ji do mapy, všechny vykomentarovany veci se vztahuji k mape, kterou jsem odstranil
        let location = locations[0]//všechny lokace budou v tomto array, dostanu tu nejnovější
        
        currentLocation = location
        
    }
    
    
    
    @objc func displayAllValues(){
        //přiřadí hodnoty jednotlivým labelum
        var hlavniZastavka = nearestMetro()[nearestZastavkaIndex]
        //aktuálne vybraná stanice
        print("Hlavní zastávka: ", hlavniZastavka)
        
        if prestupniStaniceVybrana != ""{
            hlavniZastavka = prestupniStaniceVybrana
        }
        
        let hlavniBarva = getColor(jmenoZastavky: hlavniZastavka)
        var barva2 = zelena
        var barva3 = zelena
        
        switch hlavniBarva {
        case cervena:
            barva2 = zelena
            barva3 = zluta
        case zluta:
            barva2 = cervena
            barva3 = zelena
        case zelena:
            barva2 = zluta
            barva3 = cervena
        default:
            print("Barvy nefungují.")
        }
        
        
        if aktualneZobrazovanaStanice != hlavniZastavka{
            print("NOVÁ DATA")
            metro_data = get_metro_times(dayOfWeek: getDayOfWeek(), metroStanice: nearestZastavkaIndex)
            print("Data na hodinkách: ", metro_data)
            
            if metro_data.count > 1{
                
                if metro_data.indices.contains(0){
                    konecna2 = String(describing: metro_data[0][2])
                    print("Konecna2: ", konecna2)
                    //arrayPristichZastavek2 = getDalsiTriZastavkyKeKonecne(jmenoZastavky: hlavniZastavka, jmenoKonecneZastavky: konecna2)
                }else{
                    konecna2 = "..."
                    //arrayPristichZastavek2 = ["...", "...","..."]
                }
                
                if metro_data.indices.contains(2){
                    konecna1 = String(describing: metro_data[2][2])
                    print("Konecna1: ", konecna1)
                    //arrayPristichZastavek1 = getDalsiTriZastavkyKeKonecne(jmenoZastavky: hlavniZastavka, jmenoKonecneZastavky: konecna1)
                }else{
                    konecna1 = "..."
                    //arrayPristichZastavek1 = ["...", "...","..."]
                }
                
            }
            aktualneZobrazovanaStanice = hlavniZastavka
            //takhle si nesaha do DB kazdou vterinu, ale jen, pokud se zmenila zastavka
        }
        
        
        aktualneZobrazovanaStanice = hlavniZastavka
        
        if (metro_data.count) > 1 {
            
            var time1 = 999999
            if metro_data.indices.contains(0){
                time1 = (metro_data[0][1] as! Int)
            }
            
            var time2 = 999999
            if metro_data.indices.contains(2){
                time2 = (metro_data[2][1] as! Int)
            }
            
            var time11 = 999999
            if metro_data.indices.contains(1){
                time11 = (metro_data[1][1] as! Int)
            }
            var time22 = 999999
            if metro_data.indices.contains(3){
                time22 = (metro_data[3][1] as! Int)
            }
            
            print("Konecna1: ", konecna1)
            konecna1outlet.setText(konecna1)
            //konecna1outlet.textColor = hlavniBarva
            
            print("Konecna2: ", konecna2)
            konecna2outlet.setText(konecna2)
            //konecna2outlet.textColor = hlavniBarva
            
            nearestZastavkaBtn.setTitle(hlavniZastavka)
            
            
            if myTimeDifference(to: time1) <= 0{
                metro_data = get_metro_times(dayOfWeek: getDayOfWeek(), metroStanice: nearestZastavkaIndex)
            }
            
            if myTimeDifference(to: time2) <= 0{
                metro_data = get_metro_times(dayOfWeek: getDayOfWeek(), metroStanice: nearestZastavkaIndex)
            }
            /*
            if arrayPristichZastavek1.count > 2{
                dalsiZastavkaLabel11.text = arrayPristichZastavek1[0]
                dalsiZastavkaLabel11.textColor = hlavniBarva
                dalsiZastavkaLabel12.text = arrayPristichZastavek1[1]
                dalsiZastavkaLabel12.textColor = hlavniBarva
                dalsiZastavkaLabel13.text = arrayPristichZastavek1[2]
                dalsiZastavkaLabel13.textColor = hlavniBarva
            }
            
            if arrayPristichZastavek2.count > 2{
                dalsiZastavkaLabel21.text = arrayPristichZastavek2[0]
                dalsiZastavkaLabel21.textColor = hlavniBarva
                dalsiZastavkaLabel22.text = arrayPristichZastavek2[1]
                dalsiZastavkaLabel22.textColor = hlavniBarva
                dalsiZastavkaLabel23.text = arrayPristichZastavek2[2]
                dalsiZastavkaLabel23.textColor = hlavniBarva
            }
            */
            nearestZastavkaBtn.setTitle(hlavniZastavka)
            //nearestZastavkaBtn.setTitleColor(hlavniBarva, for: .normal)
            
            
            if (myTimeDifference(to: time1) > 0 && myTimeDifference(to: time2) > 0) || (myTimeDifference(to: time1) < -1000 ){
                if time1 != 999999 || time11 != 999999{
                    print("cas12: ", timeDifference(arrivalTime: time11))
                    print("countdown1: ", timeDifference(arrivalTime: time1))
                    cas12.setText(timeDifference(arrivalTime: time11))
                    countdown1.setText(timeDifference(arrivalTime: time1))
                }else{
                    cas12.setText("0:00")
                    countdown1.setText("0:00")
                }
                
                if time2 != 999999 || time22 != 999999{
                    cas22.setText(timeDifference(arrivalTime: time22))
                    countdown2.setText(timeDifference(arrivalTime: time2))
                }else{
                    cas22.setText("0:00")
                    countdown2.setText("0:00")
                }
                
               // countdown2.textColor = barva3
                // countdown1.textColor = barva2
            }
 
            
            /*
            if existujeNovaVerzeDTBZ{
                ukazUpgradeVC()
                existujeNovaVerzeDTBZ = false
            }
            */
        }
    }
    
    func nearestMetro() -> [String]{
        //vrátí název tří nejbližších zastávek metra a vzdálenosti od usera
        var zastavkyArray = [String:Double]()
        
        for (jmeno_zastavky, lokace_zastavky) in zastavky{
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
    
    func fetchData(station_id: String, service_id: [Int], results_count: Int, current_time: Int) -> [[Any]]{
        //fetchne data z databíze
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "FullEntity")
        //vytvoření kominikacniho objectu a zadání názvu entity
        
        var final_data = [[Any]]()
        //tohle to nakonec vrátí
        
        let coreDataStack = CoreDataStack()
        
        request.returnsObjectsAsFaults = false
        //pokud je to false, nereturnuju to fetchnuty data jako faults .. faults znamena, ze to napise misto konkretnich dat jen data = faults. Setri to pamet.
        
        let context = coreDataStack.persistentContainer.viewContext
        
        
        //PREDICATES a SORTDESCRIPTORS
        let current_time = current_time
        let station_id = station_id
        let schedule_id = service_id
        
        var subPredicates = [NSPredicate]()
        //array s predikátama
        for i in 0..<schedule_id.count{
            let oneSubpredicate = NSPredicate(format: "stop_id == %@ AND service_id == %i AND arrival_time > %i", station_id, schedule_id[i], current_time)
            // pro string pouziju %@, integer %i, key %K
            subPredicates.append(oneSubpredicate)
        }//vytvoří tolik subpredicates, kolik je pro daný den potřeba service ids
        
        let myPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: subPredicates)
        //souhrnný predicate typu OR
        
        let mySortDescriptor = NSSortDescriptor(key: "arrival_time", ascending: true)
        //seradi fetch data podle casu smerem nahoru
        
        request.predicate = myPredicate
        request.sortDescriptors = [mySortDescriptor]
        //přiřadí predicate a sortdescriptor do requestu, descriptoru muze byt vice, proto je to array
        
        do{
            //fetchne si data podle predicatu a sortdescriptoru a přiřadí je do arraye, který obsahuje jen tolik záznamů, kolik jsem zadal v parametru results_count
            let results = try context.fetch(request)
            
            if results.count > 0{
                
                for result in results as! [NSManagedObject]
                {
                    var single_array = [Any]()
                    
                    if let stop_id = result.value(forKey: "stop_id") as? String, let arrival_time = result.value(forKey: "arrival_time") as? Int, let trip_headsign = result.value(forKey: "trip_headsign") as? String{
                        single_array.append(stop_id)
                        single_array.append(arrival_time)
                        single_array.append(trip_headsign)
                        //přiřadí values do array
                    }
                    final_data.append(single_array)
                    //přiřadí single array do konečného arraye
                    
                    if final_data.count > results_count - 1{
                        break
                        //díky tomuto to vrátí jen požadovaný počet výsledků
                    }
                }
            }
            
        }catch{
            print("Nepodařil se fetch")
        }
        return final_data
    }
    
    
    func current_time() -> Int{
        //vrátísoučasný čas jako Int
        let date = NSDate()
        let calendar = NSCalendar.current
        let hour = calendar.component(.hour, from: date as Date)
        var minutes = String(calendar.component(.minute, from: date as Date))
        if minutes.characters.count == 1{
            minutes = "0" + minutes
        }
        var seconds = String(calendar.component(.second, from: date as Date))
        if seconds.characters.count == 1{
            seconds = "0" + seconds
        }
        let final = Int("\(hour)\(minutes)\(seconds)")
        return final!
    }
    
    func get_metro_times(dayOfWeek: Int, metroStanice: Int) -> [[Any]]!{
        //parametr metroStanice odkazuje na to, která zastávka se má načítat > 0 je nejbližší, 1 je druhá nejbližší, 2 je třetí nejbližší
        //vrátí array s dvěma konecnyma a sesti casama
        var nearest_station = nearestMetro()[metroStanice]
        
        if prestupniStaniceVybrana != ""{
            nearest_station = prestupniStaniceVybrana
        }
        
        //název zastávky metra
        let station_ids = stations_ids[nearest_station]!
        //dva ID kody pro danou zastavku a dvě konecne
        let time = current_time()
        //soucasny cas jako INT
        let today = dayOfWeek
        
        var service_ids = getServiceId(day: today)
        
        var times1 = fetchData(station_id: station_ids[0], service_id: service_ids, results_count: 2, current_time: time)
        var times2 = fetchData(station_id: station_ids[1], service_id: service_ids, results_count: 2, current_time: time)
        
        //přiřazení časů po půlnoci
        if times1.count < 2{
            let resultCount = times1.count
            
            var tomorrow = today + 1
            if tomorrow == 8{
                tomorrow = 1
            }
            service_ids = getServiceId(day: tomorrow)
            let times11 = fetchData(station_id: station_ids[0], service_id: service_ids, results_count: 2 - resultCount, current_time: 0)
            times1 = times1 + times11
        }
        
        if times2.count < 2{
            let resultCount = times2.count
            
            var tomorrow = today + 1
            if tomorrow == 8{
                tomorrow = 1
            }
            service_ids = getServiceId(day: tomorrow)
            let times21 = fetchData(station_id: station_ids[1], service_id: service_ids, results_count: 2 - resultCount, current_time: 0)
            times2 = times2 + times21
        }
        
        
        let times = times1 + times2
        
        //print(times)
        return times
    }
    
    func formatTime(time: Int) -> String{
        //vezme cas v INT a preklopi ho do stringu s dvojteckama
        var time = String(describing: time)
        
        while time.characters.count < 5{
            let index = time.startIndex
            time.insert("0", at: index)
        }
        
        let index = time.index(time.endIndex, offsetBy: -2)
        time.insert(":", at: index)
        let index2 = time.index(time.endIndex, offsetBy: -5)
        time.insert(":", at: index2)
        
        return time
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
    
    func getServiceId(day: Int) -> [Int]{
        //vrátí service IDs pro daný den
        var service_ids = [Int]()
        
        switch day {
        case 1:
            service_ids = [1]
        case 2:
            service_ids = [1]
        case 3:
            service_ids = [1]
        case 4:
            service_ids = [1]
        case 5:
            service_ids = [1]
        case 6:
            service_ids = [3]
        case 7:
            service_ids = [5]
        default:
            print("Nepodařilo se získat service IDs")
        }
        return service_ids
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
    
    func timeDifference(arrivalTime: Int) -> String {
        //odpočítávadlo času ... vezme si Int ve formátu 153421 a dopočítává, kolik zbývá minut a sekund do toho času
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        //velke hacka znamenaji, ze misto 4pm budu mit 16:00
        
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
        //spočítá časový rozdíl mezi from a to
        var minuty = String(describing: timeDifference.minute!)
        var sekundy = String(describing: timeDifference.second!)
        
        
        
        if Int(minuty)! < -1000{
            //úprava kvůli přepočtu přes půlnoc, aby to neukazovalo minusove casy
            minuty = String(Int(minuty)! + 1439)
            sekundy = String(59 + Int(sekundy)!)
        }
        
        if sekundy.characters.count == 1{
            //přihodí nulu, pokud sekundy mají jen jeden znak
            let index = sekundy.startIndex
            sekundy.insert("0", at: index)
        }
        
        return "\(minuty):\(sekundy)"
    }
    
    func getColor(jmenoZastavky: String) -> UIColor{
        //returne barvu linky dané stanice metra
        var barva = UIColor()
        
        
        if let metroLinka = stations_ids[jmenoZastavky]?[2]{
            switch metroLinka {
            case "A":
                barva = zelena
            case "B":
                barva = zluta
            case "C":
                barva = cervena
            default:
                print("Nepodařilo se určit barvu")
            }
        }
        return barva
    }
    
    func getLinkaMetraZastavky(jmenoZastavky: String) -> String{
        //returne linku metra
        let linkaMetra = stations_ids[jmenoZastavky]?[2]
        return linkaMetra!
    }
    
    
    
    
    
    func getDocumentsDirectory() -> URL {
        //Vypíše cestu do dokumentu
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        print("Tohle je na hodinkach:  \(documentsDirectory)")
        return documentsDirectory
    }

}
