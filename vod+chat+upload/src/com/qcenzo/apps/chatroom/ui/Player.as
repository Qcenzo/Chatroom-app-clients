package com.qcenzo.apps.chatroom.ui
{
	import com.qcenzo.apps.chatroom.effects.Effect;
	import com.qcenzo.apps.chatroom.effects.Snow;
	import com.qcenzo.apps.chatroom.utils.StringTool;
	import com.qcenzo.light.components.Document;
	import com.qcenzo.light.components.SimpleLoader;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.StageDisplayState;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	public class Player extends Document implements IPlayer
	{
		include "vars/playerVars.as"; 
		
		[Embed(source="assets/player.qua", mimeType="application/octet-stream")]
		private var bytes:Class;
		private var sett:Setting;
		private var totalTime:String;
		private var paused:Boolean;
		private var snow:Effect;
		private var rect:Rectangle;
		private var watermark:SimpleLoader;
		
		public function Player()
		{
			super(new bytes());

			rect = new Rectangle();
			
			switchTogStatus(true);
			hotArea.addEventListener(MouseEvent.CLICK, onClick);
			playToggleSp.addEventListener(MouseEvent.CLICK, onClick);
			
			volSld.value = 1;
			volSld.maximum = 10;
			volSld.visible = false;
			volToggleBt.onClick = switchVolSlider;
			
			fullScreenBt.onClick = switchFs;
			settingBt.onClick = openSetting;
			
			snow = new Snow(cover) as Effect;  
			snow.play();
		}
		
		public function get componentBox():DisplayObjectContainer
		{
			return componentSp;
		}
		
		public function get progressSlider():Slider
		{
			return videoProSld;
		}
		
		public function get bufferBar():DisplayObject
		{
			return bufferBrand;
		}
		
		public function get bufferTip():DisplayObject
		{
			return bufTip;
		}
		
		public function get volumeSlider():Slider
		{
			return volSld;
		}
		
		public function get playToggle():InteractiveObject
		{
			return playToggleSp;
		}
		
		public function get playToggleHotAre():InteractiveObject
		{
			return hotArea;
		}
		
		public function get replayToggle():InteractiveObject
		{
			return replayBt;
		}
		
		public function get videoContainer():Video
		{ 
			return video;
		}
		
		public function beforePlay():void
		{
			if (snow != null)
			{
				snow.clear();
				snow = null;
			}
			
			if (watermark != null && contains(watermark))
				removeChild(watermark);
		}
		
		public function onMetaData(info:Object):void
		{
			totalTime = StringTool.formatMMSS(info.duration);
			
			scale(info.width, info.height);
			stage.fullScreenSourceRect = rect;
			
			switchTogStatus(false); 
		}
		
		public function onTick(currentTime:int):void
		{
			timeTf.text = "[" + StringTool.formatMMSS(currentTime) + "/" + totalTime + "]";
		}
		
		public function addWaterMark(file:String, bound:Object):void
		{
			watermark = new SimpleLoader();
			watermark.tryReloadTime = 10;
			watermark.x = video.x + video.width - bound.width - bound.y;
			watermark.y = bound.y;
			watermark.width = bound.width;
			watermark.height = bound.height;
			watermark.url = file;
			addChild(watermark);
		}
		
		private function onClick(event:MouseEvent):void
		{
			switchTogStatus(paused = !paused);
		}
		
		private function switchTogStatus(v:Boolean):void
		{
			playToggleSp.getChildAt(1).visible = !v;
			playToggleSp.getChildAt(0).visible = playIco.visible = v;
		}
		
		private function switchVolSlider():void
		{
			volSld.visible = !volSld.visible;
		}
		
		private function switchFs():void
		{
			stage.displayState = stage.displayState == StageDisplayState.NORMAL ?
				StageDisplayState.FULL_SCREEN : StageDisplayState.NORMAL;
		}
		
		private function openSetting():void
		{
			sett ||= new Setting(video); 
			contains(sett) ? removeChild(sett) : addChild(sett);
		}
		
		private function scale(width:int, height:int):void
		{
			if (width > height)
			{
				video.width = cover.width;
				video.height = cover.width * height / width;
				video.x = cover.x;
				video.y = cover.y + (cover.height - video.height >> 1);
			}
			else
			{
				video.height = cover.height;
				video.width = cover.height * width / height;
				video.x = cover.x + (cover.width - video.width >> 1);
				video.y = cover.y;
			}
			
			rect.x = video.x;
			rect.y = video.y;
			rect.width = video.width;
			rect.height = video.height;
		}
	}
}