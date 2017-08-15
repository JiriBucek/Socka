import UIKit
public class Downloader {
    /*
    logne se na URL a zjisti aktualni verzi
    porovna ji s verzi v rtf souboru
    kdyz neni stejna, tak stahne novy sqlite soubor a nahradi jim stary
    */
    
    
    public init() {
        // Create destination URL
        let documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL!
        let destinationFileUrl = documentsUrl.appendingPathComponent("mujfile3.rtf")
        print(documentsUrl)
        
        //Create URL to the source file you want to download
        let fileURL = URL(string: "https://fq1bua.dm2301.livefilestore.com/y4mI3_oYs96nEf86cqz1YBa8YSM9hA36Cu-B2_sJKqc9aDxaf77qD45suE_x8q8fJLfhGhvrYWqayvEL3UXqpzrs7AywHyJQOD5CIStLL0OWb0Jkz2NxRzwrMB51qtKE50egqACGdmC6VfbP0E0zymJDkkZ4EaM-hcgkJxMNzqCNlayLb4U_6QWTGMeoJAR76Sv/soubor.rtf?download&psid=1")
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        let request = URLRequest(url:fileURL!)
        
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Successfully downloaded. Status code: \(statusCode)")
                }
                
                do {
                    try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                } catch (let writeError) {
                    print("Error creating a file \(destinationFileUrl) : \(writeError)")
                }
                
            } else {
                print("Error took place while downloading a file. Error description: %@", error?.localizedDescription);
            }
        }
        task.resume()
        
    }
}
