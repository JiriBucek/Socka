//
//  ViewController.swift
//
//
//  Created by Boocha on 14.04.17.
//  Copyright © 2017 Boocha. All rights reserved.
//

import UIKit


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
    // Status bar barva.
        return .default
    }
    
    
    @objc func displayAllValues(){
    // Hodnoty pro všechny labely.
        
        triNejblizsiZastavkyPrepinaciArray = lokace.triNejblizsiZastavkyArray
        
        if triNejblizsiZastavkyPrepinaciArray != triNejblizsiZastavky{
        // Prepinac pro pripad, ze se zmeni poloha.
            triNejblizsiZastavky = triNejblizsiZastavkyPrepinaciArray
            prepinaciPomocnaZastavka = triNejblizsiZastavky[0]
        }
        
        if prepinaciPomocnaZastavka != aktualneZobrazovanaZastavka{
        // Prepinac pro pripad prepnuti zastavky uzivatelem.
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
    
    func nastavBarvy(jmenoZastavky: String){
        // Automaticky nastaví barevné schéma dle aktuální zastávky.
        
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
    
    func ukazUpgradeVC(){
    // Upgrade VC pro aktualizaci databaze.
        if isInternetAvailable() && zjistiDostupnostNoveDatabaze(){
        
        let currentVC = self.view.window?.rootViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "1") as! UpgradeViewController
        vc.view.isOpaque = false
        vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        
        currentVC?.present(vc, animated: true, completion: nil)
        }
    }
        
    func schovejSideView(){
    // Schová otevřené side view
        schovavaciSideViewTrailingConstraint.constant = -schovavaciSideView.frame.size.width - 100
        UIView.animate(withDuration: 0.3, animations: {
        self.view.layoutIfNeeded()
        })
    }
    
    
    func prepniNaPrestupniZastavku(zastavka: String){
    // Po kliknutí na prestupni zastavku v sideview schová menu a nastaví přestupní zastávka
        prepinaciPomocnaZastavka = zastavka
        zastavkySwitch = 2
        schovejSideView()
    }
    
}


