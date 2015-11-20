package {
	/**
	 * 3D preview of personal card with Papervision3D 2.0 and
	 *
	 * @author			Giovambattista Fazioli
	 * @web				http://www.undolog.com
	 * @email			g.fazioli@saidmade.com
	 * @version			1.0	 
	 *
	 * Copyright 2009 Saidmade Srl (email : g.fazioli@undolog.com)
	 * 
	 * 	This program is free software; you can redistribute it and/or modify
	 * 	it under the terms of the GNU General Public License as published by
	 * 	the Free Software Foundation; either version 2 of the License, or
	 * 	(at your option) any later version.
	 * 	
	 * 	This program is distributed in the hope that it will be useful,
	 * 	but WITHOUT ANY WARRANTY; without even the implied warranty of
	 * 	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	 * 	GNU General Public License for more details.
	 * 	
	 * 	You should have received a copy of the GNU General Public License
	 * 	along with this program; if not, write to the Free Software
	 * 	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
	 * 	
	 *
	 */
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.text.*;
	import flash.utils.Timer;
	
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.view.BasicView;
	import org.papervision3d.materials.*;
	import org.papervision3d.objects.primitives.*;
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.events.InteractiveScene3DEvent;
	
	
	public class Card extends MovieClip {
		
		private var __timer				:Timer;
		private var __background		:Sprite;
		private var __bv				:BasicView;
		private var __card				:Plane;							// front
		private var __planeBack			:Plane;							// back
		private var __matFront			:BitmapAssetMaterial;
		private var __matBack			:BitmapAssetMaterial;
		
		private var __zoom				:Number			= 100;
		
		private var __pcrx				:Number;
		private var __pcry				:Number;
		private var __pmx				:Number;
		private var __pmy				:Number;

        public function Card() {
			addEventListener( Event.ADDED_TO_STAGE, init );
			
			stage.scaleMode		= StageScaleMode.NO_SCALE
			stage.align			= StageAlign.TOP_LEFT;
        }
		
		private function init(e:Event = null):void {
			removeEventListener( Event.ADDED_TO_STAGE, init );
			
			__timer		= new Timer(25);
			__timer.addEventListener( TimerEvent.TIMER, onTimer );
			
			initStage();
			initMaterials();
			initPapervision();
			initPlane();
			initListeners();
			
			__timer.start();
		}
		
		private function initStage():void {
			__background 		= new Sprite();
			var matrix:Matrix 	= new Matrix();
			matrix.createGradientBox(stage.stageWidth, stage.stageHeight);
			with( __background.graphics ) {
				beginGradientFill(GradientType.RADIAL, [0x662200, 0x000000], [1, 1], [0x00, 0xFF], matrix);
				drawRect(0, 0, stage.stageWidth,  stage.stageHeight);
				endFill();
			}
			
			addChild(__background);
			__background.width 			= stage.stageWidth;
			__background.height 		= stage.stageHeight;		
			__background.useHandCursor 	= true;
			__background.buttonMode		= true;
		}

		private function initMaterials():void {
			__matFront  			= new BitmapAssetMaterial( 'Fronte' );
			__matFront.smooth	  	= true;
			__matFront.interactive	= true;
			__matBack				= new BitmapAssetMaterial( 'Retro' );
			__matBack.smooth	  	= true;
			__matBack.interactive	= true;
		}
		
		private function initPapervision():void {
			__bv				= new BasicView(stage.stageWidth, stage.stageHeight, false, true);
			addChild( __bv );
			__bv.camera.zoom	= __zoom;
		}		
		
		private function initListeners():void {
			addEventListener(Event.ENTER_FRAME, render);
			__background.addEventListener(MouseEvent.MOUSE_DOWN, backgroundMouseDown);
			__card.addEventListener( InteractiveScene3DEvent.OBJECT_PRESS,
				function(e:InteractiveScene3DEvent):void {
					__timer.stop();
					backgroundMouseDown();
				}
			);
			__planeBack.addEventListener( InteractiveScene3DEvent.OBJECT_PRESS,
				function(e:InteractiveScene3DEvent):void {
					__timer.stop();
					backgroundMouseDown();
				}
			);
		}

		private function backgroundMouseDown(e:MouseEvent = null):void {
			__timer.stop();
			
			__pcrx	= __card.rotationX;
			__pcry	= __card.rotationY;
			__pmx 	= mouseX;
			__pmy 	= mouseY;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, stageMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUp);
			__card.addEventListener( InteractiveScene3DEvent.OBJECT_RELEASE,
				function(e:InteractiveScene3DEvent):void {
					stageMouseUp();
				}
			);
			__planeBack.addEventListener( InteractiveScene3DEvent.OBJECT_RELEASE,
				function(e:InteractiveScene3DEvent):void {
					stageMouseUp();
				}
			);
		}
		
		private function stageMouseMove(e:MouseEvent):void {
			__card.rotationX = __pcrx + mouseY - __pmy;
			__card.rotationY = __pcry - mouseX + __pmx;
		}
		
		private function onTimer( e:TimerEvent = null ):void {
			__card.rotationY++;
		}

		private function stageMouseUp(e:MouseEvent = null):void {
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, stageMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stageMouseUp);
			__timer.start();
		}		
		
		private function initPlane():void {
			__card					= new Plane( __matFront, 425, 236, 10, 10 );
			__planeBack				= new Plane( __matBack, 425, 236, 10, 10 );
			__planeBack.z			= 1;
			__planeBack.rotationY	= 180;

//			__card.y			= 40;
//			__card.rotationY	= 30;
//			__card.rotationX	= -30;
			
			__card.useOwnContainer = true;
			
			__card.addChild( __planeBack );
			
			__bv.scene.addChild( __card );
		}

		private function render(e:Event):void {
			__bv.singleRender();
		}
	}
}