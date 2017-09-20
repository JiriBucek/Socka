//
//  Data_pool.swift
//  myLocation
//
//  Created by Boocha on 03.05.17.
//  Copyright © 2017 Boocha. All rights reserved.
//

import Foundation

let stations_ids = ["Nádraží Holešovice": ["U115Z101", "U115Z102", "C"], "Hloubětín": ["U135Z101", "U135Z102", "B"], "Černý Most": ["U897Z101", "U897Z102", "B"], "Můstek - A": ["U1072Z101", "U1072Z102", "A"], "Staroměstská": ["U703Z101", "U703Z102", "A"], "I. P. Pavlova": ["U190Z101", "U190Z102", "C"], "Radlická": ["U957Z101", "U957Z102", "B"], "Želivského": ["U921Z101", "U921Z102", "A"], "Nemocnice Motol": ["U306Z101", "U306Z102", "A"], "Stodůlky": ["U1140Z101", "U1140Z102", "B"], "Florenc - B": ["U689Z101", "U689Z102", "B"], "Prosek": ["U603Z101", "U603Z102", "C"], "Českomoravská": ["U510Z101", "U510Z102", "B"], "Muzeum - A": ["U400Z101", "U400Z102", "A"], "Jiřího z Poděbrad": ["U209Z101", "U209Z102", "A"], "Roztyly": ["U601Z101", "U601Z102", "C"], "Budějovická": ["U50Z101", "U50Z102", "C"], "Náměstí Míru": ["U476Z101", "U476Z102", "A"], "Kobylisy": ["U675Z101", "U675Z102", "C"], "Nové Butovice": ["U602Z101", "U602Z102", "B"], "Střížkov": ["U332Z101", "U332Z102", "C"], "Bořislavka": ["U157Z101", "U157Z102", "A"], "Zličín": ["U1141Z101", "U1141Z102", "B"], "Křižíkova": ["U758Z101", "U758Z102", "B"], "Opatov": ["U106Z101", "U106Z102", "C"], "Pankrác": ["U385Z101", "U385Z102", "C"], "Vyšehrad": ["U527Z101", "U527Z102", "C"], "Depo Hostivař": ["U1071Z101", "U1071Z102", "A"], "Hradčanská": ["U163Z101", "U163Z102", "A"], "Národní třída": ["U539Z101", "U539Z102", "B"], "Rajská zahrada": ["U818Z101", "U818Z102", "B"], "Skalka": ["U953Z101", "U953Z102", "A"], "Smíchovské nádraží": ["U458Z101", "U458Z102", "B"], "Náměstí Republiky": ["U480Z101", "U480Z102", "B"], "Můstek - B": ["U1072Z121", "U1072Z122", "B"], "Hlavní nádraží": ["U142Z101", "U142Z102", "C"], "Kačerov": ["U228Z101", "U228Z102", "C"], "Karlovo náměstí": ["U237Z101", "U237Z102", "B"], "Letňany": ["U1000Z101", "U1000Z102", "C"], "Pražského povstání": ["U597Z101", "U597Z102", "C"], "Chodov": ["U52Z101", "U52Z102", "C"], "Muzeum - C": ["U400Z121", "U400Z122", "C"], "Vltavská": ["U100Z101", "U100Z102", "C"], "Vysočanská": ["U474Z101", "U474Z102", "B"], "Nádraží Veleslavín": ["U462Z101", "U462Z102", "A"], "Malostranská": ["U360Z101", "U360Z102", "A"], "Luka": ["U1007Z101", "U1007Z102", "B"], "Háje": ["U286Z101", "U286Z102", "C"], "Ládví": ["U78Z101", "U78Z102", "C"], "Petřiny": ["U507Z101", "U507Z102", "A"], "Kolbenova": ["U75Z101", "U75Z102", "B"], "Flora": ["U118   Z101", "U118Z102", "A"], "Hůrka": ["U1154Z101", "U1154Z102", "B"], "Anděl": ["U1040Z101", "U1040Z102", "B"], "Dejvická": ["U321Z101", "U321Z102", "A"], "Florenc - C": ["U689Z121", "U689Z122", "C"], "Invalidovna": ["U655Z101", "U655Z102", "B"], "Lužiny": ["U258Z101", "U258Z102", "B"], "Strašnická": ["U713Z101", "U713Z102", "A"], "Palmovka": ["U529Z101", "U529Z102", "B"]]

