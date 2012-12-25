package com.andreagherardi.simplebox2dexample;

import nme.display.Sprite;
import nme.events.Event;
import nme.Lib;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2World;
import box2D.dynamics.B2BodyDef;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2DebugDraw;
import box2D.collision.shapes.B2CircleShape;
import box2D.collision.shapes.B2Shape;
import box2D.collision.shapes.B2PolygonShape;
import box2D.dynamics.B2Fixture;
import box2D.dynamics.B2FixtureDef;
import box2D.common.B2Settings;
import nme.utils.Timer;
import nme.events.TimerEvent;
import com.andreagherardi.simplebox2dexample.utils.Stats;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.events.MouseEvent;

class Main extends Sprite
{
	private var world:B2World;
	private var stepTimer:Timer;

	private var mToPx:Float; 	//pixels per meter. Box2d takes measurements in meters, while flash/android/ios take measurements in pixels, that's why we need this
	private var pxToM:Float;
	private var radToDeg:Float;
	private var degToRad:Float;

	private var crateArray:Array<B2Body>;
	private var crateImages:Array<Sprite>;
	private var tennisBallArray:Array<B2Body>;
	private var tennisBallImages:Array<Sprite>;


	private var ballBody:B2Body;
	private var ballSprite:Sprite;
	private var glassBody:B2Body;
	private var glassSprite:Sprite;

	private var resetBtn:Sprite;

	public var baseStageY:Float;

    public function new()
    {
		super();

		var stats:Stats = new Stats();
		stats.x = Lib.current.stage.stageWidth - 1;
		stats.x = Lib.current.stage.stageHeight - 1;
		addChild(stats);

		mToPx = 50;
		pxToM = 1 / mToPx;
		radToDeg = 180 / B2Settings.b2_pi;
		degToRad = B2Settings.b2_pi / 180;

		crateArray = new Array<B2Body>();
		crateImages = new Array<Sprite>();

		tennisBallArray = new Array<B2Body>();
		tennisBallImages = new Array<Sprite>();

		addEventListener(Event.ADDED_TO_STAGE, init);
    }

    private function init(e:Event = null):Void
    {
        removeEventListener(Event.ADDED_TO_STAGE, init);
        getStarted();
    }

    private function getStarted():Void
    {
    	baseStageY = Lib.current.stage.stageHeight - 1 * mToPx;

		var gravity:B2Vec2 = new B2Vec2(0, 10);
		world = new B2World(gravity, true);

		createBoundaries();
		createBall(0.3, 100, baseStageY, 0, 0);
		createGlass(1, Lib.current.stage.stageWidth, baseStageY, 0, 0);


		resetBtn = new Sprite();
		resetBtn.graphics.beginFill(0xff0000, 1);
		resetBtn.graphics.drawRect(0, 0, 80, 30);
		resetBtn.graphics.endFill();
		resetBtn.x = Lib.current.stage.stageWidth - 80;
		resetBtn.y = 0;
		addChild(resetBtn);
		resetBtn.addEventListener(MouseEvent.CLICK, resetScene);


		stepTimer = new Timer(0.015 * 1000);
	    stepTimer.addEventListener(TimerEvent.TIMER, onTick);
	    stepTimer.start();
    }

    private function resetScene(e:MouseEvent):Void
    {
		createBall(0.3, 100, baseStageY, 0, 0);
    }

	// Create boundaries

