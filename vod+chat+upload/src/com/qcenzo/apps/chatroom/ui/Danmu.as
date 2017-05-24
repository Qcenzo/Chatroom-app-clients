package com.qcenzo.apps.chatroom.ui
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	public class Danmu extends Sprite
	{
		private var pool:Vector.<Buttlet>;
		private var bs:Vector.<Buttlet>;
		private var i:int;
		private var n:int;
		private var temp:Number;
		
		public function Danmu()
		{
			mouseChildren = mouseEnabled = false;
			
			pool = new Vector.<Buttlet>();
			for (var i:int = 0; i < 10; ++i)
				pool[i] = new Buttlet();
			
			bs = new Vector.<Buttlet>();
			
			addEventListener(Event.ENTER_FRAME, onFrame);
		}
		
		override public function set scrollRect(value:Rectangle):void
		{
			x = value.x;
			y = value.y;
			value.x = 0;
			value.y = 0;
			super.scrollRect = value;
		}
		
		public function fly(message:String):void
		{
			var b:Buttlet = pool.length > 0 ? pool.pop() : new Buttlet();
			b.text = message;
			b.scrollRect = scrollRect; 
			addChild(b);
			
			bs.fixed = false;
			bs[n++] = b;
			bs.fixed = true; 
		}
		
		private function onFrame(event:Event):void
		{
			for (i = 0; i < n; ++i)
			{
				temp = bs[i].x - bs[i].speed;
				if (temp >= bs[i].x0)
				{
					bs[i].x = temp;
					continue;
				}
				
				temp = i; 
				
				removeChild(bs[i]);
				pool.push(bs[i]);
				
				bs.fixed = false;
				for (--n; i < n; ++i)
					bs[i] = bs[i + 1];
				bs[i] = null;
				bs.fixed = true;
				
				i = temp - 1;
			}
		}
	}
}

import flash.filters.GlowFilter;
import flash.geom.Rectangle;
import flash.text.TextField;

class Buttlet extends TextField
{
	private static const BLACK_BORDER:Array = [new GlowFilter(0, 0.8, 2, 2, 255)];
	
	var x0:Number;
	var speed:Number;
	
	public function Buttlet()
	{
		filters = BLACK_BORDER; 
		cacheAsBitmap = true;
	}
	
	override public function set text(value:String):void
	{
		htmlText = "<font size='18' color='#FFFFFF'><b>" + value.substring(1, value.length - 1) + "<b></font>";
		width = textWidth + 4;
		height = textHeight + 4;
	}
	
	override public function set scrollRect(value:Rectangle):void
	{
		x = value.right;
		y = value.top + Math.random() * (value.height - height);
		speed = 2 + 2 * Math.random();
		x0 = value.left - width - speed;
	}
}