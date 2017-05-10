
import CoreData
import UIKit


class CoreDataStack {
    
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
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "DataFinal280417")
        
        let seededData: String = "DataFinal280417"
        var persistentStoreDescriptions: NSPersistentStoreDescription
        
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        let storeUrl = URL(fileURLWithPath: documentDirectoryPath!).appendingPathComponent("DataFinal280417")
        
        //let storeUrl = self.applicationDocumentsDirectory.appendingPathComponent("app_name.sqlite")
        
        if !FileManager.default.fileExists(atPath: (storeUrl.path)) {
            let seededDataUrl = Bundle.main.url(forResource: seededData, withExtension: "sqlite")
            try! FileManager.default.copyItem(at: seededDataUrl!, to: storeUrl)
            
        }
        
        print(storeUrl)
        
        
        container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: storeUrl)]
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                
                fatalError("Unresolved error \(error),")
            }
        })
        
        return container
        
        
    }()
    
    func saveContext() {
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