	private function createBoundaries():Void
	{
	    //Create the ground

		var groundBodyDef:B2BodyDef = new B2BodyDef();
		groundBodyDef.position.set(0, Lib.current.stage.stageHeight * pxToM);
		var groundBody:B2Body = world.createBody(groundBodyDef);
		var groundShape:B2PolygonShape = new B2PolygonShape();
		groundShape.setAsBox(Lib.current.stage.stageWidth * pxToM, 1 * pxToM);
		var groundFixtureDef:B2FixtureDef = new B2FixtureDef();
		groundFixtureDef.shape = groundShape;
		var groundFixture:B2Fixture = groundBody.createFixture(groundFixtureDef);

		//Create right wall

		var rightWallBodyDef:B2BodyDef = new B2BodyDef();
	    rightWallBodyDef.position.set(stage.stageWidth * pxToM, 0);
	    var rightWallBody:B2Body = world.createBody(rightWallBodyDef);
	    var rightWallShape:B2PolygonShape = new B2PolygonShape();
	    rightWallShape.setAsBox(1 * pxToM, Lib.current.stage.stageHeight * pxToM);
	    var rightWallFixtureDef:B2FixtureDef = new B2FixtureDef();
	    rightWallFixtureDef.shape = rightWallShape;
	    var rightWallFixture:B2Fixture = rightWallBody.createFixture(rightWallFixtureDef);

		//Create left wall

	    var leftWallBodyDef:B2BodyDef = new B2BodyDef();
	    leftWallBodyDef.position.set(0, 0);
	    var leftWallBody:B2Body = world.createBody(leftWallBodyDef);
	    var leftWallShape:B2PolygonShape = new B2PolygonShape();
	    leftWallShape.setAsBox(1 * pxToM, Lib.current.stage.stageHeight * pxToM);
	    var leftWallFixtureDef:B2FixtureDef = new B2FixtureDef();
	    leftWallFixtureDef.shape = leftWallShape;
	    var leftWallFixture:B2Fixture = leftWallBody.createFixture(leftWallFixtureDef);

		//Create ceiling

	    var ceilingBodyDef:B2BodyDef = new B2BodyDef();
	    ceilingBodyDef.position.set(0, 0);
	    var ceilingBody:B2Body = world.createBody(ceilingBodyDef);
	    var ceilingShape:B2PolygonShape = new B2PolygonShape();
	    ceilingShape.setAsBox(Lib.current.stage.stageWidth, 1);
	    var ceilingFixtureDef:B2FixtureDef = new B2FixtureDef();
	    ceilingFixtureDef.shape = ceilingShape;
	    var ceilingFixture:B2Fixture = ceilingBody.createFixture(ceilingFixtureDef);
	}

	//Wheel generator


	private function createGlass(mWidth:Float, pxStartX:Float, pxStartY:Float, mVelocityX:Float, mVelocityY:Float):Void
	{
	    var crateBodyDef:B2BodyDef = new B2BodyDef();
	    crateBodyDef.position.set(pxStartX * pxToM, pxStartY * pxToM);  //note the scale factor
		crateBodyDef.type = B2Body.b2_dynamicBody;
	    var crateBody:B2Body = world.createBody(crateBodyDef);
	    var crateShape:B2PolygonShape = new B2PolygonShape();
	    crateShape.setAsBox(mWidth / 2, mWidth / 2);        //crates are square so width == height
	    var crateFixtureDef:B2FixtureDef = new B2FixtureDef();
	    crateFixtureDef.shape = crateShape;
		crateFixtureDef.density = 1.0;
	    var crateFixture:B2Fixture = crateBody.createFixture(crateFixtureDef);

	    var startingVelocity:B2Vec2 = new B2Vec2(mVelocityX, mVelocityY);
	    crateBody.setLinearVelocity(startingVelocity);

		crateArray.push(crateBody);

		var crateBmd:BitmapData = ApplicationMain.getAsset('assets/glass.jpg');
		var crateImage:Bitmap = new Bitmap(crateBmd);
	    crateImage.width = mWidth * mToPx;
	    crateImage.height = mWidth * mToPx;

	 	var crateSprite:Sprite = new Sprite();
	    crateSprite.addChild(crateImage);
		crateImage.x -= crateImage.width / 2;
		crateImage.y -= crateImage.height / 2;
	    crateSprite.x = pxStartX;
	    crateSprite.y = pxStartY;
	    crateImages.push(crateSprite);
		addChild(crateSprite);
	}

	private function createBall(mRadius:Float, pxStartX:Float, pxStartY:Float, mVelocityX:Float, mVelocityY:Float):Void
	{
		if (ballBody != null) {
			ballBody.setLinearVelocity(new B2Vec2(0,0));
			ballBody.setAngularVelocity(0);
	    	ballBody.setPosition(new B2Vec2(pxStartX * pxToM, pxStartY * pxToM));
			return;
		}

	    var ballBodyDef:B2BodyDef = new B2BodyDef();
	    ballBodyDef.type = B2Body.b2_dynamicBody;
	    ballBodyDef.position.set(pxStartX * pxToM, pxStartY * pxToM);
	    ballBody = world.createBody(ballBodyDef);
	    var circleShape:B2CircleShape = new B2CircleShape(mRadius);
	    var wheelFixtureDef:B2FixtureDef = new B2FixtureDef();
	    wheelFixtureDef.shape = circleShape;
		wheelFixtureDef.restitution = .8;
		wheelFixtureDef.friction = .6;
		wheelFixtureDef.density = 15;
	    var wheelFixture:B2Fixture = ballBody.createFixture(wheelFixtureDef);

	    var startingVelocity:B2Vec2 = new B2Vec2(mVelocityX, mVelocityY);
	    ballBody.setLinearVelocity(startingVelocity);

		var wheelBmd:BitmapData = ApplicationMain.getAsset('assets/SimpleWheel.png');
		var wheelImage:Bitmap = new Bitmap(wheelBmd);
		wheelImage.width = mRadius * 2 * mToPx;
	    wheelImage.height = mRadius * 2 * mToPx;

		ballSprite = new Sprite();
		ballSprite.addChild(wheelImage);
		ballSprite.x = pxStartX;
		ballSprite.y = pxStartY;
		addChild(ballSprite);

		ballSprite.addEventListener(MouseEvent.CLICK, onBallClick);
	}

