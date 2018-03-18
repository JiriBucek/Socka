   import UIKit
   
   
   let svatky = [[1,1],[18,3],[1,5],[8,5],[5,7],[6,7],[28,9],[28,10],[17,11],[24,12],[25,12],[26,12],[1,4]]
   let now = Date()
   let kalendar = Calendar.current
   let den = kalendar.component(.day, from: now)
   let mesic = kalendar.component(.month, from: now)
   let dnesniDen = [den, mesic]
   
   if svatky.contains(where: {$0 == dnesniDen}){
    print("Dnes je svátek")
   }else{
    print("NENE")
   }

