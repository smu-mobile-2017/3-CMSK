//
//  ColorPurchaseViewController.swift
//  Work It
//
//  Created by Jake Rowland on 9/27/17.
//  Copyright © 2017 Paul Herz. All rights reserved.
//

import UIKit
import CoreMotion

class ColorPurchaseViewController: UIViewController {
    
    @IBOutlet weak var stepCurrencyLabel: UILabel!
    
    @IBOutlet weak var selectedColor: UILabel!
    
    @IBOutlet weak var redButton: UIButton!
    @IBOutlet weak var yellowButton: UIButton!
    @IBOutlet weak var orangeButton: UIButton!
    @IBOutlet weak var greenButton: UIButton!
    @IBOutlet weak var cyanButton: UIButton!
    @IBOutlet weak var blueButton: UIButton!
    @IBOutlet weak var pinkButton: UIButton!
    @IBOutlet weak var purpleButton: UIButton!
    
    var colorList: [String] = ["Red","Yellow","Orange","Green","Cyan","Blue","Pink","Purple"]

    @IBOutlet weak var playButton: UIButton!
    
    var stepCurrency: Int? = nil {
        didSet {
            var text = "-"
            if let sc = stepCurrency{ text = "\(sc)"}
            DispatchQueue.main.async {
                self.stepCurrencyLabel.text = text;
            }
        }
    }
    
    var color: String? = nil {
        didSet {
            var text = "None"
            if let sc = color{ text = "\(sc)"}
            DispatchQueue.main.async {
                self.selectedColor.text = text;
                switch text {
                case self.colorList[0]:
                    self.selectedColor.textColor = UIColor.red
                    break;
                case self.colorList[1]:
                    self.selectedColor.textColor = UIColor.yellow
                    break;
                case self.colorList[2]:
                    self.selectedColor.textColor = UIColor.orange
                    break;
                case self.colorList[3]:
                    self.selectedColor.textColor = UIColor.green
                    break;
                case self.colorList[4]:
                    self.selectedColor.textColor = UIColor.cyan
                    break;
                case self.colorList[5]:
                    self.selectedColor.textColor = UIColor.blue
                    break;
                case self.colorList[6]:
                    self.selectedColor.textColor = UIColor.magenta
                    break;
                case self.colorList[7]:
                    self.selectedColor.textColor = UIColor.purple
                    break;
                default:
                    self.selectedColor.textColor = UIColor.white
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        
        GoalManager.shared.getPedometerData(forDay: yesterday) { data in
            guard let stepCount = data?.numberOfSteps.intValue else { return }
            self.stepCurrency = stepCount
        }
        
        selectedColor.text = "TEST"
        
        purpleButton.isUserInteractionEnabled = false;
        pinkButton.isUserInteractionEnabled = false;
        blueButton.isUserInteractionEnabled = false;
        cyanButton.isUserInteractionEnabled = false;
        greenButton.isUserInteractionEnabled = false;
        orangeButton.isUserInteractionEnabled = false;
        yellowButton.isUserInteractionEnabled = false;
        redButton.isUserInteractionEnabled = false;
        
        guard let curr = stepCurrency else { return }
        switch 10001 {
        case let val where val > 10000:
            purpleButton.isUserInteractionEnabled = true;
        case let val where val > 8000:
            pinkButton.isUserInteractionEnabled = true;
        case let val where val > 7000:
            blueButton.isUserInteractionEnabled = true;
        case let val where val > 6000:
            cyanButton.isUserInteractionEnabled = true;
        case let val where val > 5000:
            greenButton.isUserInteractionEnabled = true;
        case let val where val > 4000:
            orangeButton.isUserInteractionEnabled = true;
        case let val where val > 3000:
            yellowButton.isUserInteractionEnabled = true;
        case let val where val > 2000:
            redButton.isUserInteractionEnabled = true;
        default:
            break;
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
