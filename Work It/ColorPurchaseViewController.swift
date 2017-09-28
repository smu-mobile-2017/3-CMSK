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
    
    var nameColor = ["Red": UIColor.red,
                     "Yellow": UIColor.yellow,
                     "Orange": UIColor.orange,
                     "Green":UIColor.green,
                     "Cyan":UIColor.cyan,
                     "Blue":UIColor.blue,
                     "Pink":UIColor.magenta,
                     "Purple":UIColor.purple,
                     "White":UIColor.white]

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
    
    var color: String? =  "White" {
        didSet {
            var text = "White"
            if let sc = color{ text = "\(sc)"}
            DispatchQueue.main.async {
                self.selectedColor.text = text;
                guard let s = self.color else { return }
                self.selectedColor.textColor = self.nameColor[s]
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
        
        purpleButton.isUserInteractionEnabled = false;
        pinkButton.isUserInteractionEnabled = false;
        blueButton.isUserInteractionEnabled = false;
        cyanButton.isUserInteractionEnabled = false;
        greenButton.isUserInteractionEnabled = false;
        orangeButton.isUserInteractionEnabled = false;
        yellowButton.isUserInteractionEnabled = false;
        redButton.isUserInteractionEnabled = false;
        
        //guard let curr = stepCurrency else {return}
        let curr = 10001
        switch curr {
        case let curr where curr > 10000:
            purpleButton.isUserInteractionEnabled = true;
            fallthrough
        case 8001...10000:
            pinkButton.isUserInteractionEnabled = true;
            fallthrough
        case 7001...8000:
            blueButton.isUserInteractionEnabled = true;
            fallthrough
        case 6001...7000:
            cyanButton.isUserInteractionEnabled = true;
            fallthrough
        case 5001...6000:
            greenButton.isUserInteractionEnabled = true;
            fallthrough
        case 4001...5000:
            orangeButton.isUserInteractionEnabled = true;
            fallthrough
        case 3001...4000:
            yellowButton.isUserInteractionEnabled = true;
            fallthrough
        case 2001...3000:
            redButton.isUserInteractionEnabled = true;
            fallthrough
        default:
            break;
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
        dest.paddleColor = nameColor[c]
    }

}