	//Box generator

	private function createCrate(mWidth:Float, pxStartX:Float, pxStartY:Float, mVelocityX:Float, mVelocityY:Float):Void
	{
	    var crateBodyDef:B2BodyDef = new B2BodyDef();
	    crateBodyDef.position.set(pxStartX * pxToM, pxStartY * pxToM);  //note the scale factor
		crateBodyDef.type = B2Body.b2_dynamicBody;
	    var crateBody:B2Body = world.createBody(crateBodyDef);
	    var crateShape:B2PolygonShape = new B2PolygonShape();
	    crateShape.setAsBox(mWidth / 2, mWidth / 2);        //crates are square so width == height
	    var crateFixtureDef:B2FixtureDef = new B2FixtureDef();
	    crateFixtureDef.shape = crateShape;
		crateFixtureDef.density = 1.0;
	    var crateFixture:B2Fixture = crateBody.createFixture(crateFixtureDef);

	    var startingVelocity:B2Vec2 = new B2Vec2(mVelocityX, mVelocityY);
	    crateBody.setLinearVelocity(startingVelocity);

		crateArray.push(crateBody);

		var crateBmd:BitmapData = ApplicationMain.getAsset('assets/SimpleCrate.png');
		var crateImage:Bitmap = new Bitmap(crateBmd);
	    crateImage.width = mWidth * mToPx;
	    crateImage.height = mWidth * mToPx;

	 	var crateSprite:Sprite = new Sprite();
	    crateSprite.addChild(crateImage);
		crateImage.x -= crateImage.width / 2;
		crateImage.y -= crateImage.height / 2;
	    crateSprite.x = pxStartX;
	    crateSprite.y = pxStartY;
	    crateImages.push(crateSprite);
		addChild(crateSprite);
	}

	//Event listeners

	private function onTick(e:TimerEvent):Void
	{
	    world.step(0.025, 10, 10);

		ballSprite.x = ballBody.getPosition().x * mToPx - (ballSprite.width * .5);
		ballSprite.y = ballBody.getPosition().y * mToPx - (ballSprite.width * .5);

		// for(i in 0...wheelArray.length)
	 //    {
		// 	var ballBody = wheelArray[i];

		// 	wheelImage = wheelImages[i];
		// 	wheelImage.x = ballBody.getPosition().x * mToPx - (wheelImage.width * .5);
		// 	wheelImage.y = ballBody.getPosition().y * mToPx - (wheelImage.width * .5);
	 //    }

		var crateImage:Sprite;

		for(j in 0...crateArray.length)
		{
			var crateBody = crateArray[j];

		    crateImage = crateImages[j];
		    crateImage.x = (crateBody.getPosition().x * mToPx);// - (crateImage.width * 0.5);
		    crateImage.y = (crateBody.getPosition().y * mToPx);// - (crateImage.height * 0.5);
			crateImage.rotation = crateBody.getAngle() * radToDeg;
		}

		world.drawDebugData();
	}

	private function onBallClick(e:MouseEvent):Void
	{
		//show the arrow on the ball to adjust direction

		var ball:Sprite = cast(e.target, Sprite);

		// ball.graphics.lineStyle(2, 0xff0000);
		// ball.graphics.moveTo(0, 0);
		// ball.graphics.lineTo(100, 100);

		var relatedBody:B2Body = ballBody;

		var clickOffsetX:Float = e.localX - ball.width * .5;
		var clickOffsetY:Float = e.localY - ball.height * .5;
		var horizontalForce:Float = - clickOffsetX * 1000 * pxToM;
		var verticalForce:Float = - clickOffsetY * 1000 * pxToM;

		ballBody.applyImpulse(new B2Vec2(horizontalForce, verticalForce), relatedBody.getPosition());
	}

	// Entry point

	public static function main()
	{
		Lib.current.addChild(new Main());
	}
}