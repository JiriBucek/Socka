//
//  Databaze.swift
//  MHD APP
//
//  Created by Boocha on 14.12.18.
//  Copyright © 2018 Boocha. All rights reserved.
//

import Foundation
import CoreData

public class Databaze{
    //  Propojeni na Core Data datamodel.
    //  Kopírování databáze z bundlu.
    //  Fetch dat z sqlite souboru.
    //  Ukládání verze uložené databáze.
    
    var zarizeni: typZarizeni
    enum typZarizeni
        {
            case MOBIL
            case HODINKY
        }
    
    init(zarizeni: typZarizeni) {
        self.zarizeni = zarizeni
        self.zapisVerziDtbzDoUserDefaults(novaVerze: 3)
    }
    
    let verzeDTBZvTomtoBundlu = 4
    
    lazy var persistentContainer: NSPersistentContainer = {
        // Core Data
        
        let container = NSPersistentContainer(name: "DataBaze")
        let DatabazeString: String = "DataBaze"
        var persistentStoreDescriptions: NSPersistentStoreDescription
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        let dtbzFileUrlVDokumentech = URL(fileURLWithPath: documentDirectoryPath!).appendingPathComponent("DataBaze")
        
        //  Check, zda není v telefonu stará databáze. Kvůli aktualizaci z App Storu.
        if FileManager.default.fileExists(atPath: (dtbzFileUrlVDokumentech.path)) && (zjistiVerziDtbzVDefaults() < verzeDTBZvTomtoBundlu){
            
            do{
                try FileManager.default.removeItem(at: dtbzFileUrlVDokumentech)
                  print("Mažu starou databázi pro", zarizeni)
            }catch{
                print("Nepodařilo se smazat starou databázi pro", zarizeni)
            }
        }
        
        // Kopírování databáze z bundlu
        if !FileManager.default.fileExists(atPath: (dtbzFileUrlVDokumentech.path)) {
            
            let bundleFileUrl = Bundle.main.url(forResource: DatabazeString, withExtension: "sqlite")
            
            do {
                try FileManager.default.copyItem(at: bundleFileUrl!, to: dtbzFileUrlVDokumentech)
                zapisVerziDtbzDoUserDefaults(novaVerze: verzeDTBZvTomtoBundlu)
                print("Databaze zkopirovana z bundlu do dokumentů pro.", zarizeni)
            }catch{
                print("Nepodařilo se zkopírovat databázi z bundlu pro.", zarizeni)
            }
        }
        
        // Log na persistant store = sql file
        container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: dtbzFileUrlVDokumentech)]
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                fatalError("Error v databázi: \(error), pro \(self.zarizeni)")
            }
        })
        return container
    }()
    
    func saveContext() {
        //Uložení změn
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch let error as NSError {
                fatalError("Error ve funkci save Context: \(error), \(error.userInfo) pro \(zarizeni)")
            }
        }
    }
    
    func fetchData(station_id: String, service_id: Int, results_count: Int, current_time: Int) -> [[Any]]{
        // Fetch dat z databáze
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "FullEntity")
        var final_data = [[Any]]()
        let databaze = Databaze(zarizeni: zarizeni)
        request.returnsObjectsAsFaults = false
        // Lepsi performance.
        
        let context = databaze.persistentContainer.viewContext
        let current_time = current_time
        let station_id = station_id
        let schedule_id = service_id
        var subPredicates = [NSPredicate]()
        let oneSubpredicate = NSPredicate(format: "stop_id == %@ AND service_id == %i AND arrival_time > %i", station_id, schedule_id, current_time)
        // Pro string pouziji %@, integer %i, key %K.
        
        subPredicates.append(oneSubpredicate)
        let myPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: subPredicates)
        // Souhrnný predicate typu OR.
        
        let mySortDescriptor = NSSortDescriptor(key: "arrival_time", ascending: true)
        // Seradi fetch data podle casu smerem nahoru.
        
        request.predicate = myPredicate
        request.sortDescriptors = [mySortDescriptor]
        
        do{
            // Fetch.
            let results = try context.fetch(request)
            
            if results.count > 0{
                
                for result in results as! [NSManagedObject]
                {
                    var single_array = [Any]()
                    
                    if let stop_id = result.value(forKey: "stop_id") as? String, let arrival_time = result.value(forKey: "arrival_time") as? Int, let trip_headsign = result.value(forKey: "trip_headsign") as? String{
                        single_array.append(stop_id)
                        single_array.append(arrival_time)
                        single_array.append(trip_headsign)
                    }
                    
                    final_data.append(single_array)
                    
                    if final_data.count > results_count - 1{
                        break
                        // Break na požadovaný počet výsledků.
                    }
                }
            }
            
        }catch{
            print("Nepodařil se fetch pro.", zarizeni)
        }
        return final_data
    }
    
    func zjistiVerziDtbzNaWebu() -> Int{
        // Zjistí verzi databaze na webu.
        var verzeNaWebu = 0
        
        if let url = URL(string: "http://socka.funsite.cz/verze.htm") {
            do {
                verzeNaWebu = try Int(String(contentsOf: url)) ?? 0
            } catch {
                print("")
            }
        } else {
            print("Nedokážu se lognout na web a zjistit verzi")
        }
        return verzeNaWebu
    }
    
    func zjistiVerziDtbzVDefaults() -> Int{
        var verze = UserDefaults.standard.integer(forKey: "verzeDtbz")
        
        if zarizeni == .HODINKY{
            verze = UserDefaults.standard.integer(forKey: "verzeDtbzWatch")
        }
        
        return verze
    }
    
    func zapisVerziDtbzDoUserDefaults(novaVerze: Int){
        UserDefaults.standard.set(novaVerze, forKey: "verzeDtbz")
        
        if zarizeni == .HODINKY{
            UserDefaults.standard.set(novaVerze, forKey: "verzeDtbzWatch")
        }
        
        print("Zapisuji novou verzi: ", novaVerze, "pro", zarizeni)
    }
    
    
    
}
