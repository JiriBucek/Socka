import UIKit
public class Downloader: NSObject, URLSessionDownloadDelegate{
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
    
    
    /* ČTENÍ Z RTF SOUBORU
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
 
    */
    
    func zjistiVerziDtbzVTelefonuUserDefaults() -> Int{
        let verze = UserDefaults.standard.integer(forKey: "verzeDtbz")
        print("spusteno")
        return verze
    }
    
    func zapisVerziDtbzDoUserDefaults(novaVerze: Int){
        print("spusteno2")
        UserDefaults.standard.set(novaVerze, forKey: "verzeDtbz")
    }
    
    
    func downloadAndSave(){
        //stáhne soubor z URL a uloží ho do složky dokumenty
        print("Spusteno3")
        
        let documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL!
        let destinationFileUrlbezPripony = documentsUrl.appendingPathComponent("DataFinal280417")
        //jmeno souboru, ktery se ulozi
        
        //Create URL to the source file you want to download
        let fileURL = URL(string: "http://socka.funsite.cz/databaze")
        //URL, ze ktereho stahuji
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: OperationQueue.main)
        
        let request = URLRequest(url:fileURL!)
        
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Successfully downloaded. Status code: \(statusCode)")
                }
                
                do {
                    try FileManager.default.removeItem(at: destinationFileUrlbezPripony)
                    try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrlbezPripony)
                } catch (let writeError) {
                    print("Error creating a file \(destinationFileUrlbezPripony) : \(writeError)")
                }
                
            } else {
                print("Error took place while downloading a file. Error description: %@", error?.localizedDescription ?? "Error downloading");
            }
        }
        task.resume()
        
    }
 
    // 1
    public func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL){
                     }
    // 2
    public func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64){
        
        print(totalBytesExpectedToWrite)
        print(totalBytesWritten)
        //progressView.setProgress(Float(totalBytesWritten)/Float(totalBytesExpectedToWrite), animated: true)
}

}


