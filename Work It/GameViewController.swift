//
//  GameViewController.swift
//  Work It
//
//  Created by Paul Herz on --09-27.
//  Copyright © 2017 Paul Herz. All rights reserved.
//

import UIKit
import SpriteKit
import CoreMotion

class GameViewController: UIViewController {
	
	@IBOutlet weak var skView: SKView!
	
	lazy var motionManager = CMMotionManager()
	var paddle: SKSpriteNode!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		print("Loaded game view")
		skView.scene?.isPaused = true
		skView.scene?.scaleMode = .resizeFill
		skView.scene?.physicsWorld.gravity = CGVector(dx: 0.0, dy: -5.0)
		
		paddle = skView.scene?.childNode(withName: "paddle") as? SKSpriteNode
		
		motionManager.accelerometerUpdateInterval = 0.05
		motionManager.startAccelerometerUpdates(to: .main, withHandler: handleAccelerometerData(data:error:))
    }
	
	override func viewWillAppear(_ animated: Bool) {
		print("Unpause")
		super.viewWillAppear(animated)
		skView.scene?.isPaused = false
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		print("Pause")
		super.viewWillDisappear(animated)
		skView.scene?.isPaused = true
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func handleAccelerometerData(data: CMAccelerometerData?, error: Error?) {
		guard error == nil else { print(error!); return }
		guard let data = data else { print("No accel data."); return }
		movePaddle(withAcceleration: data.acceleration)
	}
	
	func movePaddle(withAcceleration acceleration: CMAcceleration) {
		
		let ax: CGFloat = CGFloat(acceleration.x * 500.0)
		let x0: CGFloat = paddle.position.x
		
		let minX = skView.scene!.frame.minX + 0.5 * paddle.size.width
		let maxX = skView.scene!.frame.maxX - 0.5 * paddle.size.width
		
		let x1: CGFloat = max(min(x0+ax, maxX), minX)
		let action: SKAction = SKAction.moveTo(x: x1, duration: 0.05)
		paddle.removeAllActions()
		paddle.run(action)
	}

}
