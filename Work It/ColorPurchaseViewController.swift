//
//  ColorPurchaseViewController.swift
//  Work It
//
//  Created by Jake Rowland on 9/27/17.
//  Copyright © 2017 Paul Herz. All rights reserved.
//

import UIKit
import CoreMotion

struct unlock {
    var color: UIColor
    var cost: Int
}

class ColorPurchaseViewController: UIViewController {
    
    @IBOutlet weak var stepCurrencyLabel: UILabel!
    
    @IBOutlet weak var selectedColor: UILabel!

    @IBOutlet var colorButton: [UIButton]!
    
    var nameColor = ["Red": unlock(color:UIColor.red, cost:2000),
                     "Yellow": unlock(color:UIColor.yellow, cost:3000),
                     "Orange": unlock(color:UIColor.orange, cost:4000),
                     "Green": unlock(color:UIColor.green, cost:5000),
                     "Cyan": unlock(color:UIColor.cyan, cost:6000),
                     "Blue": unlock(color:UIColor.blue, cost:7000),
                     "Pink": unlock(color:UIColor.magenta, cost:8000),
                     "Purple": unlock(color:UIColor.purple, cost:10000),
                     "White": unlock(color:UIColor.white, cost:0)]

    @IBOutlet weak var playButton: UIButton!
    
    var stepCurrency: Int? = nil {
        didSet {
            var text = "-"
            if let sc = stepCurrency{ text = "\(sc)"}
            DispatchQueue.main.async {
                self.stepCurrencyLabel.text = text;
                
                //For each button. If enough steps to puchase. Make clickable and not grayed.
                //If not enough to puchase. Gray out
                for button in self.colorButton {
                    guard let id = button.restorationIdentifier else {return}
                    
                    //If cost is nil, make everything cost 2000 steps
                    let cost = self.nameColor[id]?.cost ?? 2000
                    //If avaliable currency is nil, no currency is avaliable
                    let currency = self.stepCurrency ?? 0
                    if(currency > cost) {
                        button.isUserInteractionEnabled = true;
                        button.alpha = 1
                    } else {
                        button.isUserInteractionEnabled = false;
                        button.alpha = 0.4
                    }
                }
                
            }
        }
    }
    
    var color: String? =  "White" {
        didSet {
            var text = "White"
            if let sc = color{ text = "\(sc)"}
            DispatchQueue.main.async {
                self.selectedColor.text = text;
                guard let s = self.color else { return }
                self.selectedColor.textColor = self.nameColor[s]?.color
                
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

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didPressRedButton(_ sender: Any) {
        guard let senderView = sender as? UIView,
            let id = senderView.restorationIdentifier else {return}
        color = id;
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let dest = segue.destination as? GameViewController else {return}
        guard let c = color else {return}
        dest.paddleColor = nameColor[c]?.color
    }

}
