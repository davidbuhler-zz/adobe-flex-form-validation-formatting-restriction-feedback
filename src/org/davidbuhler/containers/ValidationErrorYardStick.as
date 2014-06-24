/*
 * #%L
 * GwtBootstrap3
 * %%
 * Copyright (C) 2013 FormFunction
 * %%
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * #L%
 */
package org.davidbuhler.containers
{
	import flash.filters.BitmapFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BitmapFilterType;
	import flash.filters.GradientBevelFilter;

	import mx.containers.VBox;

	public class ValidationErrorYardStick extends VBox
	{
		public function ValidationErrorYardStick()
		{

			super();
			var filter:BitmapFilter=getBitmapFilter();
			var myFilters:Array=new Array();
			myFilters.push(filter);
			filters=myFilters;
		}
		private var alphas:Array=[1, 1, 1];
		private var angleInDegrees:Number=0; // opposite 45 degrees


		private var bgColor:uint=0xffffff;
		private var blurX:Number=0;
		private var blurY:Number=0;
		private var colors:Array=[0xCC1100, 0xCC1100, 0xCC1100];
		private var distance:Number=10;
		private var knockout:Boolean=true;
		private var offset:uint=0;
		private var quality:Number=BitmapFilterQuality.HIGH
		private var ratios:Array=[0, 100, 255];
		private var size:uint=5;
		private var strength:Number=2;
		private var type:String=BitmapFilterType.INNER;

		private function getBitmapFilter():BitmapFilter
		{
			return new GradientBevelFilter(distance, angleInDegrees, colors, alphas, ratios, blurX, blurY, strength, quality, type, knockout);
		}
	}
}

