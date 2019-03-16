//
//  ViewController.swift
//
//
//  Created by Boocha on 14.04.17.
//  Copyright © 2017 Boocha. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import SystemConfiguration
import Alamofire


var zastavkySwitch: Int = 0
// Globalni var pro prehazovani zastavky, pro kterou maji byt zobrazeny casove udaje.
var existujeNovaVerzeDTBZ = false
var prepinaciPomocnaZastavka = ""


class ViewController: SockaBaseVC{
    // Hlavní VC.
    
    let cervena = UIColor().HexToColor(hexString: "F30503", alpha: 1.0)
    let zluta = UIColor().HexToColor(hexString: "FFA100", alpha: 1.0)
    let zelena = UIColor().HexToColor(hexString: "008900", alpha: 1.0)
    
    lazy var hlavniBarva = zluta
    lazy var barva2 = zelena
    lazy var barva3 = cervena
    
    // Outlety.
    @IBOutlet weak var nearestZastavkaButton: UIButton!
    
    @IBAction func nearestZastavkaButtonPressed(_ sender: Any) {
        // Prepinani trech nejblizsich stanic.
        zastavkySwitch += 1
        if zastavkySwitch == 3{
            zastavkySwitch = 0
        }
        if triNejblizsiZastavky.count > 0{
            prepinaciPomocnaZastavka = triNejblizsiZastavky[zastavkySwitch]
        }
    }
    
    @IBOutlet weak var schovavaciSideView: UIView!
    
    @IBAction func swipeDoprava(_ sender: UISwipeGestureRecognizer) {
        schovejSideView()
    }
    
    @IBAction func mustekABtn(_ sender: Any) {
        prepniNaPrestupniZastavku(zastavka: "Můstek - A")
    }
    @IBAction func mustekBBtn(_ sender: Any) {
        prepniNaPrestupniZastavku(zastavka: "Můstek - B")
    }
    @IBAction func muzeumABtn(_ sender: Any) {
        prepniNaPrestupniZastavku(zastavka: "Muzeum - A")
    }
    @IBAction func muzeumCBtn(_ sender: Any) {
        prepniNaPrestupniZastavku(zastavka: "Muzeum - C")
    }
    @IBAction func florencBBtn(_ sender: Any) {
        prepniNaPrestupniZastavku(zastavka: "Florenc - B")
    }
    @IBAction func florencCBtn(_ sender: Any) {
        prepniNaPrestupniZastavku(zastavka: "Florenc - C")
    }
    
    @IBAction func zavriSideviewBtn(_ sender: Any) {
       schovejSideView()
    }
    @IBOutlet weak var zavriSideViewOutletBtn: UIButton!
    
    @IBAction func oAplikaciBtn(_ sender: Any) {
        
    }

