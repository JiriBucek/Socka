import UIKit

let timeFormatter = DateFormatter()
timeFormatter.dateFormat = "HH:mm:ss"
let time = "13:00:00"
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

let timeDifference = calendar.dateComponents([.minute, .second], from: stopTime!, to: date)