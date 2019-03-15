//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

func parseCSV(){
    let path = Bundle.main.path(forResource: "stop_times male", ofType: "csv")
    do {
        let csv = try CSV(contentsOfURL: path!)
        let rows = csv.rows
        parse_to_dictionary(rows: rows)
    }catch{
        
    }
    
}


func parse_to_dictionary(rows: Array<Dictionary<String, String>>){
   for row in rows{
    for (key, value) in row{
        if key == "1"{
            print(value)
        }
    }
    }
    
    
}

parseCSV()
