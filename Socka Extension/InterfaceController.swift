//
//  InterfaceController.swift
//  Socka Extension
//
//  Created by Boocha on 18.11.18.
//  Copyright © 2018 Boocha. All rights reserved. sfsf
//

import WatchKit
import Foundation
import UIKit
import CoreLocation
import CoreData
import Alamofire

extension UIColor{
    // rozšíření klasické UIColot, abych mohl zadávat rovnou HEX kod barvy
    func HexToColor(hexString: String, alpha:CGFloat? = 1.0) -> UIColor {
        // Convert hex string to an integer
        let hexint = Int(self.intFromHexString(hexStr: hexString))
        let red = CGFloat((hexint & 0xff0000) >> 16) / 255.0
        let green = CGFloat((hexint & 0xff00) >> 8) / 255.0
        let blue = CGFloat((hexint & 0xff) >> 0) / 255.0
        let alpha = alpha!
        // Create color object, specifying alpha as well
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return color
    }
    
    func intFromHexString(hexStr: String) -> UInt32 {
        var hexInt: UInt32 = 0
        // Create scanner
        let scanner: Scanner = Scanner(string: hexStr)
        // Tell scanner to skip the # character
        scanner.charactersToBeSkipped = NSCharacterSet(charactersIn: "#") as CharacterSet
        // Scan hex value
        scanner.scanHexInt32(&hexInt)
        return hexInt
    }
}

//MARK - global vars

var zastavkySwitch: Int = 0
// globalni var pro prehazovani zastavky, pro kterou maji byt zobrazeny casove udaje

var existujeNovaVerzeDTBZ = false
var prepinaciPomocnaZastavka = ""
var dtbzPopUpAlreadyShowed = false
//aby se dtbz alert neozobrazoval pořád dokola


class InterfaceController:  SockaWatchBaseVC{
    
    let cervena = UIColor().HexToColor(hexString: "F30503", alpha: 1.0)
    let zluta = UIColor().HexToColor(hexString: "FFA100", alpha: 1.0)
    let zelena = UIColor().HexToColor(hexString: "008900", alpha: 1.0)
    
    lazy var hlavniBarva = zluta
    lazy var barva2 = zelena
    lazy var barva3 = cervena
    
    let dl = Downloader_W()

    
    
    @IBOutlet var nearestZastavkaBtn: WKInterfaceButton!
    
    @IBOutlet var nearestZastavkaLabel: WKInterfaceLabel!
    
    @IBOutlet var nearestZastavkaGroup: WKInterfaceGroup!
    
    @IBAction func nearestZastavkaBtnPressed() {
        //prepinani trech nejblizsich stanic
        zastavkySwitch += 1
        if zastavkySwitch == 3{
            zastavkySwitch = 0
        }
        if triNejblizsiZastavky.count > 0{
            prepinaciPomocnaZastavka = triNejblizsiZastavky[zastavkySwitch]
        }
    }
    

    @IBOutlet var konecna1outlet: WKInterfaceLabel!
    @IBOutlet var konecna2outlet: WKInterfaceLabel!
    
    @IBOutlet var countdown1: WKInterfaceLabel!
    @IBOutlet var countdown2: WKInterfaceLabel!
    
    @IBOutlet var cas12: WKInterfaceLabel!
    
    @IBOutlet var cas22: WKInterfaceLabel!
    
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        dtbzPopUpAlreadyShowed = false
        
        printDocumentsDirectory()
        
