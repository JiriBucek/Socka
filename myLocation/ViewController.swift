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

class ViewController: UIViewController, CLLocationManagerDelegate{
    
    //MAP
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var nearestZastavkaLabel: UILabel!
    
    var zastavky = ["Depo Hostivař": [50.075541, 14.51532], "Skalka": [50.068435, 14.507169], "Strašnická": [50.073336, 14.490091], "Želivského": [50.07854, 14.474891], "Flora": [50.078288, 14.461886], "Jiřího z Poděbrad": [50.077642, 14.45004], "Náměstí Míru": [50.075398, 14.439078], "Muzeum - A": [50.079847, 14.430577], "Můstek - A": [50.083943, 14.424149], "Staroměstská": [50.088454, 14.417066], "Malostranská": [50.092176, 14.409101], "Hradčanská": [50.097671, 14.402535], "Dejvická": [50.100481, 14.392462], "Bořislavka": [50.098319, 14.36212], "Nádraží Veleslavín": [50.09551, 14.348419], "Petřiny": [50.086608, 14.345018], "Nemocnice Motol": [50.074985, 14.340497], "Zličín": [50.052798, 14.291152], "Stodůlky": [50.046716, 14.307241], "Luka": [50.045365, 14.321854], "Lužiny": [50.044515, 14.331143], "Hůrka": [50.050026, 14.343495], "Nové Butovice": [50.050856, 14.35285], "Radlická": [50.057942, 14.388403], "Smíchovské nádraží": [50.061797, 14.409112], "Anděl": [50.07049, 14.404878], "Karlovo náměstí": [50.074808, 14.417579], "Národní třída": [50.080209, 14.420439], "Můstek - B": [50.083609, 14.423983], "Náměstí Republiky": [50.088974, 14.43128], "Florenc - B": [50.090437, 14.438362], "Křižíkova": [50.092627, 14.452043], "Invalidovna": [50.096976, 14.463824], "Palmovka": [50.10417, 14.475436], "Českomoravská": [50.106302, 14.492291], "Vysočanská": [50.110167, 14.501728], "Kolbenova": [50.110331, 14.517115], "Hloubětín": [50.106531, 14.537062], "Rajská zahrada": [50.106935, 14.561205], "Černý Most": [50.109058, 14.577538], "Letňany": [50.126314, 14.515926], "Prosek": [50.119166, 14.498572], "Střížkov": [50.12713, 14.488199], "Ládví": [50.126655, 14.468806], "Kobylisy": [50.124005, 14.453577], "Nádraží Holešovice": [50.108534, 14.440372], "Vltavská": [50.099847, 14.438426], "Florenc - C": [50.089619, 14.438892], "Hlavní nádraží": [50.083115, 14.433785], "Muzeum - C": [50.079861, 14.431276], "I. P. Pavlova": [50.073871, 14.430295], "Vyšehrad": [50.062681, 14.430482], "Pražského povstání": [50.056508, 14.433761], "Pankrác": [50.050601, 14.439927], "Budějovická": [50.044052, 14.449283], "Kačerov": [50.041696, 14.459939], "Roztyly": [50.037425, 14.477329], "Chodov": [50.031392, 14.491431], "Opatov": [50.027915, 14.509895], "Háje": [50.03081, 14.527675],]
    
    var currentLocation = CLLocation()
    //globalni promenna, kam si vlozim soucasnou pozici ve fci location manager
    
    let manager = CLLocationManager()
    //první proměnná nutná pro práci s polohovým službama
    
    override func viewDidLoad() {
    //co se stane po loadnutí
        super.viewDidLoad()
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest //nejlepší možná přesnost
        manager.requestWhenInUseAuthorization() //hodí request na užívání
        manager.startUpdatingLocation() //updatuje polohu
        
        /// Funkce pro plneni DB///
        
        //parseCSV(fileName: "stop_times_male") //rozparsuje csv do formátu [["key":"value","key":"value"], ["key":"value"]]
        fillData(csvFileName: "stop_times_male", entityName: "PolozkaJR")
        //deleteDB(entityName: "PolozkaJR")
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    //vrátí aktuální polohu a vykreslí ji do mapy
        let location = locations[0]//všechny lokace budou v tomto array, dostanu tu nejnovější
        
        currentLocation = location
        
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01) //určuje, jak moc chci, aby byla mapa zoomnuta
        let myLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude) //moje poloha
        
        //let myLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(50.076286, 14.446349)
        
        let region: MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span) //zkombinuje předchozí dvě vars a vytvoří region
        map.setRegion(region, animated: true) //vykreslí mapu
        
        self.map.showsUserLocation = true //vykreslí modrou tečku na místo, kde jsem
        
        nearestZastavkaLabel.text = nearestMetro()
        
    }
    
    func nearestMetro() -> String{
    //vrátí název zastávky nejbližšího metra
        var lowest_distance: Double = 999999999999.99999
        var nearestZastavka = String()
        
        for (jmeno_zastavky, lokace_zastavky) in zastavky{
            let poloha_zastavky = CLLocation(latitude: lokace_zastavky[0], longitude: lokace_zastavky[1])
            let temporary_distance = currentLocation.distance(from: poloha_zastavky)
            if temporary_distance < lowest_distance{
                lowest_distance = temporary_distance
                nearestZastavka = jmeno_zastavky
            }
        }
    return nearestZastavka
    }


    
//////////// CORE DATA by Swift Guy ///////////
    
    ////změnil sem typy a názvy v PolozkaJR, způsobuje to errory
        
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
                novaPolozka.setValue(value, forKey: key)
                do{
                    try context.save()
                    print("SAVED")
                }catch{
                    print("ANI PRD")
                }
            }
        }
        
        /*
        novaPolozka.setValue("stop idecko2", forKey: "stop_id")
        novaPolozka.setValue("15:452", forKey: "time")
        novaPolozka.setValue(324, forKey: "trip_id")
        */
        
        do{
            try context.save()
            print("SAVED")
        }catch{
            print("ANI PRD")
        }
        /*
        // FETCHING RESULTS FROM CORE DATA - Swift Guy
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PolozkaJR")
        //vytvoření kominikacniho objectu a zadání názvu entity
        
        request.returnsObjectsAsFaults = false
        //tohle upraví formát výstupu na něco použitelného
        
        do{
            let results = try context.fetch(request)
            //
            if results.count > 0{
                for result in results as! [NSManagedObject]
                {
                    if let stop_id = result.value(forKey: "stop_id") as? String{
                        print(stop_id)
                    }
                }
            }
            
        }catch{
            print("Nepodařil se fetch")
        }
        */
        
        
        /*
        polozkaJR?.stop_id = "2"
        polozkaJR?.time = "15:30"
        polozkaJR?.trip_id = */
    }
    
    func deleteDB(entityName: String) {
        //Vymaže všechna data v dané položce
        let coreDataStack = CoreDataStack()
        let context = coreDataStack.persistentContainer.viewContext
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        do{
        try context.execute(request)
        }catch{
            print(error)
        }
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func parseCSV(fileName: String) -> [Dictionary<String, Any>]{
    //rozparsuje SCVecko a vrátí array plnej dictionaries, kde key je název sloupce a value je hodnota
        let path = Bundle.main.path(forResource: fileName, ofType: "csv")
        var rows = [Dictionary<String, Any>]()
        do {
            let csv = try CSV(contentsOfURL: path!)
            rows = csv.rows
            //print(rows)
        }catch{
        print(error)
        }
        return rows
    }


}

