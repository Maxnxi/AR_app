//
//  ViewController.swift
//  AR_app
//
//  Created by Maksim on 11.02.2021.
//

import UIKit
import RealityKit

class ARVC: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the "Box" scene from the "Experience" Reality File
        let boxAnchor = try! Experience.loadBox()
        //let pizzaAnchor = try! Experience.piz
        // Add the box anchor to the scene
        arView.scene.anchors.append(boxAnchor)
    }
}
