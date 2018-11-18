
import CoreData
import UIKit


class CoreDataStack {
    
    //puvodni persistentContainer bez kodu tykajiciho se kopirovani databaze sql
    /*lazy var persistentContainer: NSPersistentContainer = {
     let container = NSPersistentContainer(name: "DataFinal280417")
     
     container.loadPersistentStores(completionHandler: { (storeDescription, error) in
     print(storeDescription)
     if let error = error as NSError? {
     fatalError("Unresolved error \(error), \(error)")
     }
     })
     return container
     }()*/
    
    let downloader = Downloader()
    
    lazy var persistentContainer: NSPersistentContainer = {
        //vytvoří container, který má pod sebou více vrstev core dat
        
        let container = NSPersistentContainer(name: "DataBaze")
        let seededData: String = "DataBaze"
        var persistentStoreDescriptions: NSPersistentStoreDescription
        
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        let storeUrl = URL(fileURLWithPath: documentDirectoryPath!).appendingPathComponent("DataBaze")
        
        /*
        //Přemazávání starých databázi v telefonu při aktualizaci databáze. Databáze z 25.7.2018 je označena jako databáze č. 2
        //Při další aktualizaci musím přepsat tento kôd tak, aby se Socka aktualizovala na vyšší databázi (trojku)
        if FileManager.default.fileExists(atPath: (storeUrl.path)) && (downloader.zjistiVerziDtbzVTelefonuUserDefaults() < 2){
            print("Přemazávám starou databázi.")
            do{
                try FileManager.default.removeItem(at: storeUrl)
            }catch{
                print("Nepodařilo se smazat starou databázi.")
            }
            downloader.zapisVerziDtbzDoUserDefaults(novaVerze: 2)
        }
        
        
        if !FileManager.default.fileExists(atPath: (storeUrl.path)) {
            //existuje uz na tom umisteni soubor DataFinal280417.sqlite?. Kdyz ne, tak:
            
            let seededDataUrl = Bundle.main.url(forResource: seededData, withExtension: "sqlite")
            //najde soubor sql v bundlu appky
            
            try! FileManager.default.copyItem(at: seededDataUrl!, to: storeUrl)
            print("Databaze zkopirovana")
            //zkopiruje tento soubor do slozky dokumentu do founu
        }
        
        
        //print(storeUrl)
        */
        //logne se na persistaent store = sql file
        container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: storeUrl)]
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                
                fatalError("Unresolved error \(error),")
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
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
}
