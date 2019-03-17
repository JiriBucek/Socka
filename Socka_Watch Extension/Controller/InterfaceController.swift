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
import Alamofire


var zastavkySwitch: Int = 0
// Globalni var pro prehazovani zastavky, pro kterou maji byt zobrazeny casove udaje.

var existujeNovaVerzeDTBZ = false
var prepinaciPomocnaZastavka = ""
var dtbzPopUpAlreadyShowed = false


class InterfaceController:  SockaWatchBaseVC{
    // Hlavní VC.
    
    let cervena = UIColor().HexToColor(hexString: "F30503", alpha: 1.0)
    let zluta = UIColor().HexToColor(hexString: "FFA100", alpha: 1.0)
    let zelena = UIColor().HexToColor(hexString: "008900", alpha: 1.0)
    
    lazy var hlavniBarva = zluta
    lazy var barva2 = zelena
    lazy var barva3 = cervena
    
    
    @IBOutlet var nearestZastavkaBtn: WKInterfaceButton!
    
    @IBOutlet var nearestZastavkaLabel: WKInterfaceLabel!
    
    @IBOutlet var nearestZastavkaGroup: WKInterfaceGroup!
    
    @IBAction func nearestZastavkaBtnPressed() {
        // Prepinani trech nejblizsich stanic
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
        // Každou sekundu updatuje funkci displayAllValue
    }
    
    override func willActivate() {
        super.willActivate()
        // Ukončí všechna probíhající stahování. Pouze pojistka.
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach { $0.cancel() }
            uploadData.forEach { $0.cancel() }
            downloadData.forEach { $0.cancel() }
        }
        
        if triNejblizsiZastavky.count > 0{
            prepinaciPomocnaZastavka = triNejblizsiZastavky[zastavkySwitch]
        }
    }
    
    override func didAppear(){
        if !dtbzPopUpAlreadyShowed{
            ukazUpgradePopUp()
        }
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
    
    @objc func displayAllValues(){
        // Zobrazuje hodnoty na screenu.
        triNejblizsiZastavkyPrepinaciArray = lokace.triNejblizsiZastavkyArray
        
        if triNejblizsiZastavkyPrepinaciArray != triNejblizsiZastavky{
            // Prepinac pro pripad, ze se zmeni poloha
            triNejblizsiZastavky = triNejblizsiZastavkyPrepinaciArray
            prepinaciPomocnaZastavka = triNejblizsiZastavky[0]
        }
        
        if prepinaciPomocnaZastavka != aktualneZobrazovanaZastavka{
            // Prepinac pro pripad zmeny polohy nebo prepnuti zastacky uzivatelem
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
    
    
    func nastavBarvy(jmenoZastavky: String){
        // Nastaví barvy dle aktuální linky metra.
        
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
    
    func ukazUpgradePopUp(){
        // Download pro novou databazi.
        
        Alamofire.request("http://socka.funsite.cz/verze.htm").responseString
            {response in
                if let verze = Int(response.value ?? "0"){
                    
                    if verze > self.databaze.zjistiVerziDtbzVDefaults(){
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
}
