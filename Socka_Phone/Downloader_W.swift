import UIKit
import Alamofire

public class Downloader_W{
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
                
            } catch {
                // nedokážu se lognout na web a zjistit verzi
            }
        } else {
            print("Nedokážu se lognout na web a zjistit verzi")
            // the URL was bad!
        }
        return verzeNaWebu
    }
    
    func zjistiVerziDtbzVHodinkachUserDefaults() -> Int{
        let verze = UserDefaults.standard.integer(forKey: "verzeDtbzWatch")
        
        if verze > 0{
            return verze
        }else{
            zapisVerziDtbzDoUserDefaultsHodinek(novaVerze: 0)
            return 0
        }
    }
    
    func zapisVerziDtbzDoUserDefaultsHodinek(novaVerze: Int){
        UserDefaults.standard.set(novaVerze, forKey: "verzeDtbzWatch")
        print("Zapisuji novou verzi v hodinkách: ", novaVerze)
    }

}


