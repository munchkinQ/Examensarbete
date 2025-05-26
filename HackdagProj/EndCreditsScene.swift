//
//  EndCreditsScene.swift
//  HackdagProj
//
//  Created by Åsa Ericson Östmark on 2025-05-26.
//

import SpriteKit
import AVFoundation

class EndCreditsScene: SKScene {

    var endCreditsMusicPlayer: AVAudioPlayer?

    override func didMove(to view: SKView) {
        setupBackground()
        playMusic()
        showCredits()
    }

    func setupBackground() {
        let bg = SKSpriteNode(color: .black, size: self.size)
        bg.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        bg.zPosition = -1
        addChild(bg)
    }

    func playMusic() {
        if let musicURL = Bundle.main.url(forResource: "endcredits", withExtension: "mp4") {
            do {
                endCreditsMusicPlayer = try AVAudioPlayer(contentsOf: musicURL)
                endCreditsMusicPlayer?.numberOfLoops = -1
                endCreditsMusicPlayer?.play()
            } catch {
                print("error playing *pwetty* tunes: \(error)")
            }
        }
    }

    func showCredits() {
        let creditsText = """
        Thank you for playing
        STARVALE

        Developed by:
        Åsa Ericson Östmark

        Art by:
        Åsa Ericson Östmark
        Open Source assets @itch.io

        Music by:
        Åsa Ericson Östmark

        Special Thanks:
        Marcus
        Alessio
        Erik
        Jannica
        Michael
        and
        IAD23 & STI :)
        
        Obs! Starvale is a current WIP.
        """

        let label = SKLabelNode(fontNamed: "Courier-Bold")
        label.text = ""
        label.fontSize = 24
        label.fontColor = .white
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = self.size.width - 40
        label.verticalAlignmentMode = .top
        label.horizontalAlignmentMode = .center
        label.position = CGPoint(x: size.width / 2, y: -size.height / 2)
        label.zPosition = 1

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attributed = NSAttributedString(string: creditsText, attributes: [
            .paragraphStyle: paragraphStyle,
            .foregroundColor: UIColor.white,
            .font: UIFont(name: "Courier-Bold", size: 24)!
        ])
        label.attributedText = attributed
        addChild(label)

        let totalHeight = label.frame.height + size.height
        let moveUp = SKAction.moveBy(x: 0, y: totalHeight, duration: 20.0)
        let wait = SKAction.wait(forDuration: 1.0)
        let fadeOut = SKAction.fadeOut(withDuration: 2.0)
        let transitionBack = SKAction.run { [weak self] in
            guard let self = self else { return }
            self.endCreditsMusicPlayer?.stop()
            let gamescene = GameScene(size: self.size)
            self.view?.presentScene(gamescene, transition: SKTransition.fade(withDuration: 2.0))
        }

        label.run(SKAction.sequence([wait, moveUp, fadeOut, transitionBack]))
    }
}

