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
package org.davidbuhler.formandfunction
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import mx.collections.ArrayCollection;
	import mx.controls.Label;
	import mx.controls.TextInput;
	import mx.core.UIComponent;
	import mx.core.UIComponentDescriptor;
	import mx.events.FlexEvent;
	import mx.events.ValidationResultEvent;
	import mx.formatters.DateFormatter;
	import mx.managers.IFocusManagerComponent;
	import mx.validators.CreditCardValidator;
	import mx.validators.CreditCardValidatorCardType;
	import mx.validators.StringValidator;
	import mx.validators.Validator;

	import org.davidbuhler.controls.BaseComboBox;
	import org.davidbuhler.formandfunction.common.FormItemTypes;
	import org.davidbuhler.formandfunction.model.FormatHintsModel;
	import org.davidbuhler.formandfunction.utils.Utils;
	import org.davidbuhler.formandfunction.vo.UIComponentVO;

	public class BaseForm extends AbstractForm
	{

		public static const SAVE_EVENT:String='saveEvent';

		public function BaseForm()
		{
			super();
			this.addEventListener(FlexEvent.SHOW, handleShow);
			this.addEventListener(FlexEvent.HIDE, handleHide);
			this.addEventListener(FlexEvent.CREATION_COMPLETE, handleCreationComplete);
			this.addEventListener(FlexEvent.ADD, handleChildrenChange);
			this.addEventListener(FlexEvent.REMOVE, handleChildrenChange);
			if (validateOnReturnKeyClick)
			{
				this.addEventListener(KeyboardEvent.KEY_UP, handleEnterKey);
			}
		}

		[Bindable]
		public var errorsCount:int=0;

		[Bindable]
		public var requiredFieldCount:int=0;

		[Inspectable]
		public var validateOnReturnKeyClick:Boolean=true;

		private var _autoSaveEnabled:Boolean=false;
		private var _autoSaveInvalidForm:Boolean=true;
		private var _autoSaveInterval:uint=60000;
		private var _autoSaveLimit:uint=100;
		private var _autoSaveTimer:Timer;

		private var _controlsOriginalValues:Array;

		private var _firstFocussedControl:DisplayObject;

		private var _focussedControl:DisplayObject;

		private var _formValidators:Array;

		private var _isFirstFocusComplete:Boolean=false;

		private var _isFormDirty:Boolean=false;

		private var _isFormValid:Boolean=false;

		private var _lastSaved:Date;

		private var _originalState:UIComponentDescriptor;

		private var _validatedControls:ArrayCollection=new ArrayCollection();

		private var _validators:ArrayCollection=new ArrayCollection();

		private var dateFormat:String="MM/DD/YYYY";


		[Bindable]
		public function get autoSaveInvalidForm():Boolean
		{
			return this._autoSaveInvalidForm;
		}

		[Inspectable]
		public function set autoSaveInvalidForm(value:Boolean):void
		{
			this._autoSaveInvalidForm=value;
		}

		[Bindable]
		public function get autoSaveEnabled():Boolean
		{
			return this._autoSaveEnabled;
		}

		[Inspectable]
		public function set autoSaveEnabled(value:Boolean):void
		{
			this._autoSaveEnabled=value;
		}

		public function get autoSaveInterval():uint
		{
			return this._autoSaveInterval;
		}

		[Inspectable]
		public function set autoSaveInterval(value:uint):void
		{
			this._autoSaveInterval=value;

			if (_autoSaveTimer)
			{
				_autoSaveTimer.reset();
			}
			if (value)
			{
				_autoSaveTimer=new Timer(this.autoSaveInterval, this.autoSaveLimit);

				_autoSaveTimer.addEventListener(TimerEvent.TIMER, handleSaveFormInterval);
				_autoSaveTimer.addEventListener(TimerEvent.TIMER_COMPLETE, handleAutoSaveExpiration);

				_autoSaveTimer.start();
			}
		}

		public function get autoSaveLimit():uint
		{
			return this._autoSaveLimit;
		}

		[Inspectable]
		public function set autoSaveLimit(value:uint):void
		{
			this._autoSaveLimit=value;
		}

		public function get formValues():Array
		{
			var valuesList:Array=new Array();
			var formItems:Array=this.getRegisteredFormItemsLength();
			for (var i:uint=0; i < formItems.length; i++)
			{
				if (formItemAllowsRegistration(formItems[i]))
				{
					var uiComponentVO:UIComponentVO=new UIComponentVO(BaseFormItem(formItems[i]).id, BaseFormItem(formItems[i]).value);
					valuesList.push(uiComponentVO);
				}
			}
			return valuesList;
		}

		public function handleAutoSaveExpiration(event:TimerEvent):void
		{
			trace("Autosaving has expired");
			this.removeEventListener(TimerEvent.TIMER, handleSaveFormInterval);
			this.removeEventListener(TimerEvent.TIMER_COMPLETE, handleAutoSaveExpiration);
		}



		public function handleSaveFormInterval(event:TimerEvent):void
		{
			//trace('handleSaveFormInterval');
			if (!this.isFormDirty)
			{
				return;
			}
			if (!autoSaveInvalidForm && !isFormValid)
			{
				return;
			}
			dispatchEvent(new Event(SAVE_EVENT));
		}

		[Bindable]
		public function get isFormDirty():Boolean
		{
			return this._isFormDirty;
		}

		public function set isFormDirty(value:Boolean):void
		{
			this._isFormDirty=value;
		}

		[Bindable]
		public function get isFormValid():Boolean
		{
			return this._isFormValid;
		}

		public function set isFormValid(value:Boolean):void
		{
			this._isFormValid=value;
		}

		public function get lastSaved():Date
		{
			return this._lastSaved;
		}

		[Inspectable]
		public function set lastSaved(value:Date):void
		{
			this._lastSaved=value;
		}

		public function get lastSavedLabel():String
		{
			var str:String=!lastSaved ? 'Never' : Utils.getLastSavedDateTime(lastSaved);
			return 'Last Auto-Saved : ' + ' ' + str;
		}

		public function resetForm():void
		{
			this.setCursorFocus();
		}

		protected function handleHide(event:FlexEvent):void
		{
		}

		protected function handleShow(event:FlexEvent):void
		{
			if (!isFirstFocusComplete)
			{
				isFirstFocusComplete=true;
				setCursorFocus();
			}
		}

		protected function validateAll(event:Event):void
		{
			trace('validateAll');
			this.clearErrorStrings();
			this.isFormValid=(isEntireFormValid(event, true));
		}

		private function isEntireFormValid(event:Event, isSuppressed:Boolean):Boolean
		{
			errorsCount=0;
			var areAllValid:Boolean=true;
			var len:uint=formValidators.length;
			for (var i:uint=0; i < len; i++)
			{
				var evt:ValidationResultEvent=Validator(formValidators[i]).validate(null, isSuppressed);
				var isValid:Boolean=(evt.type == ValidationResultEvent.VALID);
				if (!isValid)
				{
					errorsCount++;
					trace('errorsCount ' + errorsCount);
				}
				areAllValid=isValid && areAllValid;
			}
			return areAllValid;
		}

		private function clearError(control:UIComponent):void
		{
			if (control.errorString != '')
			{
				control.errorString='';
			}
		}

		private function clearErrorStrings():void
		{
			return;
			for (var i:uint=0; i < formValidators.length; i++)
			{
				if (formValidators[i] is UIComponent)
				{
					clearError(formValidators[i])
				}
			}
		}

		private function compare_initial_to_current_values():void
		{
			var isDirty:Boolean=false;
			var formItems:Array=this.getRegisteredFormItemsLength();
			for (var i:uint=0; i < formItems.length; i++)
			{
				if (formItemAllowsRegistration(formItems[i]))
				{
					// make sure the sorting is right for the comparison
					if (BaseFormItem(formItems[i]).id != UIComponentVO(this.controlsOriginalValues[i]).id)
					{
						throw new Error('Mis-match');
					}
					if (BaseFormItem(formItems[i]).value != UIComponentVO(this.controlsOriginalValues[i]).value)
					{
						isDirty=true;
					}
				}
			}
			isFormDirty=isDirty;
		}

		private function get controlsOriginalValues():Array
		{
			return this._controlsOriginalValues;
		}

		private function set controlsOriginalValues(value:Array):void
		{
			this._controlsOriginalValues=value;
		}

		private function enableValidators(value:Boolean):void
		{
			var len:uint=formValidators.length;
			for (var i:uint=0; i < len; i++)
			{
				Validator(formValidators[i]).enabled=value;
			}
		}

		private function get firstFocussedControl():DisplayObject
		{
			return this._firstFocussedControl;
		}

		private function set firstFocussedControl(value:DisplayObject):void
		{
			this._firstFocussedControl=value;
		}

		private function get focussedControl():DisplayObject
		{
			return this._focussedControl
		}

		private function set focussedControl(value:DisplayObject):void
		{
			this._focussedControl=value;
		}

		private function get formValidators():Array
		{
			return this._formValidators;
		}

		private function set formValidators(value:Array):void
		{
			this._formValidators=value;
		}

		private function format(dateString:String, dateFormat:String):String
		{
			var f:DateFormatter=new DateFormatter();
			f.formatString=dateFormat;
			return f.format(dateString);
		}

		private function getRegisteredFormItemsLength():Array
		{
			var formItems:Array=this.getChildren();
			var registeredItems:Array=new Array();
			for (var i:uint=0; i < formItems.length; i++)
			{
				if (formItemAllowsRegistration(formItems[i]))
				{
					registeredItems.push(formItems[i]);
				}
			}
			return registeredItems;
		}

		private function handleChange(event:Event):void
		{
			this.compare_initial_to_current_values();
		}

		private function handleChildrenChange(event:FlexEvent):void
		{
			registerControlsWithValidators(event);
		}

		private function handleCreationComplete(event:FlexEvent):void
		{
			registerControlsWithValidators(event);
		}

		private function handleCreditCardTypeChange(event:Event):void
		{
			var formItems:Array=this.getRegisteredFormItemsLength();
			var ccNumberHint:String;
			var ccCodeHint:String;
			var formatHintsModel:FormatHintsModel=new FormatHintsModel();
			for (var i:uint=0; i < formItems.length; i++)
			{
				if (formItemAllowsRegistration(formItems[i]))
				{
					var cardTypeSource:String=BaseComboBox(event.currentTarget).selectedLabel;
					if (BaseFormItem(formItems[i]).type == FormItemTypes.CREDIT_CARD_SECURITY_CODE)
					{
						BaseFormItem(formItems[i]).cardTypeSource=cardTypeSource;
						var stringValidator:Validator=BaseFormItem(formItems[i]).validator;
						var ccSecurityCodeTextInput:TextInput=TextInput(BaseFormItem(formItems[i]).controlInstance);
						StringValidator(stringValidator).minLength=(BaseComboBox(event.currentTarget).selectedLabel == CreditCardValidatorCardType.AMERICAN_EXPRESS) ? 4 : 3;
						var maxSecurityCodeCharsAllowed:int=(BaseComboBox(event.currentTarget).selectedLabel == CreditCardValidatorCardType.AMERICAN_EXPRESS) ? 4 : 3;
						if (ccSecurityCodeTextInput.maxChars != maxSecurityCodeCharsAllowed)
						{
							ccSecurityCodeTextInput.text='';
						}
						switch (cardTypeSource)
						{
							case CreditCardValidatorCardType.AMERICAN_EXPRESS:
								ccCodeHint=formatHintsModel.creditCardSecurityCode_AmericanExpress;
								break;
							case CreditCardValidatorCardType.DINERS_CLUB:
								;
								ccCodeHint=formatHintsModel.creditCardSecurityCode_DinersClub;
								break;
							case CreditCardValidatorCardType.DISCOVER:
								ccCodeHint=formatHintsModel.creditCardSecurityCode_Discover;
								break;
							case CreditCardValidatorCardType.MASTER_CARD:
								ccCodeHint=formatHintsModel.creditCardSecurityCode_MasterCard;
								break;
							case CreditCardValidatorCardType.VISA:
								ccCodeHint=formatHintsModel.creditCardSecurityCode_Visa;
								break;
							default:
								throw new Error('unhandled condition');
								break;
						}
						Label(BaseFormItem(formItems[i]).formatHintLabel).text=ccCodeHint;
						ccSecurityCodeTextInput.maxChars=maxSecurityCodeCharsAllowed;
						ccSecurityCodeTextInput.enabled=true;
					}
					if (BaseFormItem(formItems[i]).type == FormItemTypes.CREDIT_CARD_NUMBER)
					{
						BaseFormItem(formItems[i]).cardTypeSource=cardTypeSource;
						var creditCardValidator:Validator=BaseFormItem(formItems[i]).validator;
						var ccNumberTextInput:TextInput=TextInput(BaseFormItem(formItems[i]).controlInstance);
						CreditCardValidator(creditCardValidator).cardTypeProperty=cardTypeSource;
						var maxNumbersAllowed:int;
						switch (cardTypeSource)
						{
							case CreditCardValidatorCardType.AMERICAN_EXPRESS:
								maxNumbersAllowed=15;
								ccNumberHint=formatHintsModel.creditCardNumber_AmericanExpress;
								break;
							case CreditCardValidatorCardType.DINERS_CLUB:
								maxNumbersAllowed=14;
								ccNumberHint=formatHintsModel.creditCardNumber_DinersClub;
								break;
							case CreditCardValidatorCardType.DISCOVER:
								maxNumbersAllowed=16;
								ccNumberHint=formatHintsModel.creditCardNumber_Discover;
								break;
							case CreditCardValidatorCardType.MASTER_CARD:
								maxNumbersAllowed=16;
								ccNumberHint=formatHintsModel.creditCardNumber_MasterCard;
								break;
							case CreditCardValidatorCardType.VISA:
								maxNumbersAllowed=16;
								ccNumberHint=formatHintsModel.creditCardNumber_Visa;
								break;
							default:
								throw new Error('unhandled condition');
								break;
						}
						Label(BaseFormItem(formItems[i]).formatHintLabel).text=ccNumberHint;
						if (ccNumberTextInput.maxChars != maxNumbersAllowed)
						{
							ccNumberTextInput.text='';
						}
						ccNumberTextInput.maxChars=maxNumbersAllowed;
						ccNumberTextInput.enabled=true;
					}
				}
			}

		}

		private function handleEnterKey(event:KeyboardEvent):void
		{
			if (event.charCode == 13)
			{
				if (isEntireFormValid(null, false))
				{
					dispatchEvent(new Event(SAVE_EVENT));
				}
			}
			event.stopPropagation();
		}

		private function formItemAllowsRegistration(item:DisplayObject):Boolean
		{
			return item.hasOwnProperty('allowRegistration');
		}

		private function get isFirstFocusComplete():Boolean
		{
			return this._isFirstFocusComplete;
		}

		private function set isFirstFocusComplete(value:Boolean):void
		{
			this._isFirstFocusComplete=value;
		}

		private function registerControlsOriginalValues(value:Array):void
		{
			this._controlsOriginalValues=new Array();
			this.controlsOriginalValues=value;
		}

		private function registerControlsWithValidators(event:FlexEvent):void
		{
			var formItems:Array=this.getRegisteredFormItemsLength();
			var controlsAndInitialValues:Array=new Array();
			formValidators=new Array();
			for (var i:uint=0; i < formItems.length; i++)
			{
				var formItemAllowsRegistration:Boolean=formItemAllowsRegistration(formItems[i])
				if (formItemAllowsRegistration)
				{
					trace('formItemAllowsRegistration = ' + formItemAllowsRegistration);
					trace('formItem is = ' + formItems[i]);
					var len:Number=BaseFormItem(formItems[i]).registeredControls.length;
					var formItem:BaseFormItem=BaseFormItem(formItems[i])
					var uiComponentVO:UIComponentVO=new UIComponentVO(formItem.id, formItem.value);
					controlsAndInitialValues.push(uiComponentVO);

					for (var a:uint=0; a < len; a++)
					{
						var control2:DisplayObject=DisplayObject(BaseFormItem(formItems[i]).registeredControls[a]);
						control2.addEventListener(Event.CHANGE, handleChange);
					}

					if (BaseFormItem(formItems[i]).type == FormItemTypes.CREDIT_CARD_TYPE)
					{
						BaseFormItem(formItems[i]).controlInstance.addEventListener(Event.CHANGE, handleCreditCardTypeChange);
					}

					if (BaseFormItem(formItems[i]).required)
					{
						trace('required field');
						formValidators.push(Validator(BaseFormItem(formItems[i]).registeredValidator));
						/*
						   only going to validate the required fields
						 */
						var k:uint=0;
						for (k=0; k < len; k++)
						{
							var control:DisplayObject=DisplayObject(BaseFormItem(formItems[i]).registeredControls[k]);
							trace('control registered with validator = ' + control);
							control.addEventListener(Event.CHANGE, validateAll);
						}
						this.requiredFieldCount=k;
					}
				}
			}

			this.registerControlsOriginalValues(controlsAndInitialValues);
		}

		private function resetState():void
		{
			this.setCursorFocus();
		}

		private function setCursorFocus():void
		{
			if (this.getRegisteredFormItemsLength().length > 0)
			{
				var control:DisplayObject=BaseFormItem(this.getChildAt(0)).registeredControls[0];
				focusManager.setFocus(control as IFocusManagerComponent);
			}
		}
	}
}

