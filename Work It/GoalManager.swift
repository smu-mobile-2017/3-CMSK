//
//  GoalManager.swift
//  Work It
//
//  Created by Paul Herz on --09-26.
//  Copyright © 2017 Paul Herz. All rights reserved.
//

import Foundation
import CoreMotion

class GoalManager {
	static var shared: GoalManager = GoalManager()
	static let recordKey: String = "workItStepRecord"
	static let goalKey: String = "workItStepGoal"
	static let goalDidChangeKey: NSNotification.Name = NSNotification.Name(rawValue: "edu.smu.workit.goalDidChange")
	static let passedGoalYesterdayDidChangeKey: NSNotification.Name = NSNotification.Name(rawValue: "edu.smu.workit.passedGoalYesterdayDidChange")
	
	lazy var pedometer: CMPedometer = CMPedometer()
	
	lazy var defaults: UserDefaults = UserDefaults.standard
	
	// Represents the user-defined step goal. Will be overwritten when the user
	// changes it in the UI. This does not impact how yesterday's steps are
	// compared to the goal, which is always tested at the start of the program.
	var stepGoal: Int? {
		get {
			let goal = defaults.integer(forKey: GoalManager.goalKey)
			// 0 denotes nothing returned.
			if goal == 0 {
				return nil
			}
			return goal
		}
		set {
			var data: [AnyHashable: Any] = [:]
			if let val = newValue { data = ["value": val] }
			if let goal = newValue {
				defaults.set(goal, forKey: GoalManager.goalKey)
			} else {
				defaults.removeObject(forKey: GoalManager.goalKey)
			}
			checkIfPassedGoalYesterday()
			NotificationCenter.default.post(
				name: GoalManager.goalDidChangeKey,
				object: self,
				userInfo: data
			)
		}
	}
	
	// by default, we assume nothing happened yesterday, which would
	// mean that the goal was not passed.
	var passedGoalYesterday: Bool = false {
		didSet {
			let data: [AnyHashable: Any] = ["value": passedGoalYesterday]
			NotificationCenter.default.post(
				name: GoalManager.passedGoalYesterdayDidChangeKey,
				object: self,
				userInfo: data
			)
		}
	}
	
	func checkIfPassedGoalYesterday() {
		// If the stored step record is from yesterday, do nothing
		let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
		
		guard let goal = stepGoal else { passedGoalYesterday = false; return }
		getPedometerData(forDay: yesterday) { data in
			guard let stepCount = data?.numberOfSteps.intValue else { return }
			print("stepCount: \(stepCount) >= \(goal)?")
			print((stepCount >= goal))
			self.passedGoalYesterday = (stepCount >= goal)
		}
	}
	
	func getPedometerData(from start: Date, to end: Date, block: @escaping (CMPedometerData?)->Void) {
		func handleStepCount(data: CMPedometerData?, error: Error?) {
			if let error = error {
				print("[GoalManager.handleStepCount] CoreMotion error: \(error)")
				return
			}
			block(data)
		}
		pedometer.queryPedometerData(from: start, to: end, withHandler: handleStepCount(data:error:))
	}
	
	func getPedometerData(forDay day: Date, block: @escaping (CMPedometerData?)->Void) {
		let dayAfter: Date = Calendar.current.date(byAdding: .day, value: 1, to: day)!
		let start: Date = Calendar.current.startOfDay(for: day)
		let end: Date = Calendar.current.startOfDay(for: dayAfter)
		getPedometerData(from: start, to: end, block: block)
	}
}
