//
//  ActivityState.swift
//  Work It
//
//  Created by Paul Herz on --09-27.
//  Copyright © 2017 Paul Herz. All rights reserved.
//

import Foundation
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
