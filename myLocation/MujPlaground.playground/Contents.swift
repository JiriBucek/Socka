//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

let array = ["trip_headsign": "Háje", "service_id": "9", "trip_id": "7022", "arrival_time": "181120", "stop_name": "Letňany", "stop_id": "U1000Z102"]

for (key, value) in array{
    
    if let cislo =  Int(value){
       print(key)
    }else{
        print("Tohle nepujde: \(key)")
    }
    
    
    
}