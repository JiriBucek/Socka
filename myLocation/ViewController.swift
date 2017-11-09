//
//  ViewController.swift
//  myLocation
//
//  Created by Boocha on 14.04.17.
//  Copyright © 2017 Boocha. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData
import SystemConfiguration

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

let cervena = UIColor().HexToColor(hexString: "F30503", alpha: 1.0)
let zluta = UIColor().HexToColor(hexString: "FFA100", alpha: 1.0)
let zelena = UIColor().HexToColor(hexString: "008900", alpha: 1.0)

//MARK - VC

class ViewController: UIViewController, CLLocationManagerDelegate{
    
    
    @IBOutlet weak var nearestZastavkaButton: UIButton!
    
    @IBAction func nearestZastavkaButtonPressed(_ sender: Any) {
        //prepinani trech nejblizsich stanic
        nearestZastavkaIndex += 1
        if nearestZastavkaIndex == 3{
            nearestZastavkaIndex = 0
        }
        //kvuli restartu po 5 minutach na puvodni zastavku
    }
    
    @IBOutlet weak var cas11: UILabel!
    @IBOutlet weak var cas21: UILabel!
    
    @IBOutlet weak var countdown1: UILabel!
    @IBOutlet weak var countdown2: UILabel!
    
    @IBOutlet weak var konecna1outlet: UILabel!
    @IBOutlet weak var konecna2outlet: UILabel!
    
    @IBOutlet weak var dalsiZastavkaLabel11: UILabel!
    @IBOutlet weak var dalsiZastavkaLabel12: UILabel!
    @IBOutlet weak var dalsiZastavkaLabel13: UILabel!
    
    @IBOutlet weak var dalsiZastavkaLabel21: UILabel!
    @IBOutlet weak var dalsiZastavkaLabel22: UILabel!
    @IBOutlet weak var dalsiZastavkaLabel23: UILabel!
    
    var currentLocation = CLLocation()
    //globalni promenna, kam si vlozim soucasnou pozici ve fci location manager
    
    let manager = CLLocationManager()
    //první proměnná nutná pro práci s polohovým službama
    
    
//MARK - functions
    
    override func viewDidLoad() {
    //co se stane po loadnutí
        
        //let appDelegate:AppDelegate = UIApplication.shared.delegate! as! AppDelegate
        //appDelegate.refreshVC = self
        
        //Nastaví font na buttonu hlavní zastávky 
        nearestZastavkaButton.titleLabel?.minimumScaleFactor = 0.2
        nearestZastavkaButton.titleLabel?.numberOfLines = 1
        nearestZastavkaButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        super.viewDidLoad()
        
        var _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(displayAllValues), userInfo: nil, repeats: true)
        //každou sekundu updatuje funkci displayAllValue

        
        ////   LOKACE   ////
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest //nejlepší možná přesnost
        manager.requestWhenInUseAuthorization() //hodí request na užívání
        manager.startUpdatingLocation() //updatuje polohu
        
        if isInternetAvailable(){
            existujeNovaVerzeDTBZ = zjistiDostupnostNoveDatabaze()
        }
        
        print(getDocumentsDirectory())
        
        /// Funkce pro plneni DB///
        //parseCSV(fileName: "zkratka") //rozparsuje csv do formátu [["key":"value","key":"value"], ["key":"value"]]
        //fillData(csvFileName: "zkratka", entityName: "FullEntity")
        //deleteDB(entityName: "FullEntity")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
    //vybarví status bar nahoře na bílo
        return .default
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    //vrátí aktuální polohu a vykreslí ji do mapy, všechny vykomentarovany veci se vztahuji k mape, kterou jsem odstranil
        let location = locations[0]//všechny lokace budou v tomto array, dostanu tu nejnovější
        
