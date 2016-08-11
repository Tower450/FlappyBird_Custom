//
//  GameScene.swift
//  DisruptiveBird
//
//  Created by Jonathan Tourangeau on 2016-04-20.
//  Copyright (c) 2016 DisruptiveInno. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    var score = 0;
    var scoreLabel = SKLabelNode();
    var gameoverLabel = SKLabelNode();
    
    
    var isGameOver:Bool = false;
    
    var bird = SKSpriteNode();
    var bg = SKSpriteNode();
    var ground = SKSpriteNode();
    
    var pipe1 = SKSpriteNode();
    var pipe2 = SKSpriteNode();
    
    var movingObjects = SKSpriteNode();
    var labelContainer = SKSpriteNode();
    
    enum ColliderType: UInt32{
    
        case Bird = 1;
        case Object = 2;
        case Gap = 4;
    
    
    }
    
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        self.physicsWorld.contactDelegate = self;
        
        self.addChild(movingObjects);
        self.addChild(labelContainer);
        
        
        /* BACKGROUND */
        makeBackground();
        
        
        
        
        /** SCORE LABEL **/
        
         scoreLabel.fontName = "Helvetica";
         scoreLabel.fontSize = 60;
         scoreLabel.text = "0";
         scoreLabel.position = CGPointMake( CGRectGetMidX(self.frame),  self.frame.size.height - 70);
        
         self.addChild(scoreLabel);
        
        /*****************/
        
        
        /* BIRD */
        
        let birdTexture = SKTexture(imageNamed: "disruptiveflappy1.png");
        let birdTexture2 = SKTexture(imageNamed: "disruptiveflappy2.png");
        
        let birdAnimation = SKAction.animateWithTextures([birdTexture,birdTexture2], timePerFrame: 0.3);
        let makeBirdFlap = SKAction.repeatActionForever(birdAnimation);
        
        bird = SKSpriteNode(texture: birdTexture);
        
        
        bird.position = CGPoint(x: CGRectGetMidX(self.frame) ,y: CGRectGetMidY(self.frame) );
        bird.runAction(makeBirdFlap);
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: birdTexture.size().height / 2);
        bird.physicsBody!.dynamic = true;
        //bird.physicsBody?.allowsRotation
        
        bird.physicsBody!.categoryBitMask = ColliderType.Bird.rawValue;
        bird.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue;
        bird.physicsBody!.collisionBitMask = ColliderType.Object.rawValue;
        
        
        
        
        //self refere a la scene
        self.addChild(bird);
        
        
        /* GROUND */
        
        let groundTexture = SKTexture(imageNamed: "ground.png");
        
        ground = SKSpriteNode(texture: groundTexture);
    
        ground.position = CGPoint(x: CGRectGetMidX(self.frame) ,y: 0);
        ground.size.width = self.frame.width;
        
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width , 100 ));
        
        ground.physicsBody!.dynamic = false;
        
        ground.physicsBody!.categoryBitMask = ColliderType.Object.rawValue;
        ground.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue;
        ground.physicsBody!.collisionBitMask = ColliderType.Object.rawValue;
        
        
        self.addChild(ground);
        
        
        /* PIPE timer */
        
        
        _ = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "spawnPipes", userInfo: nil, repeats: true);
        
      
    }
    
    
    
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        print("we have contact");
        
        
        if(contact.bodyA.categoryBitMask == ColliderType.Gap.rawValue || contact.bodyB.categoryBitMask == ColliderType.Gap.rawValue ){
        
            score++;
            
            scoreLabel.text = String(score);
        
        
        }
        else{
            
            if(isGameOver == false){
                
            
                isGameOver = true;
            
                //Set everything in the scene to 0 speed (stop everything)
                self.speed = 0;
            
                gameoverLabel.fontName = "Helvetica";
                gameoverLabel.fontSize = 20;
                gameoverLabel.text = "GAME OVER! TAP TO PLAY AGAIN!";
                gameoverLabel.position = CGPointMake( CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
            
                labelContainer.addChild(gameoverLabel);
            }
        
        }
        
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        if(isGameOver == false){
            
            bird.physicsBody!.velocity = CGVectorMake(0,0);
            bird.physicsBody!.applyImpulse(CGVectorMake(0, 50));
            
        }
        else{
            
      
            //RESET THE GAME
            resetGame();
            
        }
        
    }
    
    
    
    
    func resetGame(){
        
        
        
        score = 0;
        scoreLabel.text = "0";
        
        bird.position = CGPointMake( CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        bird.physicsBody!.velocity = CGVectorMake(0,0);
        
        movingObjects.removeAllChildren();
        
        makeBackground();
        
        self.speed = 1 ;
        
        isGameOver = false;
        
        labelContainer.removeAllChildren();
        
    
    
    }
    
    
    func makeBackground(){
    
        
        let bgTexture = SKTexture(imageNamed: "bg.png");
        
        
        let moveBgAnimation = SKAction.moveByX(-bgTexture.size().width, y:0 , duration: 9);
        let replaceBackground = SKAction.moveByX(bgTexture.size().width , y: 0, duration: 0);
        let moveBgForever = SKAction.repeatActionForever(SKAction.sequence([moveBgAnimation, replaceBackground]));
        
        
        
        for(var i:CGFloat = 0; i < 10 ; i++ ){
            
            bg = SKSpriteNode(texture: bgTexture);
            
            bg.position =  CGPoint(x: bgTexture.size().width / 2 + bgTexture.size().width * i , y: CGRectGetMidY(self.frame) );
            
            bg.size.height = self.frame.height;
            
            bg.zPosition = -5
            
            bg.runAction(moveBgForever);
            
            movingObjects.addChild(bg);
        }
        
    
    }
    
    
    //Making pipe method
    func spawnPipes(){
        
        
        let gapHeight = (bird.texture?.size().height)! * 4;
        
        let mouvementAmount = arc4random() % UInt32(self.frame.size.height / 2) ;
        
        let pipeOffSet = CGFloat(mouvementAmount) - self.frame.size.height / 4;
        
        let movePipe  = SKAction.moveByX(-self.frame.size.width * 2, y: 0, duration: NSTimeInterval(self.frame.size.width / 100) );
        let removePipe = SKAction.removeFromParent();
        
        let moveAndRemovePipes = SKAction.sequence([movePipe,removePipe]);
        
        
        var pipe1Texture = SKTexture(imageNamed: "pipe1.png");
        pipe1 = SKSpriteNode(texture: pipe1Texture);
        
        pipe1.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width , y: CGRectGetMidY(self.frame) + pipe1Texture.size().height / 2 + gapHeight / 2 + pipeOffSet);
        pipe1.zPosition = -3
        
        pipe1.runAction(moveAndRemovePipes);
        
        
        pipe1.physicsBody = SKPhysicsBody(rectangleOfSize: pipe1Texture.size() );
        pipe1.physicsBody!.dynamic = false;
        
        pipe1.physicsBody!.categoryBitMask = ColliderType.Object.rawValue;
        pipe1.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue;
        pipe1.physicsBody!.collisionBitMask = ColliderType.Object.rawValue;
        
        
        movingObjects.addChild(pipe1);
        
        
        var pipe2Texture = SKTexture(imageNamed: "pipe2.png");
        pipe2 = SKSpriteNode(texture: pipe2Texture);
        
        pipe2.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width , y: CGRectGetMidY(self.frame) - pipe2Texture.size().height / 2 - gapHeight / 2 + pipeOffSet);
        pipe2.zPosition = -3
        
        pipe2.runAction(moveAndRemovePipes);
        
        
        pipe2.physicsBody = SKPhysicsBody(rectangleOfSize: pipe1Texture.size() );
        pipe2.physicsBody!.dynamic = false;
        pipe2.physicsBody!.categoryBitMask = ColliderType.Object.rawValue;
        pipe2.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue;
        pipe2.physicsBody!.collisionBitMask = ColliderType.Object.rawValue;
        
        movingObjects.addChild(pipe2);
        
        
        /*** GAP ZONE POINT ***/
        
        var gap = SKNode();
        
        // +50 ajouter pour seulement si flappy a bien passser dans le milieu
        gap.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width + 50 , y: CGRectGetMidY(self.frame) + pipeOffSet );
        gap.runAction(moveAndRemovePipes)
        
        gap.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(pipe1.size.width , gapHeight) );
        gap.physicsBody?.dynamic = false;
        
        gap.physicsBody!.categoryBitMask = ColliderType.Gap.rawValue;
        gap.physicsBody!.contactTestBitMask = ColliderType.Bird.rawValue;
        gap.physicsBody!.collisionBitMask = ColliderType.Gap.rawValue;
        
        movingObjects.addChild(gap);
    }
    
   
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
