package com.qcenzo.apps.chatroom.net
{
	import com.qcenzo.apps.chatroom.ui.IPlayer;
	
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.media.SoundTransform;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	public class NetStreamX extends NetStream
	{
		private var ticker:Shape;
		private var waited:Boolean;
		private var paused:Boolean;
		private var params:Array;
		private var tickFunc:Function;
		private var pui:IPlayer;
		private var d:int;

		public function NetStreamX(connection:NetConnection, player:IPlayer, bufferTime:int = 1, inBufferSeek:Boolean = true)
		{
			super(connection);
			super.bufferTime = bufferTime;
			super.inBufferSeek = inBufferSeek;
			
			pui = player;
			setupPlayer();
			
			waited = true;
			
			ticker = new Shape();
			ticker.addEventListener(Event.ENTER_FRAME, update);
			
			addEventListener(NetStatusEvent.NET_STATUS, onStatus);
		}
		
		override public function play(...parameters):void
		{
			pui.beforePlay();
			
			if (paused)
			{
				if (pui.playToggle != null)
					pui.playToggle.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
				else if (pui.playToggleHotAre != null)
					pui.playToggleHotAre.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
				else
					onToggle(null);
			}
			
			pui.componentBox.visible = false;
			if (pui.bufferTip != null)
				pui.bufferTip.visible = true;
			if (pui.replayToggle != null)
				pui.replayToggle.visible = false;
			
			waited = true;
			if (typeof parameters[0] == "string")
				params = parameters;
			super.play.apply(null, parameters); 
		}
		
		public function onMetaData(info:Object):void
		{
			d = info.duration;
			
			if (pui.progressSlider != null)
				pui.progressSlider.maximum = d;
			
			pui.componentBox.visible = isVod();
			if (pui.bufferTip != null)
				pui.bufferTip.visible = false;
			
			pui.onMetaData(info); 
		}
		
		public function onTextData(info:Object):void
		{
			if (info.hasOwnProperty("handler"))
				pui[info.handler].apply(null, info.parameters);
		}
		
		private function setupPlayer():void
		{
			if (pui.playToggle != null)
				pui.playToggle.addEventListener(MouseEvent.CLICK, onToggle);
			if (pui.playToggleHotAre != null)
				pui.playToggleHotAre.addEventListener(MouseEvent.CLICK, onToggle);
			
			if (pui.progressSlider != null)
				pui.progressSlider.onChange = changeProgress;
			
			if (pui.volumeSlider != null)
			{
				pui.volumeSlider.onChange = changeVolume;
				changeVolume();
			}
			
			if (pui.replayToggle != null)
			{
				pui.replayToggle.visible = false;
				pui.replayToggle.addEventListener(MouseEvent.CLICK, onReplay);
			}
			
			pui.videoContainer.smoothing = true;
			pui.videoContainer.attachNetStream(this);
			
			pui.componentBox.visible = false;
		}
		
		private function onStatus(event:NetStatusEvent):void
		{
			switch (event.info.code)
			{
				case "NetStream.Buffer.Full":
				case "NetStream.Seek.Notify":
					if (isVod())
						waited = false;
					break;
			}
		}
		
		private function update(event:Event):void
		{
			if (waited)
				return;
			
			if (time >= d)
			{
				waited = true;
				reset();
			}
			
			if (pui.progressSlider != null)
			{
				pui.progressSlider.value = time;
				
				if (pui.bufferBar != null)
					pui.bufferBar.width = pui.progressSlider.trackedDistance +
						pui.progressSlider.distance * bufferLength / d;
			}
			
			pui.onTick(time);
		}
		
		private function changeVolume():void
		{
			var s:SoundTransform = soundTransform;
			s.volume = pui.volumeSlider.maximum - pui.volumeSlider.value;
			soundTransform = s;
		}
		
		private function changeProgress():void
		{
			waited = true;
			if (pui.progressSlider.value == d)
				reset();
			else
				seek(pui.progressSlider.value);
		}
		
		private function onToggle(event:MouseEvent):void
		{
			paused = !paused;
			togglePause();
		}
		
		private function onReplay(event:MouseEvent):void
		{
			isVod() && this.play.apply(null, params);
		}
		
		private function isVod():Boolean
		{
			return params != null && 
				(params.length == 1 || (params.length > 1 && params[1] >= 0)); 
		}
		
		private function reset():void
		{
			dispose();
			pui.componentBox.visible = false;
			if (pui.replayToggle != null)
				pui.replayToggle.visible = true;
		}
	}
}