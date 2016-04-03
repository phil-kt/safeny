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

class InitialViewController: UIViewController, GMSAutocompleteViewControllerDelegate {
    
    var startLatitude: String?
    var startLongitude: String?
    var endLatitude: String?
    var endLongitude: String?
    var encodedPolyline: String?
    var currentPlace: String?
    var destinationPlace: String?
    var lastTapped: String?

    @IBOutlet weak var currentView: UIView!
    @IBOutlet weak var currentLabel: UILabel!
    @IBOutlet weak var destinationView: UIControl!
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var directionsButton: UIControl!
    
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
                
                print(placeLikelihoods.likelihoods)
                
                self.currentLabel.text = placeLikelihoods.likelihoods[0].place.name
                
            }
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // Handle the user's selection.
    func viewController(viewController: GMSAutocompleteViewController, didAutocompleteWithPlace place: GMSPlace) {
        if (lastTapped == "current") {
            currentLabel.text = place.name
        }
        else {
            destinationLabel.text = place.name
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
        self.performSegueWithIdentifier("mapSegue", sender: sender)
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

