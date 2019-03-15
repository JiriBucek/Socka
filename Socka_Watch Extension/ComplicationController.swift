//
//  ComplicationController.swift
//  Socka Extension
//
//  Created by Boocha on 18.11.18.
//  Copyright © 2018 Boocha. All rights reserved.
//

import ClockKit

class ComplicationController: NSObject, CLKComplicationDataSource
{
    let zelena = UIColor().HexToColor(hexString: "008900", alpha: 1.0)
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void)
    {
        handler([])
    }
    
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void)
    {
        if complication.family == .circularSmall
        {
            
            let template = CLKComplicationTemplateCircularSmallRingImage()
            template.tintColor = zelena
            template.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "Complication/Circular")!)
            let timelineEntry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
            handler(timelineEntry)
            
        }
            
        else if #available(watchOSApplicationExtension 5.0, *), complication.family == .graphicCircular
        {
            
            let template = CLKComplicationTemplateGraphicCircularImage()
            template.imageProvider = CLKFullColorImageProvider(fullColorImage: UIImage(named: "Complication/Graphic Circular")!)
            let timelineEntry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
            handler(timelineEntry)
            
            
        }
        else if complication.family == .utilitarianSmall
        {
            
            let template = CLKComplicationTemplateUtilitarianSmallRingImage()
            template.tintColor = zelena
            template.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "Complication/Utilitarian")!)
            let timelineEntry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
            handler(timelineEntry)
            
        } else if complication.family == .modularSmall
        {
            
            let template = CLKComplicationTemplateModularSmallRingImage()
            template.tintColor = zelena
            template.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "Complication/Modular")!)
            let timelineEntry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
            handler(timelineEntry)
 
        } else {
            
            handler(nil)
            
        }
        
    }
    
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void)
    {
        switch complication.family
        {
        case .circularSmall:
            let image: UIImage = UIImage(named: "Complication/Circular")!
            let template = CLKComplicationTemplateCircularSmallSimpleImage()
            template.imageProvider = CLKImageProvider(onePieceImage: image)
            handler(template)
            
        case .utilitarianSmall:
            let image: UIImage = UIImage(named: "Complication/Utilitarian")!
            let template = CLKComplicationTemplateUtilitarianSmallSquare()
            template.imageProvider = CLKImageProvider(onePieceImage: image)
            handler(template)
        case .modularSmall:
            let image: UIImage = UIImage(named: "Complication/Modular")!
            let template = CLKComplicationTemplateModularSmallSimpleImage()
            template.imageProvider = CLKImageProvider(onePieceImage: image)
            handler(template)
 
        
        default:
            handler(nil)
        }
    }
    
}

