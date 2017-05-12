import UIKit

var numbers = [1, 2, 3, 4]

let co = numbers.indices.contains(4)


let date = Date()
let calendar = Calendar.current
let day = calendar.component(.weekday, from: date)


var neco = "111"

neco.characters.count

while neco.characters.count < 5{
    let index = neco.startIndex
    neco.insert("0", at: index)
}

print(neco)
