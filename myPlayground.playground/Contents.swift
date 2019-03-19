import UIKit

var str = "240321"


if str.prefix(2) == "24"{
    str = String(str.dropFirst(2))
    str = "00" + str
    print(str)
}
