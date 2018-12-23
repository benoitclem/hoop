//
//  CirclesOverlay.swift
//  hoop
//
//  Created by Clément on 05/05/2017.
//  Copyright © 2017 the hoop company. All rights reserved.
//

import MapKit
import Foundation

func  MKMapRectForCoordinateRegion(region:MKCoordinateRegion ) -> MKMapRect {
    let a = MKMapPoint.init(CLLocationCoordinate2DMake(
        region.center.latitude + region.span.latitudeDelta / 2,
        region.center.longitude - region.span.longitudeDelta / 2
        ))
    let b = MKMapPoint.init(CLLocationCoordinate2DMake(
        region.center.latitude - region.span.latitudeDelta / 2,
        region.center.longitude + region.span.longitudeDelta / 2
        ))
    
    return MKMapRect(x: min(a.x,b.x), y: min(a.y,b.y), width: abs(a.x-b.x), height: abs(a.y-b.y));
}

class Circle: NSObject {
    var center: CLLocationCoordinate2D!
    var width: Double!
    var height: Double!
    //var radius: Double!
    
    init(center: CLLocationCoordinate2D, width: Double, height: Double) {
        super.init()
        self.center = center
        self.width = width
        self.height = height
        //self.radius = radius
    }
    
    var mapRect: MKMapRect {
        return MKMapRectForCoordinateRegion(region:  MKCoordinateRegion(center: self.center, latitudinalMeters: self.height, longitudinalMeters: self.width))
    }
}

class CirclesOverlay: NSObject, MKOverlay {
    var circles:[Circle]!
    var color: UIColor!
    
    init(withiCircles circles: [Circle], color: UIColor) {
        super.init()
        self.circles = circles
        self.color = color
    }
    
    var coordinate: CLLocationCoordinate2D {
        let bounds = self.boundingMapRect
        
        return MKMapPoint.init(CLLocationCoordinate2DMake(
            bounds.origin.x + bounds.size.width / 2.0,
            bounds.origin.y + bounds.size.height / 2.0
        )).coordinate
    }
    
    var boundingMapRect: MKMapRect{
        var bounds = MKMapRect.null;
        
        for circle in self.circles {
            bounds = bounds.union(circle.mapRect)
        }
        
        return bounds;
    }
}

class CirclesOverlayRenderer: MKOverlayPathRenderer {
    
    var circlesOverlay: CirclesOverlay!
    
    init(withCircleOverlay overlay: CirclesOverlay) {
        super.init(overlay: overlay)
        self.circlesOverlay = overlay
        self.fillColor = overlay.color.withAlphaComponent(0.1)
    }
    
    override func createPath() {
        let path = CGMutablePath()
        for circle in self.circlesOverlay.circles {
            path.addEllipse(in: self.rect(for: circle.mapRect))
        }
        self.path = path
    }
    
}
