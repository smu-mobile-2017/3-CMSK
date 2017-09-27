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
	
	let pedometer: CMPedometer = CMPedometer()
	
	// When the program starts, we check if yesterday's goal was fulfilled.
	// We:
	// (1) wipe any persistence entries that aren't yesterday
	// (2) check the persistence entry for yesterday, skip to (4) if exists.
	// (3) if one does not exist, create one:
	//     - marking it 'true' if yesterday's steps ≥ the goal
	//     - marking it 'false' otherwise.
	// (4) show the game if the entry is true.
	
	let defaults: UserDefaults = UserDefaults.standard
	
	// Represents the number of steps from yesterday, and whether they passed
	// the goal at the time. Erased if the date does not correspond to yesterday
	// at program start.
	var stepRecord: NSDictionary? {
		get {
			if let record = defaults.object(forKey: GoalManager.recordKey) as? NSDictionary {
				return record
			}
			return nil
		}
		set {
			if let record = newValue {
				defaults.set(record, forKey: GoalManager.recordKey)
			} else {
				defaults.removeObject(forKey: GoalManager.recordKey)
			}
		}
	}
	
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
			NotificationCenter.default.post(
				name: GoalManager.goalDidChangeKey,
				object: self,
				userInfo: data
			)
			if let goal = newValue {
				defaults.set(goal, forKey: GoalManager.goalKey)
			} else {
				defaults.removeObject(forKey: GoalManager.goalKey)
			}
		}
	}
	
	// by default, we assume nothing happened yesterday, which would
	// mean that the goal was not passed.
	var passedGoalYesterday: Bool = false {
		didSet {
			print("passedGoalYesterday didSet \(passedGoalYesterday)")
		}
	}
	
	func makeStepsRecord(date: Date, steps: Int, passed: Bool) -> NSDictionary {
		return NSDictionary(dictionary: [
			"date": date,
			"steps": NSNumber(value: steps),
			"passed": passed
		])
	}
	
	func performStartupActions() {
		// If the stored step record is from yesterday, do nothing
		let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())
		if
			let record = stepRecord,
			let date = record.value(forKey: "date") as? Date,
			date == yesterday,
			let passed = record.value(forKey: "passed") as? Bool
		{
			passedGoalYesterday = passed
			return
		}
		
		// dispose of the record (not from yesterday)
		stepRecord = nil
		generateYesterdayRecord { record in
			self.stepRecord = record
			guard let passed = record.value(forKey: "passed") as? Bool else {
				print("[performStartupActions] could not get key 'passed' from record.")
				return
			}
			self.passedGoalYesterday = passed
		}
	}
	
	func generateYesterdayRecord(callback: @escaping (NSDictionary) -> Void) {
		let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
		guard let goal = stepGoal else { return }
		getPedometerData(forDay: yesterday) { data in
			guard let stepCount = data?.numberOfSteps.intValue else { return }
			let passed = stepCount >= goal
			callback(self.makeStepsRecord(date: yesterday, steps: stepCount, passed: passed))
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
