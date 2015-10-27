//
//  ViewController.swift
//  PetRock
//
//  Created by Mike Pitre on 10/26/15.
//  Copyright © 2015 Mike Pitre. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var monsterImg: MonsterImg!
    @IBOutlet weak var foodImg: DragImg!
    @IBOutlet weak var heartImg: DragImg!
    @IBOutlet weak var stoneImg: DragImg!
    @IBOutlet weak var penalty1Img: UIImageView!
    @IBOutlet weak var penalty2Img: UIImageView!
    @IBOutlet weak var penalty3Img: UIImageView!
    @IBOutlet weak var newRockBtn: UIButton!
    @IBOutlet weak var newRockPanel: UIImageView!
    
    
    let DIM_ALPHA: CGFloat = 0.2
    let OPAQUE: CGFloat = 1.0
    let MAX_PENALTIES = 3
    
    var penalties = 0
    var timer: NSTimer!
    var monsterHappy = false
    var currentItem: UInt32 = 0
    var chosenMonster: Int?
    
    var musicPlayer: AVAudioPlayer!
    var sfxBite: AVAudioPlayer!
    var sfxHeart: AVAudioPlayer!
    var sfxDeath: AVAudioPlayer!
    var sfxSkull: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        foodImg.dropTarget = monsterImg
        heartImg.dropTarget = monsterImg
        stoneImg.dropTarget = monsterImg
        
        penalty1Img.alpha = DIM_ALPHA
        penalty2Img.alpha = DIM_ALPHA
        penalty3Img.alpha = DIM_ALPHA
        
        foodImg.alpha = DIM_ALPHA
        foodImg.userInteractionEnabled = false
        heartImg.alpha = OPAQUE
        heartImg.userInteractionEnabled = true
        stoneImg.alpha = DIM_ALPHA
        stoneImg.userInteractionEnabled = false
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "itemDroppedOnCharacter:", name: "onTargetDropped", object: nil)
        
        do {
            
            try sfxBite = AVAudioPlayer(contentsOfURL: NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource("bite", ofType: "wav")!))
            try sfxDeath = AVAudioPlayer(contentsOfURL: NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource("death", ofType: "wav")!))
            try sfxHeart = AVAudioPlayer(contentsOfURL: NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource("heart", ofType: "wav")!))
            try sfxSkull = AVAudioPlayer(contentsOfURL: NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource("skull", ofType: "wav")!))
            
            sfxBite.prepareToPlay()
            sfxDeath.prepareToPlay()
            sfxHeart.prepareToPlay()
            sfxSkull.prepareToPlay()
            
        } catch let err as NSError {
            print(err.debugDescription)
        }
        
        startTimer()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func itemDroppedOnCharacter(notif: AnyObject) {
        
        monsterHappy = true
        startTimer()
        
        foodImg.alpha = DIM_ALPHA
        foodImg.userInteractionEnabled = false
        heartImg.alpha = DIM_ALPHA
        heartImg.userInteractionEnabled = false
        stoneImg.alpha = DIM_ALPHA
        stoneImg.userInteractionEnabled = false
        
        if currentItem == 0 {
            sfxHeart.play()
        } else if currentItem == 1 {
            sfxBite.play()
        } else {
            sfxDeath.play()
        }
    }
    
    func startTimer() {
        
        if timer != nil {
            timer.invalidate()
        }
        
        timer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "changeGameState", userInfo: nil, repeats: true)
        
    }
    
    func changeGameState() {
        
        if !monsterHappy {
            
            penalties++
            
            sfxSkull.play()
            
            if penalties == 1 {
                penalty1Img.alpha = OPAQUE
                penalty2Img.alpha = DIM_ALPHA
            } else if penalties == 2 {
                penalty2Img.alpha = OPAQUE
                penalty3Img.alpha = DIM_ALPHA
            } else if penalties >= 3 {
                penalty3Img.alpha = OPAQUE
            } else {
                penalty1Img.alpha = DIM_ALPHA
                penalty2Img.alpha = DIM_ALPHA
                penalty3Img.alpha = DIM_ALPHA
            }
            
            if penalties >= MAX_PENALTIES {
                gameOver()
            }
        }
        
        let rand = arc4random_uniform(3)
        
        if rand == 0 {
            heartImg.alpha = OPAQUE
            heartImg.userInteractionEnabled = true
            
            foodImg.alpha = DIM_ALPHA
            foodImg.userInteractionEnabled = false
            stoneImg.alpha = DIM_ALPHA
            stoneImg.userInteractionEnabled = false
        } else if rand == 1 {
            foodImg.alpha = OPAQUE
            foodImg.userInteractionEnabled = true
            
            heartImg.alpha = DIM_ALPHA
            heartImg.userInteractionEnabled = false
            stoneImg.alpha = DIM_ALPHA
            stoneImg.userInteractionEnabled = false
        } else {
            stoneImg.alpha = OPAQUE
            stoneImg.userInteractionEnabled = true
            
            heartImg.alpha = DIM_ALPHA
            heartImg.userInteractionEnabled = false
            foodImg.alpha = DIM_ALPHA
            foodImg.userInteractionEnabled = false
        }
        
        currentItem = rand
        monsterHappy = false
        
    }
    
    func gameOver() {

        timer.invalidate()
        
        monsterImg.playDeathAnimation()
        sfxDeath.play()
        
        foodImg.hidden = true
        heartImg.hidden = true
        stoneImg.hidden = true
        
        newRockBtn.hidden = false
        newRockPanel.hidden = false
    }
    
    @IBAction func newRockBtnPressed(sender: AnyObject) {
        restartGame()
    }
    
    
    func restartGame() {
        sfxHeart.play()
        penalties = 0
        startTimer()
        
        penalty1Img.alpha = DIM_ALPHA
        penalty2Img.alpha = DIM_ALPHA
        penalty3Img.alpha = DIM_ALPHA
        
        foodImg.hidden = false
        heartImg.hidden = false
        stoneImg.hidden = false
        
        newRockBtn.hidden = true
        newRockPanel.hidden = true
        
        monsterImg.playIdleAnimation()
    }
    

}


