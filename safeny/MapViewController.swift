//
//  MapViewController.swift
//  safeny
//
//  Created by Philippe Kimura-Thollander on 4/2/16.
//  Copyright © 2016 Philippe Kimura-Thollander. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController {
    
    var start: CLLocationCoordinate2D!
    var end: CLLocationCoordinate2D!
    var encodedPolyline: String!
    var currentLocation: CLLocation?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        NSNotificationCenter.defaultCenter().addObserverForName("didUpdateLocationNotification", object: nil, queue: NSOperationQueue.mainQueue()) {(notification: NSNotification!) -> Void in
            let userInfo = notification.userInfo!
            self.currentLocation = userInfo["location"] as! CLLocation
        }
    
        let camera = GMSCameraPosition.cameraWithLatitude(start.latitude,
            longitude: start.longitude, zoom: 10)
        let mapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
        mapView.myLocationEnabled = true
        
        print(currentLocation)
        
        self.view = mapView

        let path = GMSPath(fromEncodedPath: encodedPolyline)
        let polyline = GMSPolyline(path: path)
        polyline.map = mapView
        
        let startMarker = GMSMarker()
        startMarker.position = start
        startMarker.title = "Start"
        startMarker.map = mapView
        
        let endMarker = GMSMarker()
        endMarker.position = end
        endMarker.title = "Destination"
        endMarker.map = mapView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
