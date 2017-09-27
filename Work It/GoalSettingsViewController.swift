
//
//  GoalSettingsViewController.swift
//  Work It
//
//  Created by Paul Herz on --09-26.
//  Copyright © 2017 Paul Herz. All rights reserved.
//

import UIKit

class GoalSettingsViewController: UIViewController {

	@IBOutlet weak var goalLabel: UILabel!
	@IBOutlet weak var goalStepper: UIStepper!
	@IBOutlet weak var saveGoalButton: UIButton!
	@IBOutlet weak var clearGoalButton: UIButton!
	
	var unsavedStepGoal: Int? {
		didSet {
			DispatchQueue.main.async {
				self.saveGoalButton.isEnabled = true
			}
			
			var text = "No goal"
			var alpha = 0.5
			if let val = unsavedStepGoal {
				DispatchQueue.main.async {
					self.clearGoalButton.isEnabled = true
				}
				text = "\(val)"
				alpha = 1.0
			}
			DispatchQueue.main.async {
				self.goalLabel.text = "\(text)"
				self.goalLabel.alpha = CGFloat(alpha)
			}
		}
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		unsavedStepGoal = GoalManager.shared.stepGoal
		
		DispatchQueue.main.async {
			if let val = self.unsavedStepGoal {
				self.goalStepper.value = Double(val)
			} else {
				self.goalStepper.value = self.goalStepper.minimumValue
			}
		}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	@IBAction func didChangeStepperValue(_ sender: UIStepper) {
		unsavedStepGoal = Int(sender.value)
	}
	
	@IBAction func didPressClearGoalButton(_ sender: Any) {
		DispatchQueue.main.async {
			self.clearGoalButton.isEnabled = false
			self.goalStepper.value = self.goalStepper.minimumValue
		}
		unsavedStepGoal = nil
	}
	
	@IBAction func didPressSaveGoalButton(_ sender: Any) {
		print("**********\nSaving step goal (\(unsavedStepGoal))\n**********")
		GoalManager.shared.stepGoal = unsavedStepGoal
		DispatchQueue.main.async {
			self.saveGoalButton.isEnabled = false
		}
	}
	
	
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
