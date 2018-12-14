//
//  SockaBaseVC.swift
//  MHD APP
//
//  Created by Boocha on 14.12.18.
//  Copyright © 2018 Boocha. All rights reserved.
//

import Foundation
import UIKit


class SockaBaseVC: UIViewController{
    
    var aktualneZobrazovanaZastavka: String = "..."
    var device: String = "mobil"
    var triNejblizsiZastavky: Array = ["...", "...", "..."]
    var zastavkySwitch: Int = 0
    var metroData: MetroDataClass?
    
    
    override func viewDidLoad() {
        
        let lokace = Lokace()
        triNejblizsiZastavky = lokace.getTriNejblizsiZastavky()
        aktualneZobrazovanaZastavka = triNejblizsiZastavky[0]
        
        
    }
    
    func fillMetroDataObject(){
            metroData?.jmenoZastavky = aktualneZobrazovanaZastavka
        
            let databaze = Databaze()
            let fetchedData = databaze.fetchData(station_id: <#T##String#>, service_id: <#T##[Int]#>, results_count: <#T##Int#>, current_time: <#T##Int#>)
        
    }
    
    
    func getServiceId(day: Int) -> Int{
        //vrátí service ID pro daný den
        var service_id = Int()
        
        let date = Date()
        let calendar = Calendar.current
        var day = calendar.component(.weekday, from: date) - 1
        if day == 0{
            day = 7
        }
        
        switch day {
        case 1:
            service_id = 1
        case 2:
            service_id = 1
        case 3:
            service_id = 1
        case 4:
            service_id = 1
        case 5:
            service_id = 1
        case 6:
            service_id = 3
        case 7:
            service_id = 5
        default:
            print("Nepodařilo se získat service IDs")
        }
        return service_id
    }
    
    
    
    
}
