package com.qcenzo.apps.chatroom.ui
{
	import com.qcenzo.light.components.Slider;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.media.Video;

	public interface IPlayer
	{
		function get componentBox():DisplayObjectContainer;
		
		function get progressSlider():Slider;
		
		function get bufferBar():DisplayObject;
		
		function get bufferTip():DisplayObject;
		
		function get volumeSlider():Slider;
		
		function get playToggle():InteractiveObject;
		
		function get playToggleHotAre():InteractiveObject;
		
		function get replayToggle():InteractiveObject;
		
		function get videoContainer():Video;
		
		function beforePlay():void;
		
		function onMetaData(info:Object):void;
		
		function onTick(currentTime:int):void;
	}
}