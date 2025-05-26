//
//  EndScene.swift
//  HackdagProj
//
//  Created by Åsa Ericson Östmark on 2025-05-24.
//

import GameplayKit
import SpriteKit
import AVFoundation

class EndScene: SKScene {
    
    var dialogueLabel: SKLabelNode!
    var nameLabel: SKLabelNode!
    var dialogueBox: SKSpriteNode!
    var myrrenPortrait: SKSpriteNode!
    var malgrenPortrait: SKSpriteNode!
    var musicPlayer: AVAudioPlayer?
    
    var dialogueLines: [(name: String, text: String)] = []
    var currentLineIndex = 0
    var currentCharIndex = 0
    var isTypingTimer: Timer?
    var isTyping = false
    
    override func didMove(to view: SKView) {
        setupScene()
        loadDialogue()
        loadMusic()
        showNextLine()
    }
    
    func setupScene() {
        backgroundColor = .black
        let background = SKSpriteNode(imageNamed: "BG")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.zPosition = 0
        background.size = self.size
        addChild(background)
        
        // portraits
        myrrenPortrait = SKSpriteNode(imageNamed: "portrait-fox")
        myrrenPortrait.position = CGPoint(x: size.width * 0.2, y: size.height * 0.6)
        myrrenPortrait.zPosition = 1
        myrrenPortrait.setScale(0.2)
        addChild(myrrenPortrait)
        myrrenPortrait.isHidden = true
        
        malgrenPortrait = SKSpriteNode(imageNamed: "wip-portrait")
        malgrenPortrait.position = CGPoint(x: size.width * 0.2, y: size.height * 0.6)
        malgrenPortrait.zPosition = 1
        malgrenPortrait.setScale(0.2)
        addChild(malgrenPortrait)
        malgrenPortrait.isHidden = true
        
        // box
        dialogueBox = SKSpriteNode(color: .black, size: CGSize(width: size.width * 0.85, height: 160))
        dialogueBox.position = CGPoint(x: size.width/2, y: size.height * 0.15)
        dialogueBox.alpha = 0.75
        dialogueBox.zPosition = 2
        addChild(dialogueBox)
        
        // nametag
        nameLabel = SKLabelNode(fontNamed: "Courier-Bold")
        nameLabel.fontSize = 24
        nameLabel.fontColor = .systemPink
        nameLabel.horizontalAlignmentMode = .left
        nameLabel.position = CGPoint(x: -dialogueBox.size.width/2 + 20, y: dialogueBox.size.height/2 - 30)
        nameLabel.zPosition = 3
        dialogueBox.addChild(nameLabel)
        
        // dialogue
        dialogueLabel = SKLabelNode(fontNamed: "Courier")
        dialogueLabel.fontSize = 20
        dialogueLabel.fontColor = .white
        dialogueLabel.horizontalAlignmentMode = .left
        dialogueLabel.verticalAlignmentMode = .top
        dialogueLabel.numberOfLines = 0
        dialogueLabel.preferredMaxLayoutWidth = dialogueBox.size.width - 40
        dialogueLabel.position = CGPoint(x: -dialogueBox.size.width/2 + 20, y: dialogueBox.size.height/2 - 60)
        dialogueLabel.zPosition = 3
        dialogueBox.addChild(dialogueLabel)
    }
    
    func loadDialogue() {
            dialogueLines = [
                ("Malgren", "Look who it is, if it isn’t my favourite little critter."),
                ("Myrren", "Take me back!"),
                ("Myrren", "I want to go home."),
                ("Malgren", "Didn’t that quacking old pirate tell you already?"),
                ("Malgren", "There is no going home anymore."),
                ("Malgren", "As soon as you set foot in Starvale there’s no going back."),
                ("Malgren", "Starvale is your home now, like it ot not."),
                ("Myrren", "I know there’s a way. Clergy told me all about it."),
                ("Malgren", "Did he now?"),
                ("Myrren", "Yes. I know what it takes to get back home."),
                ("Malgren", "Well, then you’ll also know that Clergy has spent the better part of his life here in Starvale trying to get enough stars to go home himself. "),
                ("Malgren", "With no such luck, might I add."),
                ("Malgren", "How are you planning to do what he’s failed to do for all this time?"),
                ("Myrren", "I already did it. "),
                ("Myrren", "I have all the fallen stars I need."),
                ("Malgren", "!!!"),
                ("Myrren", "So take me back."),
                ("Malgren", "How’s that even possible?"),
                ("Malgren", "And in just one night??"),
                ("Myrren", "A promise is a promise."),
                ("Malgren", "I never promised *you* anything."),
                ("Myrren", "!!!"),
                ("Myrren", "B-but!"),
                ("Malgren", "But..."),
                ("Malgren", "I shall do it either way."),
                ("Myrren", "!!!"),
                ("Malgren", "Very well…"),
                ("Malgren", "Give me the stars."),
                ("Myrren", "And you’ll take me home?"),
                ("Myrren", "I’ll be me again?"),
                ("Malgren", "Yes."),
                ("Malgren", "Go to sleep now."),
                ("Malgren", "And you shall wake up as yourself, in your own bed."),
                ("Malgren", "And Starvale..."),
                ("Malgren", "Will have been nothing but a dream."),
            ]
        }
    
    func loadMusic() {
        if let url = Bundle.main.url(forResource: "the-end", withExtension: "mp4") {
            musicPlayer = try? AVAudioPlayer(contentsOf: url)
            musicPlayer?.numberOfLoops = -1
            musicPlayer?.prepareToPlay()
        }
    }
    
    func showNextLine() {
        if currentLineIndex == 0 {
            musicPlayer?.play()
        }
            if currentLineIndex < dialogueLines.count {
                let speaker = dialogueLines[currentLineIndex].name
                nameLabel.text = speaker
                startTypingText(dialogueLines[currentLineIndex].text)
                        if speaker == "Myrren" {
                            myrrenPortrait.isHidden = false
                            malgrenPortrait.isHidden = true
                        } else if speaker == "Malgren" {
                            myrrenPortrait.isHidden = true
                            malgrenPortrait.isHidden = false
                        }
                currentLineIndex += 1
            } else {
                transitionToEndCredits()
            }
        }
    
    func startTypingText(_ text: String) {
            dialogueLabel.text = ""
            currentCharIndex = 0
            isTyping = true

            isTypingTimer?.invalidate()
            isTypingTimer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
                guard self.currentCharIndex < text.count else {
                    self.isTyping = false
                    timer.invalidate()
                    return
                }
                let index = text.index(text.startIndex, offsetBy: self.currentCharIndex + 1)
                self.dialogueLabel.text = String(text[..<index])
                self.currentCharIndex += 1
            }
        }
        
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            if isTyping {
                isTypingTimer?.invalidate()
                let fullText = dialogueLines[currentLineIndex - 1].text
                dialogueLabel.text = fullText
                isTyping = false
            } else {
                showNextLine()
            }
        }
        
        func transitionToEndCredits() {
            let transition = SKTransition.fade(withDuration: 1.0)
            let endCreditsScene = EndCreditsScene(size: self.size)
            endCreditsScene.scaleMode = .aspectFill
            self.view?.presentScene(endCreditsScene, transition: transition)
        }
    }

