import UIKit
public class Downloader {
    /*
    1. logne se na URL a zjisti aktualni verzi
    2. porovna ji s verzi v rtf souboru
    3. kdyz neni stejna, tak stahne novy sqlite soubor a nahradi jim stary
    */
    
    func zjistiVerziDtbzNaWebu() -> Int{
        //logne se na muj web a zjistí aktuální verzi dtbz na webu
        var verzeNaWebu = 0

        if let url = URL(string: "http://socka.funsite.cz/verze.htm") {
            //defaultní hodnota verze
            do {
                verzeNaWebu = try Int(String(contentsOf: url))!
                print(verzeNaWebu)
            } catch {
                // nedokážu se lognout na web a zjistit verzi
            }
        } else {
            print("Nedokážu se lognout na web a zjistit verzi")
            // the URL was bad!
        }
        return verzeNaWebu
    }
    
    
    func zjistiVerziDtbzVTelefonu() -> Int{
        //dokáže přečíst rtf file
        
        let slozkaDokumentu = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        let cestaKDokumentuSVerzi = URL(fileURLWithPath: slozkaDokumentu!).appendingPathComponent("verze.rtf")
        do{
        let attributedStringWithRtf:NSAttributedString = try NSAttributedString(url: cestaKDokumentuSVerzi, options: [NSDocumentTypeDocumentAttribute:NSRTFTextDocumentType], documentAttributes: nil)
            
            print(attributedStringWithRtf)
        }catch{
            
        }
        
        return 1
    }
    
    func zjistiVerziDtbzVTelefonuUserDefaults() -> Int{
        let verze = UserDefaults.standard.integer(forKey: "verzeDtbz")
        return verze
    }
    
    func zapisVerziDtbzDoUserDefaults(novaVerze: Int){
        UserDefaults.standard.set(novaVerze, forKey: "verzeDtbz")
    }
    
    
    
    
    func downloadAndSave(){
        //stáhne soubor z URL a uloží ho do složky dokumenty
        
        let documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL!
        let destinationFileUrl = documentsUrl.appendingPathComponent("mujfile3.rtf")
        //jmeno souboru, ktery se ulozi
        
        //Create URL to the source file you want to download
        let fileURL = URL(string: "https://fq1bua.dm2301.livefilestore.com/y4mI3_oYs96nEf86cqz1YBa8YSM9hA36Cu-B2_sJKqc9aDxaf77qD45suE_x8q8fJLfhGhvrYWqayvEL3UXqpzrs7AywHyJQOD5CIStLL0OWb0Jkz2NxRzwrMB51qtKE50egqACGdmC6VfbP0E0zymJDkkZ4EaM-hcgkJxMNzqCNlayLb4U_6QWTGMeoJAR76Sv/soubor.rtf?download&psid=1")
        //URL, ze ktereho stahuji
        
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
                print("Error took place while downloading a file. Error description: %@", error?.localizedDescription ?? "Error downloading");
            }
        }
        task.resume()
        
    }
}
