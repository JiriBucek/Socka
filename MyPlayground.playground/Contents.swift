import UIKit


if let url = URL(string: "http://socka.funsite.cz/verze.htm") {
    do {
        let contents = try String(contentsOf: url)
        print(contents)
    } catch {
        // contents could not be loaded
    }
} else {
    // the URL was bad!
}

