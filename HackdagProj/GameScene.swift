//
//  GameScene.swift
//  Xproj
//
//  Created by Åsa Ericson Östmark on 2025-03-05.
//
/* README: this is the main file for the game, with all of the game physics and major functions of gameplay. I've added some comments for added readability, to point at what chunk of code does what.
 
 TODO: ensure centering of player character doesn't make the ground hover (MVP)
 TODO: replace free assets with own assets (if time allows)
 TODO: add remaining music tracks (if time allows)
 TODO: sprite shake when taking damage (if time allows)
 TODO: game over when at zero lives (MVP)
 TODO: merchant cutscene (Nice-to-have)
 TODO: merchant dialogue (nice-to-have)
 TODO: wizard tower end cutscene and win game (MVP)
 TODO: more puzzles placed down, more enemies, more stars (MVP)
 TODO: finish WIP assets (portraits, etc) (nice-to-have)
 TODO: animate enemies (nice-to-have)

 */

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // variables
    var fox: SKSpriteNode!
    var ground: SKSpriteNode!
    var leftButton: SKSpriteNode!
    var rightButton: SKSpriteNode!
    var jumpButton: SKSpriteNode!
    var boostButton: SKSpriteNode!
    var star: SKSpriteNode!
    var starCounter: SKSpriteNode!
    var starCounterText: SKLabelNode!
    var heart: SKSpriteNode!
    var heart2: SKSpriteNode!
    var heart3: SKSpriteNode!
    var skeleton: SKSpriteNode!
    var clergy: SKSpriteNode!
    var moveLeft = false
    var moveRight = false
    var canJump = false
    var boost = false
    var stars = 0
    var lives = 3 // unused
    var foxFacingRight = true
    var foxFacingLeft = false
    var canGust = true
    var hasHadClergyDialogue = false
    var foxWalkingFrames = [SKTexture]()
    var textureAtlas = SKTextureAtlas(named: "Fox")
    var cameraNode: SKCameraNode!
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        self.isUserInteractionEnabled = true
        
        // assets
        fox = childNode(withName: "Fox") as? SKSpriteNode
        ground = childNode(withName: "ground") as? SKSpriteNode
        leftButton = childNode(withName: "leftButton") as? SKSpriteNode
        rightButton = childNode(withName: "rightButton") as? SKSpriteNode
        jumpButton = childNode(withName: "jumpButton") as? SKSpriteNode
        boostButton = childNode(withName: "boostButton") as? SKSpriteNode
        star = childNode(withName: "star") as? SKSpriteNode
        skeleton = childNode(withName: "skeleton") as? SKSpriteNode
        heart = childNode(withName: "heart") as? SKSpriteNode
        heart2 = childNode(withName: "heart2") as? SKSpriteNode
        heart3 = childNode(withName: "heart3") as? SKSpriteNode
        
        // merchant -- WIP
        if let merchantNode = childNode(withName: "merchant") as? SKSpriteNode {
            clergy = merchantNode
            clergy.physicsBody = SKPhysicsBody(rectangleOf: clergy.size)
            clergy.physicsBody?.isDynamic = false
            clergy.physicsBody?.categoryBitMask = 32
            clergy.physicsBody?.contactTestBitMask = 1
            clergy.name = "clergy"
        }
        
        // dialogue stuff -- WIP
        var dialogueLabel: SKLabelNode!
        var nameLabel: SKLabelNode!
        var dialogueBox: SKSpriteNode!
        var myrranPortrait: SKSpriteNode!
        var clergyPortrait: SKSpriteNode!
            
        var dialogueLines: [(name: String, text: String)] = []
        var currentLineIndex = 0
        var currentCharIndex = 0
        var isTypingTimer: Timer?
        var isTyping = false
        var dialogueMode: DialogueMode = .normal
            
        enum DialogueMode {
            case normal
            case waiting
        }

        // fox physics
        fox?.physicsBody = SKPhysicsBody(rectangleOf: fox!.size)
        fox?.physicsBody?.affectedByGravity = true
        fox?.physicsBody?.allowsRotation = false
        fox?.physicsBody?.categoryBitMask = 1
        fox?.physicsBody?.collisionBitMask = 2
        fox?.physicsBody?.contactTestBitMask = 2 | 4 | 8

        // ground physics
        ground?.physicsBody = SKPhysicsBody(rectangleOf: ground!.size)
        ground?.physicsBody?.isDynamic = false
        ground?.physicsBody?.categoryBitMask = 2
        ground?.physicsBody?.collisionBitMask = 1
        ground?.physicsBody?.contactTestBitMask = 1
        
        // skeleton physics
        skeleton?.physicsBody = SKPhysicsBody(rectangleOf: skeleton!.size)
        skeleton?.physicsBody?.affectedByGravity = true
        skeleton?.physicsBody?.allowsRotation = false
        skeleton?.physicsBody?.categoryBitMask = 8
        skeleton?.physicsBody?.collisionBitMask = 2
        skeleton?.physicsBody?.contactTestBitMask = 1 | 2
        
        // camera init
        cameraNode = SKCameraNode()
        self.camera = cameraNode
        addChild(cameraNode)
        
        // UI
        starCounterText = SKLabelNode(fontNamed: "Courier")
        starCounterText.text = "\(stars)"
        starCounterText.fontSize = 60
        starCounterText.fontColor = .white
        starCounterText.position = CGPoint(x: frame.midX - 500, y: frame.maxY - 150)
        starCounterText.zPosition = 1000

        cameraNode.addChild(starCounterText)

        // ensure UI stays put when foxy runs and jumps to places
        if let starCounter = childNode(withName: "starCounter") as? SKSpriteNode {
            let pos = convert(starCounter.position, to: cameraNode)
            starCounter.removeFromParent()
            starCounter.position = pos
            cameraNode.addChild(starCounter)
        }

        if let heart = childNode(withName: "heart") as? SKSpriteNode {
            let pos = convert(heart.position, to: cameraNode)
            heart.removeFromParent()
            heart.position = pos
            cameraNode.addChild(heart)
        }

        if let heart2 = childNode(withName: "heart2") as? SKSpriteNode {
            let pos = convert(heart2.position, to: cameraNode)
            heart2.removeFromParent()
            heart2.position = pos
            cameraNode.addChild(heart2)
        }

        if let heart3 = childNode(withName: "heart3") as? SKSpriteNode {
            let pos = convert(heart3.position, to: cameraNode)
            heart3.removeFromParent()
            heart3.position = pos
            cameraNode.addChild(heart3)
        }
        
        if let jumpButton = childNode(withName: "jumpButton") as? SKSpriteNode {
            let pos = convert(jumpButton.position, to: cameraNode)
            jumpButton.removeFromParent()
            jumpButton.position = pos
            cameraNode.addChild(jumpButton)
        }
        
        if let leftButton = childNode(withName: "leftButton") as? SKSpriteNode {
            let pos = convert(leftButton.position, to: cameraNode)
            leftButton.removeFromParent()
            leftButton.position = pos
            cameraNode.addChild(leftButton)
        }
        
        if let rightButton = childNode(withName: "rightButton") as? SKSpriteNode {
            let pos = convert(rightButton.position, to: cameraNode)
            rightButton.removeFromParent()
            rightButton.position = pos
            cameraNode.addChild(rightButton)
        }
        
        if let boostButton = childNode(withName: "boostButton") as? SKSpriteNode {
            let pos = convert(boostButton.position, to: cameraNode)
            boostButton.removeFromParent()
            boostButton.position = pos
            cameraNode.addChild(boostButton)
        }
        
        if let gustButton = childNode(withName: "gustButton") as? SKSpriteNode {
            let pos = convert(gustButton.position, to: cameraNode)
            gustButton.removeFromParent()
            gustButton.position = pos
            cameraNode.addChild(gustButton)
        }
        
        // fox animation
        for i in 0..<textureAtlas.textureNames.count {
            let textureNames = "foxWalk" + String(i)
            foxWalkingFrames.append(textureAtlas.textureNamed(textureNames))
        }
        
        // skeleton patrolling
        func patrol(_ node: SKSpriteNode, range: CGFloat = 1000, speed: Double = 4.0) {
            let goRight = SKAction.moveBy(x: range, y: 0, duration: speed)
            // TODO: make skeleton *not* moonwalk later (frames exist and are in the asset list already)
            let goLeft = goRight.reversed()
            let patrol = SKAction.sequence([goRight, goLeft])
            node.run(SKAction.repeatForever(patrol))
        }
        
        if let skeleton = childNode(withName: "skeleton") as? SKSpriteNode {
            patrol(skeleton)
        }
    }
    
    // movement stuff for fox
    override func update(_ currentTime: TimeInterval) {
        guard let fox = fox else { return }
        
        if moveLeft {
            fox.physicsBody?.velocity.dx = -200
            if moveLeft && foxFacingRight {
                fox.xScale = -fox.xScale
            }
            foxFacingLeft = true
            foxFacingRight = false
        } else if moveRight {
            fox.physicsBody?.velocity.dx = 200
            
            if moveRight && foxFacingLeft {
                fox.xScale = -fox.xScale
            }
            foxFacingRight = true
            foxFacingLeft = false
        } else if boost && foxFacingRight {
            fox.physicsBody?.velocity.dx = 370
        } else if boost && foxFacingLeft {
            fox.physicsBody?.velocity.dx = -370
        } else {
            fox.physicsBody?.velocity.dx = 0
        }
                
        let cameraMoveAction = SKAction.move(to: fox.position, duration: 0.2)
        cameraNode.run(cameraMoveAction)
        
    }
    
    // touchesBegan
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)
            
            if touchedNode == leftButton {
                moveLeft = true
                fox.run(SKAction.repeatForever(SKAction.animate(with: foxWalkingFrames, timePerFrame: 0.3)))
            } else if touchedNode == rightButton {
                moveRight = true
                fox.run(SKAction.repeatForever(SKAction.animate(with: foxWalkingFrames, timePerFrame: 0.3)))
            } else if touchedNode == boostButton {
                boost = true
            } else if touchedNode == jumpButton && canJump {
                fox.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 670))
                canJump = false
            } else if touchedNode.name == "gustButton" {
                gustAbility()
            }

        }
        
        // helper function
        func gustAbility() {
            guard canGust else { return }
            canGust = false

            let gust = SKSpriteNode(color: .cyan, size: CGSize(width: 40, height: 20))
            gust.name = "gust"
            gust.position = fox.position
            gust.zPosition = 3

            // physics
            gust.physicsBody = SKPhysicsBody(rectangleOf: gust.size)
            gust.physicsBody?.isDynamic = true
            gust.physicsBody?.affectedByGravity = false
            gust.physicsBody?.categoryBitMask = 16
            gust.physicsBody?.contactTestBitMask = 8
            gust.physicsBody?.collisionBitMask = 0

            let direction: CGFloat = foxFacingRight ? 1 : -1
            gust.physicsBody?.velocity = CGVector(dx: 600 * direction, dy: 0)

            addChild(gust)

            gust.run(SKAction.sequence([
                SKAction.wait(forDuration: 2.0),
                SKAction.removeFromParent()
            ]))

            run(SKAction.sequence([
                SKAction.wait(forDuration: 3.0),
                SKAction.run { [weak self] in
                    self?.canGust = true
                }
            ]))
        }

    }
    
    // touchesEnded
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)
            
            if touchedNode == leftButton {
                moveLeft = false
                fox.removeAllActions()
            } else if touchedNode == rightButton {
                moveRight = false
                fox.removeAllActions()
            } else if touchedNode == boostButton {
                boost = false
            }
        }
    }
    
    // didBegin
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node, let nodeB = contact.bodyB.node else { return }

        if nodeA.name == "ground" || nodeB.name == "ground" || nodeA.name == "box" || nodeB.name == "box" || nodeA.name == "platform" || nodeB.name == "platform"{
            canJump = true
        }

        // stars
        if nodeA.name == "star" {
                collectStar(node: nodeA)
            } else if nodeB.name == "star" {
                collectStar(node: nodeB)
            }
        
        if nodeA.name == "star2" {
                collectStar(node: nodeA)
            } else if nodeB.name == "star2" {
                collectStar(node: nodeB)
            }
        
        if nodeA.name == "star3" {
                collectStar(node: nodeA)
            } else if nodeB.name == "star3" {
                collectStar(node: nodeB)
            }
        
        if nodeA.name == "star4" {
                collectStar(node: nodeA)
            } else if nodeB.name == "star4" {
                collectStar(node: nodeB)
            }
        
        // merchant
        if (nodeA.name == "clergy" && nodeB.name == "Fox") || (nodeB.name == "clergy" && nodeA.name == "Fox") && hasHadClergyDialogue == false {
            triggerFirstClergyDialogue()
        }
        
        if (nodeA.name == "clergy" && nodeB.name == "Fox") || (nodeB.name == "clergy" && nodeA.name == "Fox") && hasHadClergyDialogue == true {
            triggerClergyDialogue()
        }
        
        // get hit by skellyboy
        if (nodeA.name == "skeleton" && nodeB.name == "Fox") || (nodeB.name == "skeleton" && nodeA.name == "Fox") {
            loseHeart()
        }
        
        func loseHeart() {
            if lives > 0 {
                lives -= 1
                
                if lives == 2 {
                    heart3.isHidden = true
                } else if lives == 1 {
                    heart2.isHidden = true
                } else if lives == 0 {
                    heart.isHidden = true
                    // TODO: make superfrän gameover logic
                }
            }
        }

        if (nodeA.name == "gust" && nodeB.name == "skeleton") || (nodeB.name == "gust" && nodeA.name == "skeleton") {
            let skeleton = nodeA.name == "skeleton" ? nodeA : nodeB
            skeleton.physicsBody?.isDynamic = true
            skeleton.physicsBody?.applyImpulse(CGVector(dx: 500, dy: 0))
        }

    }
    
    // merchant -- WIP
    func triggerFirstClergyDialogue() {
        hasHadClergyDialogue = true
    }
    
    func triggerClergyDialogue() {
        
    }
    
    // stars
    func collectStar(node: SKNode) {
        node.physicsBody = nil
        node.removeFromParent()
        stars += 1
        starCounterText.text = "\(stars)"
        print("Fallen star collected! Score: \(stars)") // for debugging purposes this is still here
    }
}
