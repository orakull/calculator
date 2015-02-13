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
        switch sender.currentTitle! {
        case "×":   performOperation(sender.currentTitle!, { $0 * $1 })
        case "÷":   performOperation(sender.currentTitle!, { $1 / $0 })
        case "+":   performOperation(sender.currentTitle!, { $0 + $1 })
        case "−":   performOperation(sender.currentTitle!, { $1 - $0 })
        case "√":   performOperation(sender.currentTitle!, { sqrt($0) })
        case "sin": performOperation(sender.currentTitle!, { sin($0) })
        case "cos": performOperation(sender.currentTitle!, { cos($0) })
        case "π":   performOperation(M_PI)
        default: break
        }
    }
    
    func performOperation(sign: String, operation: (Double, Double) -> Double) {
        if operandStack.count >= 2 {
            history.text = sign + "  " + history.text!
            displayValue = operation(operandStack.removeLast(), operandStack.removeLast())
            enter()
        }
    }
    
    func performOperation(sign: String, operation: (Double) -> Double) {
        if operandStack.count >= 1 {
            history.text = sign + "  " + history.text!
            displayValue = operation(operandStack.removeLast())
            enter()
        }
    }
    
    func performOperation(const: Double) {
        if userIsInMiddleOfTyping { enter() }
        displayValue = const
        enter()
    }

    var operandStack = Array<Double>()
    
    var displayValue: Double? {
        get {
            let number = NSNumberFormatter().numberFromString(display.text!)
            return number == nil ? nil : number!.doubleValue
        }
        set {
            display.text = "\(newValue!)"
        }
    }
    
    @IBAction func enter() {
        userIsInMiddleOfTyping = false
        operandStack.append(displayValue!)
        println("stack = \(operandStack)")
        history.text! = "\(displayValue!)  " + history.text!
    }
    
    @IBAction func clear() {
        display.text = "0"
        userIsInMiddleOfTyping = false
        operandStack.removeAll(keepCapacity: false)
        history.text = ""
    }
    
    @IBAction func backspace() {
        if userIsInMiddleOfTyping {
            if countElements(display.text!) > (display.text!.hasPrefix("-") ? 2 : 1) {
                display.text = dropLast(display.text!)
            } else {
                display.text = "0"
                userIsInMiddleOfTyping = false
            }
        }
    }
}

