package com.qcenzo.apps.chatroom.effects
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	public class Effect
	{
		private var tmr:Timer;
		private var counter:int;

		public function Effect(delay:int)
		{
			tmr = new Timer(delay);
			tmr.addEventListener(TimerEvent.TIMER, onTimer);
		}
		
		public function play(sec:int = -1):void
		{
			counter = sec > 0 ? 1000 * sec / tmr.delay : -1;
			tmr.start();
		}
		
		public function stop():void
		{
			tmr.stop();
		}
		
		public final function clear():void
		{
			tmr.stop();
			tmr.removeEventListener(TimerEvent.TIMER, onTimer);
			dispose();
		}
		
		protected function dispose():void 
		{
		}
		
		private function onTimer(event:TimerEvent):void
		{
			if (counter > 0 && tmr.currentCount > counter)
			{
				tmr.reset();
				reset();
			}
			else
				onTick();
		}
		
		protected function reset():void
		{
		}
		
		protected function onTick():void
		{
		}
	}
}