        currentLocation = location
        
    }
    
    @objc func displayAllValues(){
    //přiřadí hodnoty jednotlivým labelum
        let hlavniZastavka = nearestMetro()[nearestZastavkaIndex]
        //aktuálne vybraná stanice
        
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
            
            if metro_data.count > 2{
                konecna2 = String(describing: metro_data[0][2])
                konecna1 = String(describing: metro_data[2][2])
            
                arrayPristichZastavek1 = getDalsiTriZastavkyKeKonecne(jmenoZastavky: hlavniZastavka, jmenoKonecneZastavky: konecna1)
            
                arrayPristichZastavek2 = getDalsiTriZastavkyKeKonecne(jmenoZastavky: hlavniZastavka, jmenoKonecneZastavky: konecna2)
            }
            aktualneZobrazovanaStanice = hlavniZastavka
        //takhle si nesaha do DB kazdou vterinu, ale jen, pokud se zmenila zastavka
        }
        
        
        aktualneZobrazovanaStanice = hlavniZastavka

        if (metro_data.count) > 3 {
            
            let time1 = (metro_data[0][1] as! Int)
            let time2 = (metro_data[2][1] as! Int)
            
            let time11 = (metro_data[1][1] as! Int)
            let time22 = (metro_data[3][1] as! Int)
            
            konecna1outlet.text = konecna1
            konecna1outlet.textColor = hlavniBarva
        
            konecna2outlet.text = konecna2
            konecna2outlet.textColor = hlavniBarva
            
            
            if myTimeDifference(to: time1) <= 0{
                metro_data = get_metro_times(dayOfWeek: getDayOfWeek(), metroStanice: nearestZastavkaIndex)
            }
                
            if myTimeDifference(to: time2) <= 0{
                metro_data = get_metro_times(dayOfWeek: getDayOfWeek(), metroStanice: nearestZastavkaIndex)
            }
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
            
            nearestZastavkaButton.setTitle(hlavniZastavka, for: .normal)
            nearestZastavkaButton.setTitleColor(hlavniBarva, for: .normal)
            
            
            if (myTimeDifference(to: time1) > 0 && myTimeDifference(to: time2) > 0) || (myTimeDifference(to: time11) < -1000 ){
                cas11.text = timeDifference(arrivalTime: time11)
                countdown1.text = timeDifference(arrivalTime: time1)
                countdown1.textColor = barva2
            
                cas21.text = timeDifference(arrivalTime: time22)
                countdown2.text = timeDifference(arrivalTime: time2)
                countdown2.textColor = barva3
            }
                        
            if existujeNovaVerzeDTBZ{
                ukazUpgradeVC()
                existujeNovaVerzeDTBZ = false
            }
            
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


    
//////////// CORE DATA by Swift Guy ///////////
    
    func fillData(csvFileName: String, entityName: String){
    //naplní data z csv do DB
        
        let coreDataStack = CoreDataStack()
        //object ze souboru coredatastack
        let context = coreDataStack.persistentContainer.viewContext
        //objekt contex, na kterej se odvolavam
        
        let hodnoty = parseCSV(fileName: csvFileName)
        
        for hodnota in hodnoty{
            let novaPolozka = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)
            
            for (key, value) in hodnota{
                
                if let cislo = Int(value){
                    novaPolozka.setValue(cislo, forKey: key)
                }else{
                    novaPolozka.setValue(value, forKey: key)
                }
            }
        }
        
        do{
            try context.save()
            print("SAVED")
        }catch{
            print("ANI PRD")
        }
    }
    
        // FETCHING RESULTS FROM CORE DATA - Swift Guy
         
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
    
    
    func deleteDB(entityName: String) {
        //Vymaže všechna data v dané položce
        let coreDataStack = CoreDataStack()
        let context = coreDataStack.persistentContainer.viewContext
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        do{
        try context.execute(request)
            print("Databáze vymazána")
        }catch{
            print(error)
        }
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
        let nearest_station = nearestMetro()[metroStanice]
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
            let times21 = fetchData(station_id: station_ids[0], service_id: service_ids, results_count: 2 - resultCount, current_time: 0)
            times2 = times2 + times21
        }
        
        
        let times = times1 + times2
        
        //print(times)
        return times
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func parseCSV(fileName: String) -> [Dictionary<String, String>]{
    //rozparsuje SCVecko a vrátí array plnej dictionaries, kde key je název sloupce a value je hodnota
        let path = Bundle.main.path(forResource: fileName, ofType: "csv")
        var rows = [Dictionary<String, String>]()
        do {
            let csv = try CSV(contentsOfURL: path!)
            rows = csv.rows
            //print(rows)
        }catch{
        print(error)
        }
        return rows
    }
    

    func getDocumentsDirectory() -> URL {
        //Vypíše cestu do dokumentu
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        //print("Tohle je cesta dle funkce ve VC:  \(documentsDirectory)")
        return documentsDirectory
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
            service_ids = [1,6]
        case 2:
            service_ids = [1,2]
        case 3:
            service_ids = [1,2]
        case 4:
            service_ids = [1,2]
        case 5:
            service_ids = [1,2]
        case 6:
            service_ids = [2,3]
        case 7:
            service_ids = [4,5]
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
    
    func zjistiDostupnostNoveDatabaze() -> Bool{
        let downloader = Downloader()
        let verzeVtelefonu = downloader.zjistiVerziDtbzVTelefonuUserDefaults()
        let verzeNaNetu = downloader.zjistiVerziDtbzNaWebu()
        
        print("Verze na netu: \(verzeNaNetu)")
        print("Verze v telefonu \(verzeVtelefonu)")
        
        if verzeVtelefonu < verzeNaNetu{
            print("Je dostupná nová verze!!")
            return true
        }else{
            return false
        }
        
    }
    
    func ukazUpgradeVC(){
    //vyskoci okynko s vystrahou, ze je nova verze dtbz
        let currentVC = self.view.window?.rootViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "1") as! UpgradeViewController
        vc.view.isOpaque = false
        vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        
        currentVC?.present(vc, animated: true, completion: nil)
    }
    
    func isInternetAvailable() -> Bool {
    //checkne, jestli jsem pripojenej k netu
        
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
    
    }

