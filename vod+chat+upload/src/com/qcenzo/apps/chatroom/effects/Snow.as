package com.qcenzo.apps.chatroom.effects
{
	import flash.display.Bitmap;
	import flash.utils.getTimer;

	public class Snow extends Effect
	{
		private var canvs:Bitmap;
		
		public function Snow(canvas:Bitmap)
		{
			super(100);
			canvs = canvas;
		}
		
		override protected function onTick():void
		{
			canvs.bitmapData.noise(getTimer(), 120, 250, 7, false);
		}
		
		override protected function dispose():void 
		{
			canvs.parent && canvs.parent.removeChild(canvs);
			canvs = null;
		}
	}
}