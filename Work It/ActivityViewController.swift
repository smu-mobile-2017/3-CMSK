//
//  ActivityViewController.swift
//  Work It
//
//  Created by Paul Herz on 9/26/17.
//  Copyright © 2017 Paul Herz. All rights reserved.
//

import UIKit
import CoreMotion

enum ActivityState {
	case unknown, stationary, cycling, running, walking, driving
	
	static func from(coreMotionActivity data: CMMotionActivity?) -> ActivityState? {
		guard let data = data else {
			return nil
		}
		if data.unknown {
			return .unknown
		} else if data.stationary {
			return .stationary
		} else if data.automotive {
			return .driving
		} else if data.cycling {
			return .cycling
		} else if data.running {
			return .running
		} else if data.walking {
			return .walking
		} else {
			return .unknown
		}
	}
}

class ActivityViewController: UITableViewController {

	@IBOutlet weak var activityImageView: UIImageView!
	@IBOutlet weak var activityLabel: UILabel!
	@IBOutlet weak var stepCountLabel: UILabel!
	@IBOutlet weak var yesterdayStepCountLabel: UILabel!
	@IBOutlet weak var todayGoalLabel: UILabel!
	@IBOutlet weak var todayGoalProgressView: UIProgressView!
	
	let pedometer: CMPedometer = CMPedometer()
	let activityManager: CMMotionActivityManager = CMMotionActivityManager()
	
	var stepCount: Int? = nil {
		didSet {
			// set stepCountLabel
			var text: String = "–"
			if let sc = stepCount { text = "\(sc)" }
			DispatchQueue.main.async {
				self.stepCountLabel.text = text
			}
			
			// set todayGoalLabel and -progressView
			var goalText: String = "No goal"
			var goalProgress: Float = 0.0
			
			if let goal = GoalManager.shared.stepGoal, let sc = stepCount {
				let remaining = goal - sc
				let step = abs(remaining)==1 ? "step" : "steps"
				
				goalText = remaining > 0 ? "\(remaining) \(step) to goal" : "\(abs(remaining)) \(step) past goal"
				goalProgress = min(Float(sc)/Float(goal), 1.0)
			}
			DispatchQueue.main.async {
				self.todayGoalLabel.text = goalText
				self.todayGoalProgressView.progress = goalProgress
			}
		}
	}
	
	var yesterdayStepCount: Int? = nil {
		didSet {
			var text = "–"
			if let ysc = yesterdayStepCount { text = "\(ysc)" }
			DispatchQueue.main.async {
				self.yesterdayStepCountLabel.text = text
			}
		}
	}
	
	var activityState: ActivityState? = nil {
		didSet {
			guard let activityState = activityState else {
				activityLabel.text = "–"
				activityImageView.image = UIImage()
				return
			}
			guard let iv = self.activityImageView, let l = self.activityLabel else {
				return
			}
			DispatchQueue.main.async {
				let (image,text) = self.imageAndText(for: activityState)
				iv.image = image
				l.text = text
			}
		}
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		let startOfToday: Date = Calendar.current.startOfDay(for: Date())
		
		let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())
		let startOfYesterday: Date = Calendar.current.startOfDay(for: yesterday!)
		
		// Set "Today + Yesterday" steps
		pedometer.queryPedometerData(
			from: startOfYesterday,
			to: Date(),
			withHandler: handleYesterdayPedometerData(data:error:)
		)
		
		// Initial retrieval of motion/activity data
		handleActivityData(data: nil)
		
		pedometer.queryPedometerData(
			from: startOfToday,
			to: Date(),
			withHandler: handlePedometerData(data:error:)
		)
		
		// Recurring retrieval of motion/activity data (sporadic, based on new data)
		activityManager.startActivityUpdates(
			to: OperationQueue.current!,
			withHandler: handleActivityData(data:)
		)
		pedometer.startUpdates(
			from: startOfToday,
			withHandler: handlePedometerData(data:error:)
		)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func handlePedometerData(data: CMPedometerData?, error: Error?) {
		if let error = error {
			print("CoreMotion Error: \(error)")
			return
		}
		guard let data = data else {
			print("No data")
			return
		}
		
		stepCount = data.numberOfSteps.intValue
	}
	
	func handleYesterdayPedometerData(data: CMPedometerData?, error: Error?) {
		if let error = error {
			print("CoreMotion Error: \(error)")
			return
		}
		guard let data = data else {
			print("No data")
			return
		}
		yesterdayStepCount = data.numberOfSteps.intValue
	}
	
	func handleActivityData(data: CMMotionActivity?) {
		activityState = ActivityState.from(coreMotionActivity: data)
	}
	
	func imageAndText(for activityState: ActivityState) -> (UIImage?, String) {
		switch activityState {
		case .unknown:
			return (UIImage(named: "activity-unknown"), "Unknown")
		case .stationary:
			return (UIImage(named: "activity-stationary"), "Stationary")
		case .cycling:
			return (UIImage(named: "activity-cycling"), "Cycling")
		case .running:
			return  (UIImage(named: "activity-running"), "Running")
		case .walking:
			return (UIImage(named: "activity-walking"), "Walking")
		case .driving:
			return (UIImage(named: "activity-driving"), "Driving")
		}
	}

}