    @IBAction func sideMenuBtn(_ sender: Any) {
        schovavaciSideViewTrailingConstraint.constant = 0
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
            })
    }
    
    @IBAction func menuBtn(_ sender: Any) {
        schovavaciSideViewTrailingConstraint.constant = 0
    }
    
    @IBOutlet weak var schovavaciSideViewTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var sideMenuMensiView: UIView!
    @IBOutlet weak var cas11: UILabel!
    @IBOutlet weak var cas21: UILabel!
    
    @IBOutlet weak var countdown1: UILabel!
    @IBOutlet weak var countdown2: UILabel!
    
    @IBOutlet weak var konecna1outlet: UILabel!
    @IBOutlet weak var konecna2outlet: UILabel!
    
    @IBOutlet weak var dalsiZastavkaLabel11: UILabel!
    @IBOutlet weak var dalsiZastavkaLabel12: UILabel!
    @IBOutlet weak var dalsiZastavkaLabel13: UILabel!
    
    @IBOutlet weak var dalsiZastavkaLabel21: UILabel!
    @IBOutlet weak var dalsiZastavkaLabel22: UILabel!
    @IBOutlet weak var dalsiZastavkaLabel23: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Side menu.
        let sirkaObrazovky = schovavaciSideView.frame.size.width
        schovavaciSideViewTrailingConstraint.constant = -sirkaObrazovky - 100
        sideMenuMensiView.layer.shadowOpacity = 1
        sideMenuMensiView.layer.shadowRadius = 6
        
        // Nastaví font na buttonu hlavní zastávky
        nearestZastavkaButton.titleLabel?.minimumScaleFactor = 0.2
        nearestZastavkaButton.titleLabel?.numberOfLines = 1
        nearestZastavkaButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        // Každou sekundu volá funkci displayAllValue
        var _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(displayAllValues), userInfo: nil, repeats: true)
        
        print(getDocumentsDirectory())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        jeDnesSvatek()
        ukazUpgradeVC()
    
        if isAppAlreadyLaunchedOnce(){
            checkLocationEnabled()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
    //vybarví status bar nahoře
        return .default
    }
    
    
    @objc func displayAllValues(){
    //přiřadí hodnoty jednotlivým labelum
        
        triNejblizsiZastavkyPrepinaciArray = lokace.triNejblizsiZastavkyArray
        
        if triNejblizsiZastavkyPrepinaciArray != triNejblizsiZastavky{
        //prepinac pro pripad, ze se zmeni poloha
            triNejblizsiZastavky = triNejblizsiZastavkyPrepinaciArray
            prepinaciPomocnaZastavka = triNejblizsiZastavky[0]
        }
        
        if prepinaciPomocnaZastavka != aktualneZobrazovanaZastavka{
        //prepinac pro pripad zmeny polohy nebo prepnuti zastacky uzivatelem
            aktualneZobrazovanaZastavka = prepinaciPomocnaZastavka
            fillMetroDataObject()
        }
        
        if metroData.cas11 != nil && metroData.nextZastavka11 != nil{
        
            nastavBarvy(jmenoZastavky: aktualneZobrazovanaZastavka)
            
            nearestZastavkaButton.setTitle(aktualneZobrazovanaZastavka, for: .normal)
            nearestZastavkaButton.setTitleColor(hlavniBarva, for: .normal)
            
            cas11.text = timeDifference(arrivalTime: metroData.cas12!)
            countdown1.text = timeDifference(arrivalTime: metroData.cas11!)
            countdown1.textColor = barva2
            
            cas21.text = timeDifference(arrivalTime: metroData.cas22!)
            countdown2.text = timeDifference(arrivalTime: metroData.cas21!)
            countdown2.textColor = barva3
            
            konecna1outlet.text = metroData.konecna1
            konecna1outlet.textColor = hlavniBarva
            
            konecna2outlet.text = metroData.konecna2
            konecna2outlet.textColor = hlavniBarva
            
            dalsiZastavkaLabel11.text = metroData.nextZastavka11
            dalsiZastavkaLabel11.textColor = hlavniBarva
            dalsiZastavkaLabel12.text = metroData.nextZastavka12
            dalsiZastavkaLabel12.textColor = hlavniBarva
            dalsiZastavkaLabel13.text = metroData.nextZastavka13
            dalsiZastavkaLabel13.textColor = hlavniBarva
            
            dalsiZastavkaLabel21.text = metroData.nextZastavka21
            dalsiZastavkaLabel21.textColor = hlavniBarva
            dalsiZastavkaLabel22.text = metroData.nextZastavka22
            dalsiZastavkaLabel22.textColor = hlavniBarva
            dalsiZastavkaLabel23.text = metroData.nextZastavka23
            dalsiZastavkaLabel23.textColor = hlavniBarva
        
            if myTimeDifference(to: metroData.cas11!) < 1 || myTimeDifference(to: metroData.cas21!) < 1{
                fillMetroDataObject()
            }
        }
        }
    
    func formatTime(time: Int) -> String{
    //vezme cas v INT a preklopi ho do stringu s dvojteckama
        var time = String(describing: time)
        
        while time.count < 5{
            let index = time.startIndex
            time.insert("0", at: index)
        }
        
        let index = time.index(time.endIndex, offsetBy: -2)
        time.insert(":", at: index)
        let index2 = time.index(time.endIndex, offsetBy: -5)
        time.insert(":", at: index2)

        return time
    }
    

    func getDocumentsDirectory() -> URL {
        //Vypíše cestu do dokumentu
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    
    func myTimeDifference(to targetTime: Int) -> Int{
    //spočitá rozdíl mezi časem metra a současným časem
        let time = targetTime - current_time()
        return time
    }
    
    func rozdilCasuTypuDate(datum1: Date, datum2: Date) -> Int{
        //vrati rozdil dvou objektu typu Date v sekundach
        let datum1prevedeno = datum1.timeIntervalSince1970
        let datum2prevedeno = datum2.timeIntervalSince1970
        return Int(datum1prevedeno - datum2prevedeno)
    }
    
    func timeDifference(arrivalTime: Int) -> String {
    //odpočítávadlo času ... vezme si Int ve formátu 153421 a dopočítává, kolik zbývá minut a sekund do toho času
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        //velke hacka znamenaji, ze misto 4pm budu mit 16:00
        
        let time = formatTime(time: arrivalTime)
        var stopTime = timeFormatter.date(from: time)
    
        let date = Date()
        let calendar = Calendar.current
    
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let hour = calendar.component(.hour, from: stopTime!)
        let minute = calendar.component(.minute, from: stopTime!)
        let second = calendar.component(.second, from: stopTime!)
    
        stopTime = calendar.date(bySetting: .year, value: year, of: stopTime!)
        stopTime = calendar.date(bySetting: .month, value: month, of: stopTime!)
        stopTime = calendar.date(bySetting: .day, value: day, of: stopTime!)
        stopTime = calendar.date(bySetting: .hour, value: hour, of: stopTime!)
        stopTime = calendar.date(bySetting: .minute, value: minute, of: stopTime!)
        stopTime = calendar.date(bySetting: .second, value: second, of: stopTime!)
    
        let timeDifference = calendar.dateComponents([.minute, .second], from: date, to: stopTime!)
        //spočítá časový rozdíl mezi from a to
        var minuty = String(describing: timeDifference.minute!)
        var sekundy = String(describing: timeDifference.second!)
    
        if Int(minuty)! < -1000{
        //úprava kvůli přepočtu přes půlnoc, aby to neukazovalo minusove casy
            minuty = String(Int(minuty)! + 1439)
            sekundy = String(59 + Int(sekundy)!)
            }

        if sekundy.count == 1{
        //přihodí nulu, pokud sekundy mají jen jeden znak
                let index = sekundy.startIndex
                sekundy.insert("0", at: index)
        }
    
        return "\(minuty):\(sekundy)"
    }
    
    func nastavBarvy(jmenoZastavky: String){
        if let metroLinka = zastavkyIDs[jmenoZastavky]?[2]{
            switch metroLinka {
            case "A":
                hlavniBarva = zelena
                barva2 = zluta
                barva3 = cervena
            case "B":
                hlavniBarva = zluta
                barva2 = cervena
                barva3 = zelena
            case "C":
                hlavniBarva = cervena
                barva2 = zelena
                barva3 = zluta
            default:
                print("Nepodařilo se určit barvu")
            }
        }
    }
    
    func zjistiDostupnostNoveDatabaze() -> Bool{
        let verzeVtelefonu = databaze.zjistiVerziDtbzVDefaults()
        let verzeNaNetu = databaze.zjistiVerziDtbzNaWebu()
        
        if verzeVtelefonu < verzeNaNetu{
            print("Je dostupná nová verze!")
            return true
        }else{
            return false
        }
    }
    
    func ukazUpgradeVC(){
    //vyskoci okynko s vystrahou, ze je nova verze dtbz
        if isInternetAvailable() && zjistiDostupnostNoveDatabaze(){
        
        let currentVC = self.view.window?.rootViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "1") as! UpgradeViewController
        vc.view.isOpaque = false
        vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        
        currentVC?.present(vc, animated: true, completion: nil)
        }
    }
        
    
    func isInternetAvailable() -> Bool {
    //checkne, jestli jsem pripojenej k netu
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
    
    func schovejSideView(){
    //schová otevřené side view
        schovavaciSideViewTrailingConstraint.constant = -schovavaciSideView.frame.size.width - 100
        UIView.animate(withDuration: 0.3, animations: {
        self.view.layoutIfNeeded()
        })
    }
    
    
    func prepniNaPrestupniZastavku(zastavka: String){
    //po kliknutí na prestupni zastavku v sideview schová menu a nastaví přestupní zastávka
        prepinaciPomocnaZastavka = zastavka
        zastavkySwitch = 2
        schovejSideView()
    }
    
    
    func jeDnesSvatek(){
    //zjití, zda je tento den státní svátek a pokud ano, vyhodí o tom hlášku
        var svatek = false
        
        let svatky = [[1,1],[30,3],[1,5],[8,5],[5,7],[6,7],[28,9],[28,10],[17,11],[24,12],[25,12],[26,12],[1,4]]
        let now = Date()
        let kalendar = Calendar.current
        let den = kalendar.component(.day, from: now)
        let mesic = kalendar.component(.month, from: now)
        let dnesniDen = [den, mesic]
        
        if svatky.contains(where: {$0 == dnesniDen}){
            print("Dnes je svátek")
            svatek = true
        }else{
            svatek = false
        }
        
        if svatek{
             let alertSvatky = UIAlertController(title: "Dnes je svátek.", message: "Ve dnech svátků je možné, že se časy odjezdu metra budou lišit. Tyto změny není možné ošetřit offline databází. Děkuji za pochopení", preferredStyle: .alert)
        
            alertSvatky.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alertSvatky, animated: true)
        }
        
    }
    
    func checkLocationEnabled() {
        //zkontroluje zapnutí polohových služeb. Ty mohou být vypnuty konkrétně pro Socku nebo globálně
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
                
                case .notDetermined, .restricted, .denied:
                    print("Lokalizace pro Socku vypnuta!")
                    
                    let alert = UIAlertController(title: "Lokalizační služby nedostupné", message: "Máš vypnuty lokalizační služby, bez nichž nemůže Socka určit tvou polohu a nejbližší zastávku metra. Zapni je prosím v Nastavení/Socka/Poloha/", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
                        self.dismiss(animated: true, completion: nil)
                    }
                    ))
                
                     self.present(alert, animated: true, completion: nil)
                
                case .authorizedAlways, .authorizedWhenInUse:
                    print("Lokalizační služby povoleny.")
            }
        }else{
            let alert = UIAlertController(title: "Lokalizační služby nedostupné", message: "Máš vypnuty lokalizační služby, bez nichž nemůže Socka určit tvou polohu a nejbližší zastávku metra. Zapni je prosím v Nastavení/Soukromí/Polohové služby/", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
                self.dismiss(animated: true, completion: nil)
            }
            ))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
}


