import UIKit
public class Downloader{
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
    
    func zjistiVerziDtbzVTelefonuUserDefaults() -> Int{
        let verze = UserDefaults.standard.integer(forKey: "verzeDtbz")
        return verze
    }
    
    func zapisVerziDtbzDoUserDefaults(novaVerze: Int){
        UserDefaults.standard.set(novaVerze, forKey: "verzeDtbz")
        print("Zapisuji novou verzi: ", novaVerze)
    }
    
}


