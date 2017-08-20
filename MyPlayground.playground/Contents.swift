import UIKit


var verze = Int()

if let url = URL(string: "http://socka.funsite.cz/verze.htm") {
    do {
        let contents = try String(contentsOf: url)
        verze = (Int(contents) ?? 0)
    } catch {
        // contents could not be loaded
    }
} else {
    // the URL was bad!
}

print(verze)