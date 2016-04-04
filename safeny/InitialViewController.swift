//
//  InitialViewController.swift
//  safeny
//
//  Created by Philippe Kimura-Thollander on 4/2/16.
//  Copyright © 2016 Philippe Kimura-Thollander. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import SwiftyJSON
import Alamofire

class InitialViewController: UIViewController, GMSAutocompleteViewControllerDelegate {
    
    var startLatitude: String?
    var startLongitude: String?
    var endLatitude: String?
    var endLongitude: String?
    var encodedPolyline: String?
    var currentPlace: GMSPlace?
    var destinationPlace: GMSPlace?
    var lastTapped: String?

    @IBOutlet weak var currentView: UIView!
    @IBOutlet weak var currentLabel: UILabel!
    @IBOutlet weak var destinationView: UIControl!
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var directionsButton: UIControl!
    @IBOutlet weak var directionsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        currentView.layer.cornerRadius = 7
        destinationView.layer.cornerRadius = 7
        directionsButton.layer.cornerRadius = 7
        
        
        startLatitude = "40.7284942"
        startLongitude = "-73.9953536"
        endLatitude = "40.7480285"
        endLongitude = "-73.98487709999999"
        encodedPolyline = "axqwF|esbMx@p@mB{A][yEwDyD_DbAkDnCwIn@iCLQ`E_MdC{HeCzHaE~LMPo@hCiCi@UA]BcFu@_G_AoAOgA?oBPs@~BSb@CHC@Ib@S`@OH[Dm@Ak@OMEKVgEqCu@g@MEuCa@SGa@KmB]_JaBmCe@a@O_B[]CS?MDKJYSiAu@{FsDyBwAoNiJmD{B"
        
        let placesClient = GMSPlacesClient()
        
        placesClient.currentPlaceWithCallback({ (placeLikelihoods, error) -> Void in
            guard error == nil else {
                print("Current Place error: \(error!.localizedDescription)")
                return
            }
            
            if let placeLikelihoods = placeLikelihoods {
                self.currentLabel.text = placeLikelihoods.likelihoods[0].place.name
                self.currentPlace = placeLikelihoods.likelihoods[0].place
            }
        })
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.directionsLabel.text = "get me there safely"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // Handle the user's selection.
    func viewController(viewController: GMSAutocompleteViewController, didAutocompleteWithPlace place: GMSPlace) {
        if (lastTapped == "current") {
            currentLabel.text = place.name
            currentPlace = place
        }
        else {
            destinationLabel.text = place.name
            destinationPlace = place
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func viewController(viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: NSError) {
        // TODO: handle the error.
        print("Error: ", error.description)
    }
    
    // User canceled the operation.
    func wasCancelled(viewController: GMSAutocompleteViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func onCurrentLocation(sender: AnyObject) {
        // Present the Autocomplete view controller when the button is pressed.
        lastTapped = "current"
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        self.presentViewController(autocompleteController, animated: true, completion: nil)
    }

    @IBAction func onDestinationLocation(sender: AnyObject) {
        // Present the Autocomplete view controller when the button is pressed.
        lastTapped = "destination"
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        self.presentViewController(autocompleteController, animated: true, completion: nil)

    }
    
    @IBAction func onGetThere(sender: AnyObject) {
        
        let src = currentPlace!.name.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
        let dest = destinationPlace!.name.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
        let url = "http://www.varunsayal.com:5000/getCoordinates?source=" + src! + "&destination=" + dest!
        Alamofire.request(.GET, url)
            .validate()
            .progress { bytesWritten, totalBytesWritten, totalBytesExpectedToWrite in
                dispatch_async(dispatch_get_main_queue()) {
                    self.directionsButton.enabled = false
                    UIView.performWithoutAnimation {
                        self.directionsLabel.text = "working on it..."
                    }
                }
                            }
            .response{ request, response, data, error in
                let json = JSON(data: data!)
                if (json == nil) {
                    let alertController = UIAlertController(title: "Bummer!", message:
                        "Couldn't find a route! Might I suggest an Uber?", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.Default,handler: nil))
                    self.directionsLabel.text = "sorry :("
                    self.presentViewController(alertController, animated: true, completion: nil)

                }
                else {
                    if let polyline = json["polyline"].string {
                        self.encodedPolyline = polyline
                    }
                    if let startLat = (json["start"]["lat"]).string {
                        self.startLatitude = startLat
                    }
                    if let startLong = (json["start"]["long"]).string {
                        self.startLongitude = startLong
                    }
                    if let endLat = (json["end"]["lat"]).string {
                        self.endLatitude = endLat
                    }
                    if let endLong = (json["end"]["long"]).string {
                        self.endLongitude = endLong
                    }
                
                    self.directionsLabel.text = "got it!"
            
                    self.performSegueWithIdentifier("mapSegue", sender: sender)
                }
                
                self.directionsButton.enabled = true

                
        }
    
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "mapSegue") {
            // initialize new view controller and cast it as your view controller
            let mapController = segue.destinationViewController as! MapViewController
            // your new view controller should have property that will store passed value
            let startLocation = CLLocation(latitude: Double(startLatitude!)!, longitude: Double(startLongitude!)!)
            let endLocation = CLLocation(latitude: Double(endLatitude!)!, longitude: Double(endLongitude!)!)
            
            mapController.start = startLocation.coordinate
            mapController.end = endLocation.coordinate
            mapController.encodedPolyline = self.encodedPolyline
            
        }
    }
}

