//
//  Scene2.swift
//  Xproj
//
//  Created by Åsa Ericson Östmark on 2025-03-06.
//
/* README: in this scene I've set up an intro cutscene to the game, with dialogue, music, and portraits for the different characters. It's not *fully* implemented... yet, so it looks very, euhm, *rough* atm.  Stay tuned. */

import GameplayKit
import SpriteKit
import AVFoundation

class IntroCutScene: SKScene {
    
    var dialogueLabel: SKLabelNode!
    var nameLabel: SKLabelNode!
    var dialogueBox: SKSpriteNode!
    var myrranPortrait: SKSpriteNode!
    var unknownPortrait: SKSpriteNode!
    var malgrenPortrait: SKSpriteNode!
    var clergyPortrait: SKSpriteNode!
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
        myrranPortrait = SKSpriteNode(imageNamed: "wip-portrait")
        myrranPortrait.position = CGPoint(x: size.width * 0.2, y: size.height * 0.3)
        myrranPortrait.zPosition = 1
        myrranPortrait.setScale(0.5)
        addChild(myrranPortrait)
        
        unknownPortrait = SKSpriteNode(imageNamed: "wip-portrait")
        unknownPortrait.position = CGPoint(x: size.width * 0.2, y: size.height * 0.3)
        unknownPortrait.zPosition = 1
        unknownPortrait.setScale(0.5)
        addChild(unknownPortrait)
        
        malgrenPortrait = SKSpriteNode(imageNamed: "wip-portrait")
        malgrenPortrait.position = CGPoint(x: size.width * 0.2, y: size.height * 0.3)
        malgrenPortrait.zPosition = 1
        malgrenPortrait.setScale(0.5)
        addChild(malgrenPortrait)
        
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
    
    // dialogue is written but not imputted into the app yet, I've written down the very first parts here, up until the music starts.
    
    func loadDialogue() {
            dialogueLines = [
                ("Myrren", "*sigh*"),
                ("Myrren", "Another long day."),
                ("Myrren", "Another day of being different."),
                ("Myrren", "Of feeling like I don't belong."),
                ("Myrren", "What's wrong with me?"),
                ("Myrren", "Why can't I just be normal?"),
                ("Myrren", "!!!"),
                ("Myrren", "A falling star!"),
                ("Myrren", "Quick! I should make a wish!"),
                ("Myrren", "I wish..."),
                ("Myrren", "I wish..."),
                ("Myrren", "I wish I was somewhere else. Anywhere else."),
                ("Myrren", "Someone else."),
                ("Myrren", "I wish I wasn't me, wasn't here, wasn't now."),
                ("Myrren", "Please."),
                ("Myrren", "..."),
                ("Myrren", "..."),
                ("Myrren", "..."),
                ("Myrren", "Well, it was worth a try."),
                ("Myrren", "I should go to bed, it's another long day tomorrow and I need the rest."),
                ("Myrren", "Zzzzzz"),
                ("Myrren", "Huh?"),
                ("Myrren", "!!!"),
                ("Myrren", "Where am I?!"),
                ("Myrren", "What's going on?"),
                ("???", "Ohohoho..."),
                ("Myrren", "Who's there?"),
                ("Myrren", "Who's laughing??"),
                ("Strange Man", "What have we here? A lone girl wished upon a star, hmmm?"),
                ("Myrren", "How do you know about that?"),
                ("Strange Man", "It's the only way to get here, so of course I know. Wished to get away, did you? Wished to be far away from home?"),
                ("Strange Man", "Well, you got your wish."),
                ("Myrren", "!!!"),
                ("Strange Man", "But look at my manners! I haven't even introduced myself."),
                ("Malgren", "The name's Malgren, and who might you be?"),
            ]
        }
    
    func loadMusic() {
        if let url = Bundle.main.url(forResource: "danger", withExtension: "mp4") {
            musicPlayer = try? AVAudioPlayer(contentsOf: url)
            musicPlayer?.numberOfLoops = -1
            musicPlayer?.prepareToPlay()
        }
    }
    
    func showNextLine() {
        if currentLineIndex == 25 {
            musicPlayer?.play()
        }
            if currentLineIndex < dialogueLines.count {
                nameLabel.text = dialogueLines[currentLineIndex].name
                startTypingText(dialogueLines[currentLineIndex].text)
                currentLineIndex += 1
            } else {
                transitionToGame()
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
        
        func transitionToGame() {
            let transition = SKTransition.fade(withDuration: 1.0)
            let gameScene = GameScene(fileNamed: "GameScene")!
            gameScene.scaleMode = .aspectFill
            self.view?.presentScene(gameScene, transition: transition)
        }
    }
