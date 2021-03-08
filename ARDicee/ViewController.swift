//
//  ViewController.swift
//  ARDicee
//
//  Created by Hanna Putiprawan on 3/3/21.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    var diceArrray = [SCNNode]()
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.autoenablesDefaultLighting = true
        
        // Dots represent the surfae
//        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - Dice Rendering Methods
    
    // Touch is detected in the view
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first { // detect the location when user touches the screen
            let touchLocation = touch.location(in: sceneView)
            
            // Convert 2D location (phone screen) to 3D location (real world)
            if let query = sceneView.raycastQuery(from: touchLocation, allowing: .existingPlaneGeometry, alignment: .any) {
                let results = sceneView.session.raycast(query)
                if let hitResult = results.first {
                    addDice(atLocation: hitResult)
                }
            }
        }
    }
    
    private func addDice(atLocation location: ARRaycastResult) {
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        if let diceNode = scene.rootNode.childNode(withName: "Dice", recursively: true) {
            // + diceNode.boundingSphere.radius to elevate the dice up in y position so the dice is align with the plane not half dice
            diceNode.position = SCNVector3(x: location.worldTransform.columns.3.x,
                                           y: location.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                                           z: location.worldTransform.columns.3.z)
            diceArrray.append(diceNode)
            sceneView.scene.rootNode.addChildNode(diceNode)
            roll(dice: diceNode)
        }
    }
    
    private func roll(dice: SCNNode) {
        // Create a number between 1 to 4, rotate along x axis and have 4 faces showing
        // Float.pi/2 = 90 degrees; show new face on the top of the dice
        // No randomY because the dice doesn't change the face in Y axis
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        dice.runAction(SCNAction.rotateBy(x: CGFloat(randomX * 5),
                                              y: 0,
                                              z: CGFloat(randomZ * 5),
                                              duration: 0.5))
    }
    
    private func rollAll() {
        if !diceArrray.isEmpty {
            for dice in diceArrray {
                roll(dice: dice)
            }
        }
    }
    
    // Shake the phone
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        rollAll()
    }
    
    @IBAction func removeAllDice(_ sender: UIBarButtonItem) {
        if !diceArrray.isEmpty {
            for dice in diceArrray {
                dice.removeFromParentNode()
            }
        }
    }
    
    // MARK: - ARSCNViewDelegate Methods
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        let planeNode = createPlane(withPlaneAnchor: planeAnchor)
        node.addChildNode(planeNode)
    }
    
    // MARK: - Plane Rendering Methods
    private func createPlane(withPlaneAnchor planeAnchor: ARPlaneAnchor) -> SCNNode {
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x),
                             height: CGFloat(planeAnchor.extent.z))
        let planeNode = SCNNode() // vertical when created
        // y = 0; want it flat with the surface
        planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
        
        // Since the planeNode is default in vertical, we need to transform by rotated it 90 degrees to horizontal - flat
        // Rotating 90 degrees by 1PI rad = 180, so we need half PI radient to rotate to 90
        // Rotating clockwise by using negative
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        
        let gridMaterial = SCNMaterial()
        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
        plane.materials = [gridMaterial]
        planeNode.geometry = plane
        return planeNode
    }
}
