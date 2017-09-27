//
//  ActivityViewController.swift
//  Work It
//
//  Created by Paul Herz on 9/26/17.
//  Copyright © 2017 Paul Herz. All rights reserved.
//

import UIKit
import CoreMotion

class ActivityViewController: UITableViewController {

	@IBOutlet weak var activityImageView: UIImageView!
	@IBOutlet weak var activityLabel: UILabel!
	@IBOutlet weak var stepCountLabel: UILabel!
	@IBOutlet weak var yesterdayStepCountLabel: UILabel!
	@IBOutlet weak var todayGoalLabel: UILabel!
	@IBOutlet weak var todayGoalProgressView: UIProgressView!
	
	@IBOutlet weak var gameButtonCell: UITableViewCell!
	@IBOutlet weak var gameButtonLabel: UILabel!
	
	lazy var activityManager: CMMotionActivityManager = CMMotionActivityManager()
	
	var stepCount: Int? = nil {
		didSet {
			// set stepCountLabel
			var text: String = "–"
			if let sc = stepCount { text = "\(sc)" }
			DispatchQueue.main.async {
				self.stepCountLabel.text = text
			}
			updateGoalUI(withGoal: GoalManager.shared.stepGoal)
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
		
		// listen for goal change from GoalManager
		NotificationCenter.default.addObserver(forName: GoalManager.goalDidChangeKey, object: nil, queue: nil) { notification in
			print("GoalManager.goalDidChangeKey observer triggered")
			let newGoal = notification.userInfo?["value"] as? Int
			self.updateGoalUI(withGoal: newGoal)
		}
		
		NotificationCenter.default.addObserver(forName: GoalManager.passedGoalYesterdayDidChangeKey, object: nil, queue: nil) { notification in
			print("GoalManager.passedGoalYesterdayDidChangeKey observer triggered")
			let newPassed = notification.userInfo?["value"] as? Bool
			self.updatePassedUI(withStatus: newPassed)
		}
		
		// Set "Today + Yesterday" steps
		GoalManager.shared.getPedometerData(from: startOfYesterday, to: Date()) { data in
			guard let stepCount = data?.numberOfSteps.intValue else { return }
			self.yesterdayStepCount = stepCount
		}
		
		// Initial retrieval of motion/activity data
		self.activityState = .unknown
		GoalManager.shared.getPedometerData(forDay: Date()) { data in
			guard let stepCount = data?.numberOfSteps.intValue else { return }
			self.stepCount = stepCount
		}
		
		// Recurring retrieval of motion/activity data (sporadic, based on new data)
		activityManager.startActivityUpdates(to: OperationQueue.current!) { data in
			self.activityState = ActivityState.from(coreMotionActivity: data)
		}
		GoalManager.shared.pedometer.startUpdates(from: startOfToday) { data, error in
			guard let stepCount = data?.numberOfSteps.intValue else { return }
			self.stepCount = stepCount
		}
    }
	
	func updateGoalUI(withGoal goal: Int?) {
		// Update the "Today's Goal" number
		// and the progress bar.
		
		var goalText: String = "No goal"
		var goalProgress: Float = 0.0
		
		if let goal = goal, let sc = stepCount {
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
	
	func updatePassedUI(withStatus passed: Bool?) {
		// Update the button that unlocks the game if
		// you've made your goal
		guard let passed = passed else {
			print("nil status passed as parameter in ActivityViewController.updatePassedUI.")
			return
		}
		var gameText = ""
		var enabled = false
		if passed {
			gameText = "You made your goal yesterday! Play a bonus game"
			enabled = true
		} else {
			gameText = "You'll get a reward whenver yesterday's steps beat your goal"
			enabled = false
		}
		DispatchQueue.main.async {
			self.gameButtonCell.isUserInteractionEnabled = enabled
			self.gameButtonCell.accessoryType = enabled ? .disclosureIndicator : .none
			self.gameButtonCell.selectionStyle = enabled ? .default : .none
			self.gameButtonLabel.isEnabled = enabled
			self.gameButtonLabel.text = gameText
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