        var _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(displayAllValues), userInfo: nil, repeats: true)
        //každou sekundu updatuje funkci displayAllValue
        
        //existujeNovaVerzeDTBZ = zjistiDostupnostNoveDatabaze()
        
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        
        super.willActivate()
        
        //ukončí všechna probíhající stahování. Pro případ, že se neukončí po stáhnutí dtbz
        
        
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach { $0.cancel() }
            uploadData.forEach { $0.cancel() }
            downloadData.forEach { $0.cancel() }
        }
        
        /*
        print("Dtbz na webu: ", dl.zjistiVerziDtbzNaWebu())
        print("Dtbz v hodinkách: ", dl.zjistiVerziDtbzVHodinkachUserDefaults())
        */
        
        
        if triNejblizsiZastavky.count > 0{
            prepinaciPomocnaZastavka = triNejblizsiZastavky[zastavkySwitch]
        }
        
        
    }
    
    
    override func didAppear(){
        
        
        if !dtbzPopUpAlreadyShowed{
        ukazUpgradePopUp()
        }
        
        //lokaceDostupnaPopUp()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    
    
    
    @objc func displayAllValues(){
        
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
            
            
            nearestZastavkaLabel.setText(aktualneZobrazovanaZastavka)
            
            //nearestZastavkaBtn.setTitle(aktualneZobrazovanaZastavka)
            nearestZastavkaGroup.setBackgroundColor(hlavniBarva)
            
            cas12.setText(timeDifference(arrivalTime: metroData.cas12!))
            countdown1.setText(timeDifference(arrivalTime: metroData.cas11!))
            countdown1.setTextColor(barva2)
            
            cas22.setText(timeDifference(arrivalTime: metroData.cas22!))
            countdown2.setText(timeDifference(arrivalTime: metroData.cas21!))
            countdown2.setTextColor(barva3)
            
            
            konecna1outlet.setText(metroData.konecna1)
            konecna1outlet.setTextColor(hlavniBarva)
            
            konecna2outlet.setText(metroData.konecna2)
            konecna2outlet.setTextColor(hlavniBarva)
            
            
            if myTimeDifference(to: metroData.cas11!) < 1 || myTimeDifference(to: metroData.cas21!) < 1{
                fillMetroDataObject()
            }
        }
        
    }
    
    func printDocumentsDirectory() {
        //Vypíše cestu do dokumentu
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        print("Dokument folder na hodinkach:  \(documentsDirectory)")
    }
    
    func zjistiDostupnostNoveDatabaze() -> Bool{
        let downloader = Downloader_W()
        let verzeVHodinakch = downloader.zjistiVerziDtbzVHodinkachUserDefaults()
        let verzeNaNetu = downloader.zjistiVerziDtbzNaWebu()
        
        print("Verze na netu: \(verzeNaNetu)")
        print("Verze v hodinkách \(verzeVHodinakch)")
        
        if verzeVHodinakch < verzeNaNetu{
            print("Je dostupná nová verze!!")
            return true
        }else{
            return false
        }
        
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

    //DOWNLOADER PRO NOVOU DATABAZI
    
    
    func ukazUpgradePopUp(){
        
        Alamofire.request("http://socka.funsite.cz/verze.htm").responseString
            {response in
                if let verze = Int(response.value ?? "0"){
                    
                    if verze > self.dl.zjistiVerziDtbzVHodinkachUserDefaults(){
                        let stahniClosure = {
                            self.dismiss()
                            self.pushController(withName: "downloadVC", context: nil)
                        }
                        
                        let action1 = WKAlertAction(title: "Stáhnout", style: .default, handler: stahniClosure)
                        let action2 = WKAlertAction(title: "Zrušit", style: .cancel) {}
                        
                        self.presentAlert(withTitle: "Nová databáze.", message: "Ke stažení jsou dostupné nové jízdní řády (cca 4MB).", preferredStyle: .actionSheet, actions: [action1,action2])
                    }
                    
                    dtbzPopUpAlreadyShowed = true
            
                }
            }
        
        
        
      
        
    }
    
    
    func lokaceDostupnaPopUp(){
        
        if CLLocationManager.locationServicesEnabled() {
            
            switch CLLocationManager.authorizationStatus() {
                
            case .notDetermined, .restricted, .denied:
                print("Lokalizace vypnuta!")
                
                let action1 = WKAlertAction(title: "Zrušit", style: .cancel){}
                
                presentAlert(withTitle: "GPS vypnuta.", message: "Zapni polohové služby pro Socku na svém iPhonu v Nastavení/Socka/Poloha/Vždy. Jinak nelze určit nejbližší zastávku metra.", preferredStyle: .actionSheet, actions: [action1])
                
            case .authorizedAlways, .authorizedWhenInUse:
                print("Lokalizační služby povoleny.")
                return
            }
            
        }else{
            let action1 = WKAlertAction(title: "Zrušit", style: .cancel){}
            
            presentAlert(withTitle: "GPS vypnuta.", message: "Zapni polohové služby na svém iPhonu v Nastavení/Soukromí/Polohové služby. Jinak nelze určit nejbližší zastávku metra.", preferredStyle: .actionSheet, actions: [action1])
            
        }
        
    }
    
    /*
    func stahniNovouDtbz(){
        print("Začínám stahovat.")
        let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: "backgroundSession")
        backgroundSession = Foundation.URLSession(configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: OperationQueue.main)
        let url = URL(string: "http://socka.funsite.cz/databaze")!
        downloadTask = backgroundSession.downloadTask(with: url)
        downloadTask.resume()
    }
    
    
    
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL){
        
        let documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as! URL
        let destinationFileUrlbezPripony = documentsUrl.appendingPathComponent("DataBaze")
        
        do{
            try FileManager.default.removeItem(at: destinationFileUrlbezPripony)
            try FileManager.default.copyItem(at: location, to: destinationFileUrlbezPripony)
            
            let downloader = Downloader_W()
            downloader.zapisVerziDtbzDoUserDefaultsHodinek(novaVerze: downloader.zjistiVerziDtbzNaWebu())
            
            let action1 = WKAlertAction(title: "Zpět", style: .cancel) {}
            presentAlert(withTitle: "Stahování dokončeno.", message: "Jízdní řády jsou aktuální.", preferredStyle: .actionSheet, actions: [action1])
            
        }catch{
            print("Error pri mazani a kopirování nové DTBZ", error)
        }
        
    }
    // 2
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64){
        
        print(totalBytesWritten)
        /*
        progressView.setProgress(Float(totalBytesWritten)/Float(totalBytesExpectedToWrite), animated: true)
        progressLabel.text = "\(Int(Float(totalBytesWritten)/Float(totalBytesExpectedToWrite) * 100)) %"
        */
    }
    
    //MARK: URLSessionTaskDelegate
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?){
        downloadTask = nil
        if (error != nil) {
            print(error!.localizedDescription)
        }else{
            print("Stahování v hodinkách dokončeno.")
            
            
        }
    }
    */
    
}
