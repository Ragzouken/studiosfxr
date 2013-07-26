package ui
{
	import flash.display.BlendMode;
	import flash.display.CapsStyle;
	import flash.display.DisplayObject;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;
	
	import flash.geom.Point;
	import flash.geom.Matrix;
	
	/**
	 * CircleButton
	 * 
	 * Copyright 2013 Mark Wonnacott
	 *
	 * This derivative work is a modification of the original file whose
	 * copyright and attribution is available below.
	 * 
	 * Licensed under the Apache License, Version 2.0 (the "License");
	 * you may not use this file except in compliance with the License.
	 * You may obtain a copy of the License at
	 *
	 * 	http://www.apache.org/licenses/LICENSE-2.0
	 *
	 * Unless required by applicable law or agreed to in writing, software
	 * distributed under the License is distributed on an "AS IS" BASIS,
	 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	 * See the License for the specific language governing permissions and
	 * limitations under the License.
	 * 
	 * @author Mark Wonnacott
	 */
	
	// ORIGINAL COPYRIGHT NOTICE & ATTRIBUTION
	/**
	 * TinyButton
	 * 
	 * Copyright 2010 Thomas Vian
	 *
	 * Licensed under the Apache License, Version 2.0 (the "License");
	 * you may not use this file except in compliance with the License.
	 * You may obtain a copy of the License at
	 *
	 * 	http://www.apache.org/licenses/LICENSE-2.0
	 *
	 * Unless required by applicable law or agreed to in writing, software
	 * distributed under the License is distributed on an "AS IS" BASIS,
	 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	 * See the License for the specific language governing permissions and
	 * limitations under the License.
	 * 
	 * @author Thomas Vian
	 */
	public class Individual extends Sprite
	{
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		protected var _app:SfxrApp;
		
		protected var _backOff:Shape;					// Button graphic when unselected
		protected var _backDown:Shape;					// Button graphic when being clicked
		protected var _backSelected:Shape;				// Button graphic when selected		
		
		protected var _links:Shape;
		protected var _connection:Shape;
		
		protected var _vis:Visualisation;
		
		protected var _rect:Rectangle;					// Bounds of the button in the context of the stage
		
		protected var _radius:Number;                      // Button radius in pixels
		
		protected var _selected:Boolean;				// If the button is selected (only used for wave selection)
		protected var _selectable:Boolean;				// If the button is selectable (only used for wave selection)
		
		protected var _enabled:Boolean;					// If the button is currently clickable
		
		protected var _synth:SfxrSynth;
		
		public var _parents:Dictionary;
		public var _children:Dictionary;
		public var _connects:Dictionary;
		
		protected var _dx:int, _dy:int;
		
		//--------------------------------------------------------------------------
		//	
		// Getters / Setters
		//
		//--------------------------------------------------------------------------
		
		public function get synth():SfxrSynth { return _synth; }
		
		public function get radius():Number { return _radius; }
		
		public function get params():SfxrParams { return _synth.params.clone(); }
		public function set params(params:SfxrParams):void
		{
			_synth.params = params.clone();
			
			_vis.refresh(_synth.params);
		}
		
		/** Selects/unselects the button */
		public function get selected():Boolean {return _selected;}
		public function set selected(v:Boolean):void
		{
			_selected = v;
			_vis.selected = v;
			
			removeChildAt(0);
			
			if(_selected)
			{
				addChildAt(_backSelected, 0);
			}
			else
			{
				addChildAt(_backOff, 0);
			}
		}
		
		/** Enables/disables the button */
		public function get enabled():Boolean { return _enabled; }
		public function set enabled(value:Boolean):void
		{
			if(value) 	alpha = 1.0;
			else		alpha = 0.3;
			
			_enabled = value;
		}
		
		//--------------------------------------------------------------------------
		//	
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Creates the TinyButton, adding text and a background shape. 
		 * Defaults to the off state.
		 * @param	onClick			Callback function called when the button is clicked
		 * @param	label			Text to display on the button (left aligned)
		 * @param	border			Thickness of the border in pixels
		 * @param	selectable		If the button should be selectable
		 */
		public function Individual(app:SfxrApp, x:int, y:int, synth:SfxrSynth, parents:Dictionary):void 
		{
			_app = app;
			
			this.x = x;
			this.y = y;
			
			_radius = 20;
			
			_synth = synth;
			_parents = parents;
			_children = new Dictionary();
			
			_selectable = true;
			_selected = false;
			_enabled = true;
			
			_connects = new Dictionary();
			
			_backOff =      drawCircle(0x000000, 0xA09088);
			_backDown =     drawCircle(0xA09088, 0xFFF0E0);
			_backSelected = drawCircle(0x000000, 0x988070);
			
			addChildAt(_backOff, 0);
			
			_vis = new Visualisation(0, 0, _radius, _synth.params);
			addChild(_vis);
			
			mouseChildren = false;
			blendMode = BlendMode.LAYER;
			
			_links = new Shape();
			addChild(_links);
			redrawLinks();
			
			_connection = new Shape();
			addChild(_connection);
			
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		
		public function mutate(magnitude:Number = 0.05):Individual
		{
			var synth:SfxrSynth = new SfxrSynth();
			
			synth.params = _synth.params.clone();
			synth.params.mutate(magnitude);
			
			var parents:Dictionary = new Dictionary();
			parents[this] = true;
			
			var angle:Number = Math.PI * 2 * Math.random();
			var radius:Number = _radius * 2 + _radius * Math.random();
			
			var child:Individual = new Individual(_app, x + radius * Math.cos(angle), y + radius * Math.sin(angle), synth, parents);
			_children[child] = true;
			
			//_app.selected(child);
			child._synth.play();
			
			return child;
		}
		
		public function remove():void
		{
			for (var child:* in _children) {
				delete child._parents[this];
				child.redrawLinks();
			}
			
			for (var parent:* in _parents) {
				delete parent._children[this];
				parent.redrawLinks();
			}
			
			for (var linkpoint:* in _connects) {
				linkpoint.unlink(this);
			}
			
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseDrag);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveLink);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUpDrag);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUpLink);
			
			_app.removeindividual(this);
		}
		
		/**
		 * Once the button is on the stage, the event listener can be set up and rectangles recorded
		 * @param	e	Added to stage event
		 */
		private function onAdded(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAdded)
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			
			_rect = getBounds(stage);
		}
		
		//--------------------------------------------------------------------------
		//	
		//  Mouse Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Sets the button to the down state
		 * @param	e	MouseEvent
		 */
		private function onMouseDown(e:MouseEvent):void 
		{
			var dx:int = x - stage.mouseX, dy:int = y - stage.mouseY;
			
			if (_enabled && Math.sqrt(dx*dx + dy*dy) < _radius)
			{
				removeChildAt(0);
				addChildAt(_backDown, 0);
				_vis.selected = false;
				
				if (e.shiftKey) {
					stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUpLink);
					stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveLink);
				} else {
					stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUpDrag);
					stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseDrag);
					
					_dx = dx;
					_dy = dy;
				}
			
				e.stopImmediatePropagation();
			}
		}
		
		private function onMouseDrag(e:MouseEvent):void
		{
			x = stage.mouseX + _dx;
			y = stage.mouseY + _dy;
			
			_rect.x = stage.mouseX + _dx;
			_rect.y = stage.mouseY + _dy;
			
			for (var child:* in _children) {
				child.redrawLinks();
			}
			
			redrawLinks();
		}
		
		private function onMouseMoveLink(e:MouseEvent):void
		{
			redrawConnection();
		}
		
		private function onMouseUpLink(e:MouseEvent):void
		{
			_app.linkEvent(this, stage.mouseX, stage.mouseY);
			
			removeChildAt(0);
			
			if(_selectable)
			{
				_selected = true;
				addChildAt(_backSelected, 0);
				
				_vis.selected = _selected;
				
				_app.selected(this);
			}
			else
			{
				addChildAt(_backOff, 0);
				
				_vis.selected = _selected;
			}
			
			removeChild(_connection);
			_connection = new Shape();
			addChild(_connection);
			
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUpLink);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveLink);
		}
		
		/**
		 * Sets the button to the off state if not selectable, switches state between off and selected if it is. 
		 * Calls the onClick callback
		 * @param	e	MouseEvent
		 */
		private function onMouseUpDrag(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUpDrag);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseDrag);
			
			removeChildAt(0);
			
			if(_selectable)
			{
				_selected = true;
				addChildAt(_backSelected, 0);
				
				_vis.selected = _selected;
				
				_app.selected(this);
			}
			else
			{
				addChildAt(_backOff, 0);
				
				_vis.selected = _selected;
			}
			
			if (x < -_radius/2 || x > 640 + _radius/2) { remove(); return; }
			
			_synth.play();
		}
		
		//--------------------------------------------------------------------------
		//	
		//  Util Methods
		//
		//--------------------------------------------------------------------------
		
		public function redrawConnection():void
		{
			removeChild(_connection);
			_connection = new Shape();
			addChild(_connection);
			
			var start:Vector3D = new Vector3D(0, 0, 0);
			var end:Vector3D = new Vector3D(stage.mouseX - x, stage.mouseY - y, 0);
			
			var vector:Vector3D = end.subtract(start);
			vector.normalize();
			
			vector.scaleBy(_radius);
			
			start.incrementBy(vector);
			//end.decrementBy(vector);
			
			_connection.graphics.moveTo(start.x, start.y);
			_connection.graphics.lineStyle(2, 0x000000, 1, true, LineScaleMode.NORMAL, CapsStyle.SQUARE, JointStyle.MITER);
			_connection.graphics.lineTo(end.x, end.y);
		}
		
		public function redrawLinks():void
		{
			removeChild(_links);
			_links = new Shape();
			addChild(_links);
			
			for (var parent:* in _parents) {
				var start:Vector3D = new Vector3D(0, 0, 0);
				var end:Vector3D = new Vector3D(parent.x - x, parent.y - y, 0);
				
				var vector:Vector3D = end.subtract(start);
				var distance:Number = vector.length;
				vector.normalize();
				
				vector.scaleBy(_radius);
				
				start.incrementBy(vector);
				end.decrementBy(vector);
				
				var u:Number = Math.min(1, Math.max(0, distance - 50) / 300);
				var alpha:Number = 1 - (0.9 * u);
				
				_links.graphics.moveTo(start.x, start.y);
				_links.graphics.lineStyle(1, 0x000000, alpha, true, LineScaleMode.NORMAL, CapsStyle.SQUARE, JointStyle.MITER);
				_links.graphics.lineTo(end.x, end.y);
				
				_links.graphics.beginFill(0x000000, 1);
				_links.graphics.drawCircle(end.x, end.y, 2);
				_links.graphics.endFill();
			}
			
			_links.graphics.beginFill(0x000000, 1);
			//_links.graphics.drawRect( -2, -2, 4, 4);
			_links.graphics.endFill();
		}
		
		/**
		 * Returns a background shape with the specified colours and border
		 * @param	border				Thickness of the border in pixels
		 * @param	borderColour		Colour of the border
		 * @param	fillColour			Colour of the fill
		 * @return						The drawn rectangle Shape 
		 */
		private function drawCircle(borderColour:uint, fillColour:uint):Shape
		{
			var rect:Shape = new Shape();
			rect.graphics.lineStyle(1, borderColour, 1, true);
			rect.graphics.beginFill(fillColour, 1);
			rect.graphics.drawCircle(.5, .5, _radius);
			//rect.graphics.drawRect(-_radius, -_radius, _radius*2, _radius*2);
			rect.graphics.endFill();
			return rect;
		}
	}
}