let zastavky = ["Depo Hostivař": [50.075541, 14.51532], "Skalka": [50.068435, 14.507169], "Strašnická": [50.073336, 14.490091], "Želivského": [50.07854, 14.474891], "Flora": [50.078288, 14.461886], "Jiřího z Poděbrad": [50.077642, 14.45004], "Náměstí Míru": [50.075398, 14.439078], "Muzeum - A": [50.079847, 14.430577], "Můstek - A": [50.083943, 14.424149], "Staroměstská": [50.088454, 14.417066], "Malostranská": [50.092176, 14.409101], "Hradčanská": [50.097671, 14.402535], "Dejvická": [50.100481, 14.392462], "Bořislavka": [50.098319, 14.36212], "Nádraží Veleslavín": [50.09551, 14.348419], "Petřiny": [50.086608, 14.345018], "Nemocnice Motol": [50.074985, 14.340497], "Zličín": [50.052798, 14.291152], "Stodůlky": [50.046716, 14.307241], "Luka": [50.045365, 14.321854], "Lužiny": [50.044515, 14.331143], "Hůrka": [50.050026, 14.343495], "Nové Butovice": [50.050856, 14.35285], "Radlická": [50.057942, 14.388403], "Smíchovské nádraží": [50.061797, 14.409112], "Anděl": [50.07049, 14.404878], "Karlovo náměstí": [50.074808, 14.417579], "Národní třída": [50.080209, 14.420439], "Můstek - B": [50.083609, 14.423983], "Náměstí Republiky": [50.088974, 14.43128], "Florenc - B": [50.090437, 14.438362], "Křižíkova": [50.092627, 14.452043], "Invalidovna": [50.096976, 14.463824], "Palmovka": [50.10417, 14.475436], "Českomoravská": [50.106302, 14.492291], "Vysočanská": [50.110167, 14.501728], "Kolbenova": [50.110331, 14.517115], "Hloubětín": [50.106531, 14.537062], "Rajská zahrada": [50.106935, 14.561205], "Černý Most": [50.109058, 14.577538], "Letňany": [50.126314, 14.515926], "Prosek": [50.119166, 14.498572], "Střížkov": [50.12713, 14.488199], "Ládví": [50.126655, 14.468806], "Kobylisy": [50.124005, 14.453577], "Nádraží Holešovice": [50.108534, 14.440372], "Vltavská": [50.099847, 14.438426], "Florenc - C": [50.089619, 14.438892], "Hlavní nádraží": [50.083115, 14.433785], "Muzeum - C": [50.079861, 14.431276], "I. P. Pavlova": [50.073871, 14.430295], "Vyšehrad": [50.062681, 14.430482], "Pražského povstání": [50.056508, 14.433761], "Pankrác": [50.050601, 14.439927], "Budějovická": [50.044052, 14.449283], "Kačerov": [50.041696, 14.459939], "Roztyly": [50.037425, 14.477329], "Chodov": [50.031392, 14.491431], "Opatov": [50.027915, 14.509895], "Háje": [50.03081, 14.527675],]


let seznamStanic = ["Nemocnice Motol", "Petřiny", "Nádraží Veleslavín", "Bořislavka", "Dejvická", "Hradčanská","Malostranská" ,"Staroměstská", "Můstek - A", "Muzeum - A", "Náměstí Míru", "Jiřího z Poděbrad", "Flora", "Želivského", "Strašnická", "Skalka", "Depo Hostivař", "Zličín", "Stodůlky", "Luka", "Lužiny", "Hůrka", "Nové Butovice", "Radlická", "Smíchovské nádraží", "Anděl", "Karlovo náměstí", "Národní třída", "Můstek - B", "Náměstí Republiky", "Florenc - B", "Křižíkova", "Invalidovna", "Palmovka", "Českomoravská", "Vysočanská", "Kolbenova", "Hloubětín", "Rajská zahrada", "Černý Most", "Háje", "Opatov", "Chodov", "Roztyly", "Kačerov", "Budějovická", "Pankrác", "Pražského povstání", "Vyšehrad", "I. P. Pavlova", "Muzeum - C", "Hlavní nádraží", "Florenc - C", "Vltavská", "Nádraží Holešovice", "Kobylisy", "Ládví", "Střížkov", "Prosek", "Letňany"]


let linka_A = ["Nemocnice Motol", "Petřiny", "Nádraží Veleslavín", "Bořislavka", "Dejvická", "Hradčanská","Malostranská" ,"Staroměstská", "Můstek - A", "Muzeum - A", "Náměstí Míru", "Jiřího z Poděbrad", "Flora", "Želivského", "Strašnická", "Skalka", "Depo Hostivař"]

let linka_B = ["Zličín", "Stodůlky", "Luka", "Lužiny", "Hůrka", "Nové Butovice", "Radlická", "Smíchovské nádraží", "Anděl", "Karlovo náměstí", "Národní třída", "Můstek - B", "Náměstí Republiky", "Florenc - B", "Křižíkova", "Invalidovna", "Palmovka", "Českomoravská", "Vysočanská", "Kolbenova", "Hloubětín", "Rajská zahrada", "Černý Most"]

let linka_C = ["Háje", "Opatov", "Chodov", "Roztyly", "Kačerov", "Budějovická", "Pankrác", "Pražského povstání", "Vyšehrad", "I. P. Pavlova", "Muzeum - C", "Hlavní nádraží", "Florenc - C", "Vltavská", "Nádraží Holešovice", "Kobylisy", "Ládví", "Střížkov", "Prosek", "Letňany"]

