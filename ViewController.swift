//
//  ViewController.swift
//  calculator
//
//  Created by Руслан Ольховка on 04.02.15.
//  Copyright (c) 2015 Руслан Ольховка. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{

    @IBOutlet weak var history: UILabel!
    @IBOutlet weak var display: UILabel!
    
    lazy var brain = CalculatorBrain()

    var userIsInMiddleOfTyping = false
    
    @IBAction func digitIsPressed(sender: UIButton) {
        var digit = sender.currentTitle!
        if userIsInMiddleOfTyping {
            switch digit {
            case "ᐩ/-": toggleNegativeOrPositive()
            case ".": if display.text!.rangeOfString(".") == nil { fallthrough }
            default: display.text! += digit
            }
        } else {
            switch digit {
            case "ᐩ/-": if display.text! != "0" { toggleNegativeOrPositive() }
            case "0": break
            case ".": digit = "0."; fallthrough
            default: display.text = digit
            userIsInMiddleOfTyping = true
            }
        }
    }
    
    func toggleNegativeOrPositive() {
        display.text = display.text!.hasPrefix("-") ? dropFirst(display.text!) : "-" + display.text!
    }
    
    @IBAction func operate(sender: UIButton) {
        if userIsInMiddleOfTyping {
            enter()
        }
        if let operation = sender.currentTitle {
            if let result = brain.performOperation(operation) {
                displayValue = result 
            }
            else {
                displayValue = 0
            }
        }
        history.text = brain.description
    }

    var displayValue: Double? {
        get {
            let number = NSNumberFormatter().numberFromString(display.text!)
            return number == nil ? nil : number!.doubleValue
        }
        set {
            if let value = newValue {
                let text = "\(value)"
                display.text = text.hasSuffix(".0") ? dropLast(dropLast(text)) : text
            }
            else {
                display.text = ""
            }
        }
    }
    
    @IBAction func enter() {
        userIsInMiddleOfTyping = false
        if let result = brain.pushOperand(displayValue!) {
            displayValue = result
        }
        else {
            displayValue = 0
        }
        history.text = brain.description
    }
    
    @IBAction func clear() {
        display.text = "0"
        userIsInMiddleOfTyping = false
        brain.clear()
        history.text = " "
    }
    
    @IBAction func backspace() {
        if userIsInMiddleOfTyping {
            if let value = display.text {
                switch countElements(value) {
                case 1: display.text = "0"
                case 2: display.text = value.hasPrefix("-") ? "0" : dropLast(value)
                case 3: display.text = value == "-0." ? "0" : dropLast(value)
                default: display.text = dropLast(value)
                }
                userIsInMiddleOfTyping = display.text != "0"
            }
        }
    }
}

