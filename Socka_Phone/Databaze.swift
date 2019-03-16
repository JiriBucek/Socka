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
    //propojeni na Core Data datamodel
    //fetch dat z sqlite souboru
    
    var zarizeni: typZarizeni
    
    enum typZarizeni
        {
            case MOBIL
            case HODINKY
        }
    
    init(zarizeni: typZarizeni) {
        self.zarizeni = zarizeni
    }
    
    let verzeDTBZvTomtoBundlu = 4
    
    lazy var persistentContainer: NSPersistentContainer = {
        //vytvoří container, který má pod sebou více vrstev core dat
        
        let container = NSPersistentContainer(name: "DataBaze")
        let DatabazeString: String = "DataBaze"
        var persistentStoreDescriptions: NSPersistentStoreDescription
        
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        let dtbzFileUrlVDokumentech = URL(fileURLWithPath: documentDirectoryPath!).appendingPathComponent("DataBaze")
        
        
        //CHECK ZDA V TELEFONU NENÍ ZASTARALÁ DATABÁZE
        if FileManager.default.fileExists(atPath: (dtbzFileUrlVDokumentech.path)) && (zjistiVerziDtbzVTelefonuUserDefaults() < verzeDTBZvTomtoBundlu){
            //Přemazávání starých databázi v telefonu při aktualizaci databáze. Pro případ aktualizace a existence staré dtbz v telefonu
            print("Mažu starou databázi v telefonu.")
            do{
                try FileManager.default.removeItem(at: dtbzFileUrlVDokumentech)
            }catch{
                print("Nepodařilo se smazat starou databázi v telefonu.")
            }
        }
        
        //KOPÍROVÁNÍ DATABÁZE Z BUNDLU
        if !FileManager.default.fileExists(atPath: (dtbzFileUrlVDokumentech.path)) {
            //existuje uz na tom umisteni soubor DataFinal280417.sqlite?. Kdyz ne, tak:
            
            let bundleFileUrl = Bundle.main.url(forResource: DatabazeString, withExtension: "sqlite")
            //najde soubor sql v bundlu appky
            
            do {
                try FileManager.default.copyItem(at: bundleFileUrl!, to: dtbzFileUrlVDokumentech)
                zapisVerziDtbzDoUserDefaults(novaVerze: verzeDTBZvTomtoBundlu)
                print("Databaze zkopirovana z bundlu do dokumentů v telefonu.")
                //zkopiruje tento soubor do slozky dokumentu do founu
            }catch{
                print("Nepodařilo se zkopírovat databázi z bundlu do hodinek.")
            }
        }
        
        //logne se na persistaent store = sql file
        container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: dtbzFileUrlVDokumentech)]
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                fatalError("Error ve watch databázi: \(error),")
            }
        })
        return container
    }()
    
    func saveContext() {
        //funkce k ulozeni zmen
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch let error as NSError {
                fatalError("Error ve funkci saveContext v telefonu: \(error), \(error.userInfo)")
            }
        }
    }
    
    func fetchData(station_id: String, service_id: Int, results_count: Int, current_time: Int) -> [[Any]]{
        //fetchne data z databíze
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "FullEntity")
        //vytvoření kominikacniho objectu a zadání názvu entity
        
        var final_data = [[Any]]()
        //tohle to nakonec vrátí
        
        let databaze = Databaze(zarizeni: zarizeni)
        
        request.returnsObjectsAsFaults = false
        //pokud je to false, nereturnuju to fetchnuty data jako faults .. faults znamena, ze to napise misto konkretnich dat jen data = faults. Setri to pamet.
        
        let context = databaze.persistentContainer.viewContext
        
        
        //PREDICATES a SORTDESCRIPTORS
        let current_time = current_time
        let station_id = station_id
        let schedule_id = service_id
        
        var subPredicates = [NSPredicate]()
        //array s predikátama
        
        let oneSubpredicate = NSPredicate(format: "stop_id == %@ AND service_id == %i AND arrival_time > %i", station_id, schedule_id, current_time)
        // pro string pouziju %@, integer %i, key %K
        subPredicates.append(oneSubpredicate)
        
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
            print("Nepodařil se fetch v telefonu.")
        }
        return final_data
    }
    
    func zjistiVerziDtbzNaWebu() -> Int{
        //logne se na muj web a zjistí aktuální verzi dtbz na webu
        var verzeNaWebu = 0
        
        if let url = URL(string: "http://socka.funsite.cz/verze.htm") {
            do {
                verzeNaWebu = try Int(String(contentsOf: url)) ?? 0
            } catch {
                print("")
            }
        } else {
            print("Nedokážu se lognout na web a zjistit verzi")
            // the URL was bad!
        }
        return verzeNaWebu
    }
    
    func zjistiVerziDtbzVTelefonuUserDefaults() -> Int{
        let verze = UserDefaults.standard.integer(forKey: "verzeDtbz")
        return verze
    }
    
    func zapisVerziDtbzDoUserDefaults(novaVerze: Int){
        UserDefaults.standard.set(novaVerze, forKey: "verzeDtbz")
        print("Zapisuji novou verzi: ", novaVerze)
    }
    
    
    
}
