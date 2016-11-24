//
//  ViewController.swift
//  Game2048
//
//  Created by admin on 10/26/16.
//  Copyright © 2016 admin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var score: UILabel!
    var b = Array(repeating: Array(repeating: 0, count: 4), count: 4)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let directions: [UISwipeGestureRecognizerDirection] = [.right, .left, .up, .down]
        
        for directions in directions {
            let gesture = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
            gesture.direction = directions
            self.view.addGestureRecognizer(gesture)
        }
        randomNum(type: -1)
    }
    
    func respondToSwipeGesture(gesture : UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.left: randomNum(type: 0)
            case UISwipeGestureRecognizerDirection.right: randomNum(type: 1)
            case UISwipeGestureRecognizerDirection.up: randomNum(type: 2)
            case UISwipeGestureRecognizerDirection.down: randomNum(type: 3)
            default:
                break
            }
        }
    }
    
    func convertNumberLabel(numLabel : Int, value : String) {
        let label = self.view.viewWithTag(numLabel) as! UILabel
        label.text = value
    }
    
    func changeBackColor(numLabel : Int, color : UIColor) {
        let label = self.view.viewWithTag(numLabel) as! UILabel
        label.backgroundColor = color
    }
    
    func transfer() {
        for i in 0..<4 {
            for j in 0..<4 {
                let numLabel = 100 + (i * 4) + j
                convertNumberLabel(numLabel: numLabel, value: String(b[i][j]))
                
                switch (b[i][j]) {
                case 2,4:
                    changeBackColor(numLabel: numLabel, color: UIColor.cyan)
                case 8,16:
                    changeBackColor(numLabel: numLabel, color: UIColor.green)
                case 32:
                    changeBackColor(numLabel: numLabel, color: UIColor.orange)
                case 64:
                    changeBackColor(numLabel: numLabel, color: UIColor.red)
                default:
                    changeBackColor(numLabel: numLabel, color: UIColor.brown)
                }
            }
        }
    }
    
    func randomNum(type : Int) {
        switch (type) {
        case 0: left()
        case 1: right()
        case 2: up()
        case 3: down()
        default: break
        }
        if (checkWin()) {
            let messBox = UIAlertController(title: "You Win", message: "2048", preferredStyle: .alert)
            messBox.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            messBox.addAction(UIAlertAction(title: "Reset", style: .default, handler: {(action:UIAlertAction!) in self.resetAll()
            }))
            self.present(messBox, animated: true, completion: nil)
            
        }
        if (checkRandom()) {
            var rnlabelX = arc4random_uniform(4)
            var rnlabelY = arc4random_uniform(4)
            let rdNum = arc4random_uniform(2) == 0 ? 2 : 4
            
            while (b[Int(rnlabelX)][Int(rnlabelY)] != 0) {
                rnlabelX = arc4random_uniform(4)
                rnlabelY = arc4random_uniform(4)
            }
            b[Int(rnlabelX)][Int(rnlabelY)] = rdNum
            
            let numLabel = 100 + (Int(rnlabelX) * 4) + Int(rnlabelY)
            convertNumberLabel(numLabel: numLabel , value: String(rdNum))
            transfer()
        }  else if checkGameOver() {
            let messBox = UIAlertController(title: "You Lose", message: "You can't move", preferredStyle: .alert)
            messBox.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(messBox, animated: true, completion: nil)
        }
    }
    
    func checkRandom() -> Bool {
        for i in 0..<4 {
            for j in 0..<4 {
                if b[i][j] == 0 {
                    return true
                }
            }
        }
        return false
    }
    
    func up() {
        for col in 0..<4 {
            var check = false
            for row in 1..<4 {
                var tx = row
                if (b[row][col]) == 0 {
                    continue
                }
                for rowc in stride(from: row - 1, to: -1, by: -1) {
                    if (rowc != -1) {
                        if (b[rowc][col] != 0 && (b[rowc][col] != b[row][col] || check)) {
                            break
                        } else {
                            tx = rowc
                        }
                    }
                }
                
                if (tx == row) {
                    continue
                }
                
                if (b[row][col] == b[tx][col]) {
                    check = true
                    getScore(value: b[tx][col])
                    b[tx][col] *= 2
                } else {
                    b[tx][col] = b[row][col]
                }
                b[row][col] = 0
            }
            
        }
    }
    
    func down() {
        for col in 0..<4 {
            var check = false
            for row in 0..<4 {
                var tx = row
                if(b[row][col]) == 0 {
                    continue
                }
                for rowc in stride(from: row + 1, to: 4, by: 1) {
                    if (b[rowc][col] != 0 && (b[rowc][col] != b[row][col] || check)) {
                        break
                    } else {
                        tx = rowc
                    }
                }
                if (tx == row) {
                    continue
                }
                
                if (b[row][col] == b[tx][col]) {
                    check = true
                    getScore(value: b[tx][col])
                    b[tx][col] *= 2
                } else {
                    b[tx][col] = b[row][col]
                }
                b[row][col] = 0
            }
        }
    }
    
    func left() {
        for row in 0..<4 {
            var check = false
            for col in 1..<4 {
                var ty = col
                if (b[row][col] == 0) {
                    continue
                }
                
                for colc in stride(from: col - 1, to: -1, by: -1) {
                    if (b[row][colc] != 0 && (b[row][colc] != b[row][col] || check)) {
                        break
                    } else {
                        ty = colc
                    }
                }
                
                if (ty == col) {
                    continue
                }
                
                if (b[row][ty] == b[row][col]) {
                    check = true
                    getScore(value: b[row][ty])
                    b[row][ty] *= 2
                } else {
                    b[row][ty] = b[row][col]
                }
                b[row][col] = 0
            }
        }
    }
    
    func right() {
        for row in 0..<4 {
            var check = false
            for col in stride(from: 3, to: -1, by: -1) {
                var ty = col
                if (b[row][col] == 0) {
                    continue
                }
                
                for colc in stride(from: col + 1, to: 4, by: 1) {
                    if (b[row][colc] != 0 && (b[row][colc] != b[row][col] || check)) {
                        break
                    } else {
                        ty = colc
                    }
                }
                
                if (ty == col) {
                    continue
                }
                
                if (b[row][ty] == b[row][col]) {
                    check = true
                    getScore(value: b[row][ty])
                    b[row][ty] *= 2
                } else {
                    b[row][ty] = b[row][col]
                }
                b[row][col] = 0
            }
        }
    }
    
    func getScore(value : Int) {
        score.text = String(Int(score.text!)! + value)
    }
    
    //Check theo 4 chieu
    func checkUp(row : Int, col : Int) -> Bool {
        var check = false
        if b[row][col] == b[row+1][col] {
            check = true
        }
        return check
    }
    func checkDown(row : Int, col : Int) -> Bool {
        var check = false
        if b[row][col] == b[row-1][col] {
            check = false
        }
        return check
    }
    func checkLeft(row : Int, col : Int) -> Bool {
        var check = false
        if b[row][col] == b[row][col+1] {
            check = true
        }
        return check
    }
    func checkRight(row : Int, col : Int) -> Bool {
        var check = false
        if b[row][col] == b[row][col-1] {
            check = true
        }
        return check
    }
    
    func checkFull() -> Bool {
        var check : Bool = false
        for i in 0..<4 {
            for j in 0..<4 {
                if b[i][j] == 0 {
                    check = false
                    break
                } else {
                    check = true
                }
            }
        }
        
        return check
    }
    
    func checkGameOver() -> Bool {
        var check = true
        if checkFull() {
            for row in 0..<4 {
                for col in 0..<4 {
                    if (row < 3 && checkUp(row: row, col: col)) {
                        return false
                    }
                    if (row > 0 && checkDown(row: row, col: col)) {
                        return false
                    }
                    if (col < 3 && checkLeft(row: row, col: col)) {
                        return false
                    }
                    if (col > 0 && checkRight(row: row, col: col)) {
                        return false
                    }
                }
            }
        } else {
            check = false
        }
        return check
    }
    
    @IBAction func action_Reset(_ sender: UIButton) {
        resetAll()
    }
    
    func checkWin() -> Bool{
        for i in 0..<4 {
            for j in 0..<4 {
                if b[i][j] == 128 {
                    return true
                }
            }
        }
        return false
    }
    
    func resetAll() {
        b = Array(repeating: Array(repeating: 0, count: 4), count: 4)
        randomNum(type: -1)
        score.text = "0"
    }
    
}

