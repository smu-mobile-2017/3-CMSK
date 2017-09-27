//
//  GoalManager.swift
//  Work It
//
//  Created by Paul Herz on --09-26.
//  Copyright © 2017 Paul Herz. All rights reserved.
//

import Foundation

struct StepRecord {
	let date: Date
	let steps: Int
	let passed: Bool
}

class GoalManager {
	static var shared: GoalManager = GoalManager()
	static let recordKey: String = "workItStepRecord"
	static let goalKey: String = "workItStepGoal"
	
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
	var stepRecord: StepRecord? {
		get {
			if let record = defaults.object(forKey: GoalManager.recordKey) as? StepRecord {
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
			if let goal = newValue {
				defaults.set(goal, forKey: GoalManager.goalKey)
			} else {
				defaults.removeObject(forKey: GoalManager.goalKey)
			}
		}
	}
}
