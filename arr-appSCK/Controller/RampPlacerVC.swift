//
//  RampPlacerVC.swift
//  arr-appSCK
//
//  Created by Maksim on 12.02.2021.
//

import UIKit
import SceneKit
import ARKit

class RampPlacerVC: UIViewController, ARSCNViewDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    var selectedRampName: String?
    var selectedRamp: SCNNode?
    
    @IBOutlet weak var controls: UIStackView!
    
    @IBOutlet weak var rotateBtn: UIButton!
    
    @IBOutlet weak var upBtn: UIButton!
    
    @IBOutlet weak var downBtn: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        
        //sceneView.showsStatistics = true
        let scene = SCNScene(named: "art.scnassets/main.scn")!
        sceneView.autoenablesDefaultLighting = true
        
        sceneView.scene = scene
        
        
        let gesture1 = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(gesture:)))
        let gesture2 = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(gesture:)))
        let gesture3 = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(gesture:)))
        gesture1.minimumPressDuration = 0.01
        gesture2.minimumPressDuration = 0.01
        gesture3.minimumPressDuration = 0.01
        rotateBtn.addGestureRecognizer(gesture1)
        upBtn.addGestureRecognizer(gesture2)
        downBtn.addGestureRecognizer(gesture3)
    }
    
    @objc func onLongPress(gesture: UILongPressGestureRecognizer) {
        if let ramp = selectedRamp {
            if gesture.state == .ended{
                ramp.removeAllActions()
            } else if gesture.state == .began {
                if gesture.view === rotateBtn {
                    let rotate = SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: CGFloat(0.08 * Double.pi), z: 0, duration: 0.1))
                    ramp.runAction(rotate)
                } else if gesture.view === upBtn {
                    let move = SCNAction.repeatForever(SCNAction.moveBy(x: 0, y:0.08, z: 0, duration: 0.01))
                    ramp.runAction(move)
                }else if gesture.view === downBtn {
                    let move = SCNAction.repeatForever(SCNAction.moveBy(x: 0, y:-0.08, z: 0, duration: 0.01))
                    ramp.runAction(move)
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let result = sceneView.hitTest(touch.location(in: sceneView), types: [.featurePoint])
        
        //[ARSCNView raycastQueryFromPoint:allowingTarget:alignment]
        
        //let result = sceneView.raycastQuery(from: touch.location(in: sceneView), allowing: .existingPlaneInfinite, alignment: .any)
        
        guard let hitFeature = result.last else {return}
        let hitTransform = SCNMatrix4(hitFeature.worldTransform)
        let hitPosition = SCNVector3Make(hitTransform.m41, hitTransform.m42, hitTransform.m43)
        placeRamp(position: hitPosition)
    }
    
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    
    
    @IBAction func onRampBtnWasPressed(_ sender: UIButton) {
        
        let rampPickerVC = RampPickerVC(size: CGSize(width: 250, height: 500))
        rampPickerVC.rampPlacerVC = self
        rampPickerVC.modalPresentationStyle = .popover
        rampPickerVC.popoverPresentationController?.delegate = self
        present(rampPickerVC, animated: true, completion: nil)
        rampPickerVC.popoverPresentationController?.sourceView = sender
        rampPickerVC.popoverPresentationController?.sourceRect = sender.bounds
    }
    
    func onRampSelected(_ rampName: String) {
        selectedRampName = rampName
        print("you selected - \(rampName)")
    }
    
    func placeRamp(position: SCNVector3) {
        controls.isHidden = false
        if let rampName = selectedRampName {
            let ramp = Ramp.getRampForName(rampName: rampName)
            selectedRamp = ramp
            ramp.position = position
            ramp.scale = SCNVector3Make(0.01, 0.01, 0.01)
            sceneView.scene.rootNode.addChildNode(ramp)
        }
    }
    
    @IBAction func onRemovePressed(_ sender: Any) {
    
        if let ramp = selectedRamp {
            ramp.removeFromParentNode()
            selectedRamp = nil
        }
    }
    
    
}
