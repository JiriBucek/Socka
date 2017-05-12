import UIKit

var numbers = [1, 2, 3, 4]

let co = numbers.indices.contains(4)


let date = Date()
let calendar = Calendar.current
let day = calendar.component(.weekday, from: date)