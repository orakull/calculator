//
//  CalculatorBrain.swift
//  calculator
//
//  Created by Руслан Ольховка on 13.02.15.
//  Copyright (c) 2015 Руслан Ольховка. All rights reserved.
//

import Foundation

class CalculatorBrain: Printable
{
    private enum Op: Printable
    {
        case Operand(Double)
        case Variable(String)
        case NullaryOperation(String, Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double, Bool)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .Variable(let variable):
                    return variable
                case .NullaryOperation(let symbol, _):
                    return symbol
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _, _):
                    return symbol
                }
            }
        }
    }
    
    private var opStack = [Op]()
    
    private var knownOps = [String:Op]()
    
    var variableValues = [String:Double]()
    
    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        learnOp(Op.BinaryOperation("×", *, false))
        learnOp(Op.BinaryOperation("÷", { $1 / $0 }, false))
        learnOp(Op.BinaryOperation("+", +, true))
        learnOp(Op.BinaryOperation("−", { $1 - $0 }, true))
        learnOp(Op.UnaryOperation("sin", { sin($0) }))
        learnOp(Op.UnaryOperation("cos", { cos($0) }))
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.NullaryOperation("π", M_PI))
    }
    
    var program: AnyObject {
        get {
            return opStack.map { $0.description }
        }
        set {
            if let opSymbols = newValue as? [String] {
                var newOpStack = [Op]()
                for symbol in opSymbols {
                    if let op = knownOps[symbol] {
                        newOpStack.append(op)
                    } else if let operand = NSNumberFormatter().numberFromString(symbol)?.doubleValue {
                        newOpStack.append(.Operand(operand))
                    }
                } 
                opStack = newOpStack
            }
        }
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .Variable(let variable):
                return (variableValues[variable], remainingOps)
            case .NullaryOperation(_, let const):
                return (const, remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation, _):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            }
        }
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        println("\(opStack) = \(result) with \(remainder) left over")
        return result
    }
    
    private func description(ops: [Op]) -> (result: String?, remainngOps: [Op], needParentheses: Bool) {
        if !ops.isEmpty {
            var remainngOps = ops
            let op = remainngOps.removeLast()
            switch op {
            case .Operand(let operand):
                return ("\(operand)", remainngOps, false)
            case .Variable(let symbol):
                return ("\(symbol)", remainngOps, false) // TODO: make Optional
            case .NullaryOperation(_, _):
                return (op.description, remainngOps, false)
            case .UnaryOperation(_, _):
                let desc = description(remainngOps)
                let result = desc.result ?? "?"
                return (op.description + "(\(result))", desc.remainngOps, false)
            case .BinaryOperation(_, _, let needParentheses):
                let desc1 = description(remainngOps)
                var A = desc1.result ?? "?"
                A = desc1.needParentheses && !needParentheses ? "(\(A))" : A
                let desc2 = description(desc1.remainngOps)
                var B = desc2.result ?? "?"
                B = desc2.needParentheses && !needParentheses ? "(\(B))" : B
                return ("\(B)\(op)\(A)", desc2.remainngOps, needParentheses)
            }
        }
        return (nil, ops, false)
    }
    
    var description: String {
        get {
            var desc = description(opStack)
            var value = desc.result ?? "error"
            while !desc.remainngOps.isEmpty {
                desc = description(desc.remainngOps)
                value = (desc.result ?? "error") + ", " + value
            }
            return value
        }
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func pushOperand(symbol: String) -> Double? {
        opStack.append(Op.Variable(symbol))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    
    func clear() {
        opStack.removeAll(keepCapacity: false)
        evaluate()
    }
    
}