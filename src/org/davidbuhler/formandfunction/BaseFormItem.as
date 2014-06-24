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
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import mx.containers.BoxDirection;
	import mx.containers.Canvas;
	import mx.containers.FormItem;
	import mx.containers.HBox;
	import mx.containers.Tile;
	import mx.controls.ButtonLabelPlacement;
	import mx.controls.CheckBox;
	import mx.controls.ComboBox;
	import mx.controls.Label;
	import mx.controls.LinkButton;
	import mx.controls.NumericStepper;
	import mx.controls.RadioButton;
	import mx.controls.RadioButtonGroup;
	import mx.controls.RichTextEditor;
	import mx.controls.TextInput;
	import mx.core.Application;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.events.ValidationResultEvent;
	import mx.formatters.CurrencyFormatter;
	import mx.formatters.DateFormatter;
	import mx.formatters.Formatter;
	import mx.formatters.NumberBaseRoundType;
	import mx.formatters.PhoneFormatter;
	import mx.formatters.ZipCodeFormatter;
	import mx.managers.PopUpManager;
	import mx.rpc.Fault;
	import mx.validators.CreditCardValidator;
	import mx.validators.CreditCardValidatorCardType;
	import mx.validators.CurrencyValidator;
	import mx.validators.DateValidator;
	import mx.validators.EmailValidator;
	import mx.validators.NumberValidator;
	import mx.validators.PhoneNumberValidator;
	import mx.validators.RegExpValidator;
	import mx.validators.SocialSecurityValidator;
	import mx.validators.StringValidator;
	import mx.validators.Validator;
	import mx.validators.ZipCodeValidator;
	import org.davidbuhler.containers.GradientCanvas;
	import org.davidbuhler.controls.BaseComboBox;
	import org.davidbuhler.formandfunction.common.ControlSizes;
	import org.davidbuhler.formandfunction.common.FormItemTypes;
	import org.davidbuhler.formandfunction.common.InputRestrictions;
	import org.davidbuhler.formandfunction.common.ValidityStates;
	import org.davidbuhler.formandfunction.model.DefaultLabelModel;
	import org.davidbuhler.formandfunction.model.FormatHintsModel;
	import org.davidbuhler.formandfunction.presentation.windows.ContentWindow;
	import org.davidbuhler.formandfunction.utils.Utils;
	import org.davidbuhler.formandfunction.validators.CheckBoxValidator;
	import org.davidbuhler.formandfunction.validators.CollectionValidator;
	import org.davidbuhler.formandfunction.validators.ComboBoxValidator;
	import org.davidbuhler.formandfunction.validators.StringMatchValidator;
	import org.davidbuhler.formandfunction.vo.CheckBoxVO;
	import org.davidbuhler.formandfunction.vo.RadioButtonVO;

	public class BaseFormItem extends FormItem
	{

		public static const ZIP_CODE_DOMAIN:String="US Only";

		private static const BACKGROUND_COLOR_STYLE:String='backgroundColor';
		private static const HIDE_LABEL:String='Hide';
		private static const PROPERTY_LENGTH:String='length';
		private static const PROPERTY_SELECTED:String='selected';
		private static const PROPERTY_SELECTED_INDEX:String='selectedIndex';
		private static const PROPERTY_TEXT:String='text';
		private static const PROPERTY_VALUE:String='value';
		private static const SELECTED_VALUE:String='selectedValue';
		private static const SELECT_A_PREFIX:String='Select a ';
		private static const SHOW_LABEL:String='Show';

		private static var defaultLabelModel:DefaultLabelModel=new DefaultLabelModel();

		private static var tabIndex:int=-1;

		private static function getCaptcha():String
		{
			var userAlphabet:String="abcdefghijkmnopqrstuvwxyzABCDEFGHIJKLMNPQRSTUVWXYZ123456789";
			var alphabet:Array=userAlphabet.split("");
			var alphabetLength:int=alphabet.length;
			var randomLetters:String="";
			for (var i:uint=0; i < InputRestrictions.CAPTCHA_MAX_CHARS; i++)
			{
				randomLetters+=alphabet[int(Math.floor(Math.random() * alphabetLength))];
			}
			return randomLetters;
		}

		public function BaseFormItem()
		{
			super();
			this.tabIndex=-1;
			this.explicitWidth=550;
			if (type == FormItemTypes.CAPTCHA)
			{
				this.direction=BoxDirection.VERTICAL;
			}
			else
			{
				this.direction=BoxDirection.HORIZONTAL;
			}

		}
		public var allowRegistration:Boolean=true;

		[Inspectable(enumeration="EEEE, MMM. D,YYYY at L:NN A,YYYY.MM.DD at HH:NN:SS,EEE,MMM D,'YY,H:NN A,HH o'clock A,K:NN A,YYYYY.MMMM.DD. JJ:NN A,MM/DD/YYYY", defaultValue="MM/DD/YYYY")]
		public var dateFormat:String;
		public var formatHintLabel:Label=new Label();

		[Inspectable(enumeration="###.###.####,(###) ###-####,(###) ### ####,###-###-####,#(###) ### ####,#-###-###-####,+###-###-###-####", defaultValue="(###) ###-####")]
		public var phoneNumberFormat:String;

		[Inspectable]
		public var showFormatHint:Boolean=true;

		[Inspectable(enumeration="address1,address2,captcha,checkBox,comboBox,creditCardExpirationDate,creditCardNumber,creditCardSecurityCode,creditCardType,currency,date,email,fileManager,firstName,lastName,numericStepper,password,phoneNumber,radioButtonGroup,richTextEditor,socialSecurity,textInput,time,uri,zipCode", defaultValue="")]
		public var type:String;

		[Inspectable]
		public var up_text_color:uint=0x000000;
		public var validator:Validator;
		private var _cachedColorState:String='';
		private var _cardTypeSource:String;
		private var _checkBoxList:Array=new Array();
		private var _controlProperty:String;
		private var _customFormatter:Formatter;
		private var _customValidator:Validator;
		private var _dataProvider:Object;
		private var _dateValidator:DateValidator=new DateValidator();
		private var _excludeAmericanExpress:Boolean=false;
		private var _excludeDinersClub:Boolean=false;
		private var _excludeDiscover:Boolean=false;
		private var _excludeMasterCard:Boolean=false;
		private var _excludeVisa:Boolean=false;
		private var _formatHint:String;
		private var _formatter:Formatter;
		private var _lastFormItemSyle:String;
		private var _maxLength:uint=75;
		private var _maxValue:uint=100;
		private var _minLength:uint=2;
		private var _minValue:uint=0;
		private var _nonFormattedLabel:String='';
		private var _openLinksInNewWindow:Boolean=false;
		private var _radioButtonList:Array=new Array();
		private var _registeredControls:Array=new Array();
		private var _registeredValidator:Validator;
		private var _restriction:String=InputRestrictions.RESRICT_TO_GENERIC;
		private var _selectedRadioButtonValue:String;
		private var _showWarnings:Boolean=false;
		private var _stepSize:uint=1;
		private var _whatsThisLabel:String="What's this?";
		private var _whatsThisURL:String='';
		private var _control:*;
		private var _formatHintsModel:FormatHintsModel=new FormatHintsModel();
		private var radioButtonGroup:RadioButtonGroup;

		[Bindable]
		public function get cardTypeSource():String
		{
			return this._cardTypeSource;
		}

		public function set cardTypeSource(value:String):void
		{
			this._cardTypeSource=value;
		}

		[Bindable]
		public function get checkBoxList():Array
		{
			return this._checkBoxList;
		}

		[Inspectable]
		public function set checkBoxList(value:Array):void
		{
			this._checkBoxList=value;
			setCheckBoxList();
		}

		public function get controlInstance():DisplayObject
		{
			return this._control;
		}

		public function get controlProperty():String
		{
			return this._controlProperty;
		}

		public function set controlProperty(value:String):void
		{
			this._controlProperty=value;
		}

		public function get customFormatter():Formatter
		{
			return this._customFormatter;
		}

		public function set customFormatter(value:Formatter):void
		{
			this._customFormatter=value;
		}

		public function get customValidator():Validator
		{
			return this._customValidator;
		}

		public function set customValidator(value:Validator):void
		{
			this._customValidator=value;
		}

		public function get excludeAmericanExpress():Boolean
		{
			return this._excludeAmericanExpress;
		}

		[Inspectable]
		public function set excludeAmericanExpress(value:Boolean):void
		{
			this._excludeAmericanExpress=value;
		}

		public function get excludeDinersClub():Boolean
		{
			return this._excludeDinersClub;
		}

		[Inspectable]
		public function set excludeDinersClub(value:Boolean):void
		{
			this._excludeDinersClub=value;
		}

		public function get excludeDiscover():Boolean
		{
			return this._excludeDiscover;
		}

		[Inspectable]
		public function set excludeDiscover(value:Boolean):void
		{
			this._excludeDiscover=value;
		}

		public function get excludeMasterCard():Boolean
		{
			return this._excludeMasterCard;
		}

		[Inspectable]
		public function set excludeMasterCard(value:Boolean):void
		{
			this._excludeMasterCard=value;
		}

		public function get excludeVisa():Boolean
		{
			return this._excludeVisa;
		}

		[Inspectable]
		public function set excludeVisa(value:Boolean):void
		{
			this._excludeVisa=value;
		}

		[Bindable]
		public function get formatHint():String
		{
			return this._formatHint;
		}

		public function set formatHint(value:String):void
		{
			this._formatHint=value;
		}

		[Bindable]
		public function get maxLength():uint
		{
			return this._maxLength;
		}

		public function set maxLength(value:uint):void
		{
			this._maxLength=value;
		}

		[Bindable]
		public function get maxValue():uint
		{
			return this._maxValue;
		}

		public function set maxValue(value:uint):void
		{
			this._maxValue=value;
		}

		[Bindable]
		public function get minLength():uint
		{
			return this._minLength;
		}

		public function set minLength(value:uint):void
		{
			this._minLength=value;
		}

		[Bindable]
		public function get minValue():uint
		{
			return this._minValue;
		}

		public function set minValue(value:uint):void
		{
			this._minValue=value;
		}

		[Inspectable]
		public function get openLinksInNewWindow():Boolean
		{
			return this._openLinksInNewWindow;
		}

		public function set openLinksInNewWindow(value:Boolean):void
		{
			this._openLinksInNewWindow=value;
		}

		[Bindable]
		public function get radioButtonList():Array
		{
			return this._radioButtonList;
		}

		[Inspectable]
		public function set radioButtonList(value:Array):void
		{
			this._radioButtonList=value;
			setRadioButtonList();
		}

		public function get registeredControls():Array
		{
			return this._registeredControls;
		}

		public function get registeredValidator():Validator
		{
			return this._registeredValidator;
		}

		public function set registeredValidator(value:Validator):void
		{
			this._registeredValidator=value;
		}

		[Bindable]
		public function get restriction():String
		{
			return this._restriction;
		}

		public function set restriction(value:String):void
		{
			this._restriction=value;
		}

		public function get selectedRadioButtonValue():String
		{
			return this._selectedRadioButtonValue;
		}

		public function set selectedRadioButtonValue(value:String):void
		{
			this._selectedRadioButtonValue=value;
			RadioButtonGroup(radioButtonGroup).selectedValue=value;
		}

		public function get showWarnings():Boolean
		{
			return this._showWarnings;
		}

		[Inspectable]
		public function set showWarnings(value:Boolean):void
		{
			this._showWarnings=value;
		}

		[Bindable]
		public function get stepSize():uint
		{
			return this._minLength;
		}

		public function set stepSize(value:uint):void
		{
			this._stepSize=value;
		}

		public function get value():*
		{
			switch (type)
			{
				case FormItemTypes.ADDRESS_1:
					return Utils.trim(_control.text);
				case FormItemTypes.ADDRESS_2:
					return Utils.trim(_control.text);
				case FormItemTypes.CAPTCHA:
					return Utils.trim(_control.text);
				case FormItemTypes.CHECK_BOX:
					return _control.selected;
				case FormItemTypes.COMBO_BOX:
					return BaseComboBox(_control).selectedValue;
				case FormItemTypes.CREDIT_CARD_EXPIRATION_DATE:
					return Utils.trim(_control.text);
				case FormItemTypes.CREDIT_CARD_NUMBER:
					return Utils.trim(_control.text);
				case FormItemTypes.CREDIT_CARD_SECURITY_CODE:
					return Utils.trim(_control.text);
				case FormItemTypes.CREDIT_CARD_TYPE:
					return BaseComboBox(_control).dataType;
				case FormItemTypes.CURRENCY:
					return Utils.getCurrency(_control.text);
				case FormItemTypes.DATE:
					return new Date(_control.text);
				case FormItemTypes.EMAIL:
					return Utils.trim(_control.text);
				case FormItemTypes.FILE_MANAGER:
					return _control.savedFilesCollection;
				case FormItemTypes.FIRST_NAME:
					return Utils.trim(_control.text);
				case FormItemTypes.LAST_NAME:
					return Utils.trim(_control.text);
				case FormItemTypes.NUMERIC_STEPPER:
					return int(Utils.trim(_control.value));
				case FormItemTypes.PASSWORD:
					return Utils.trim(_control.text);
				case FormItemTypes.PHONE_NUMBER:
					return Utils.getNumbers(_control.text);
				case FormItemTypes.RADIO_BUTTON_GROUP:
					return RadioButtonGroup(radioButtonGroup).selectedValue;
				case FormItemTypes.RICH_TEXT_EDITOR:
					return RichTextEditor(_control).htmlText;
				case FormItemTypes.SOCIAL_SECURITY:
					return Utils.getNumbers(_control.text);
				case FormItemTypes.TEXT_INPUT:
					return Utils.trim(_control.text);
				case FormItemTypes.TIME:
					//TODO should be dated-formatted
					return _control.text;
				case FormItemTypes.URI:
					return Utils.trim(_control.text);
				case FormItemTypes.ZIP_CODE:
					return Utils.getNumbers(_control.text);
				default:
					throw new Error('Could not find the desired form-type. Received request for ' + type);
					break;
			}
		}

		[Inspectable]
		public function get whatsThisLabel():String
		{
			return this._whatsThisLabel;
		}

		public function set whatsThisLabel(value:String):void
		{
			this._whatsThisLabel=value;
		}

		[Inspectable]
		public function get whatsThisURL():String
		{
			return this._whatsThisURL;
		}

		public function set whatsThisURL(value:String):void
		{
			this._whatsThisURL=value;
		}

		protected function addChildComponent(control:DisplayObject):void
		{
			this.incrementTabIndex(control);
			this.addChild(control);
			switch (type)
			{
				case FormItemTypes.PASSWORD:
					var showPasswordCheckBox:CheckBox=new CheckBox();
					showPasswordCheckBox.label=showPasswordCheckBox.selected ? HIDE_LABEL : SHOW_LABEL;
					showPasswordCheckBox.styleName='checkBoxLabelStyle';
					showPasswordCheckBox.addEventListener(MouseEvent.CLICK, showPassword);
					this.addChild(showPasswordCheckBox);
					break;
			}
			this._registeredControls.push(control);
			this.invalidateDisplayList();
		}

		protected function addFormatHint():void
		{
			var formatHint:String=this.getFormatHint();
			var canvas:Canvas=Utils.getShadowedCanvas();
			canvas.styleName='formatHint';
			if (formatHint == '' && whatsThisURL == '')
			{
				return;
			}
			if (whatsThisURL != '')
			{
				var linkButton:LinkButton=new LinkButton();
				linkButton.y=2;
				linkButton.styleName='whatsThisButton';
				linkButton.label=whatsThisLabel=whatsThisLabel;
				linkButton.addEventListener(MouseEvent.CLICK, handleWhatsThisClick);
				canvas.addChild(linkButton);
				this.addChild(canvas);
				return;
			}
			if (this.showFormatHint && formatHint != '')
			{
				formatHintLabel.y=2;
				formatHintLabel.text=formatHint;
				formatHintLabel.styleName='formatHintLabel';
				canvas.addChild(formatHintLabel);
				this.addChild(canvas);
				return;
			}
			invalidateDisplayList();
		}

		protected function addValidatorProperties(control:*, validator:Validator):Validator
		{
			if (control is DisplayObject)
			{
				validator.source=control;
				validator.triggerEvent=Event.CHANGE;
			}
			else if (control is RadioButtonGroup)
			{
				validator.source=radioButtonGroup;
			}
			else
			{
				throw new Error('registerControl is an unknown type');
			}
			validator.addEventListener(ValidationResultEvent.VALID, validateControl);
			validator.addEventListener(ValidationResultEvent.INVALID, validateControl);
			if (!required && !showWarnings)
			{
				validator.enabled=false; //warn?
			}
			return validator;
		}

		override protected function createChildren():void
		{
			this.setFormItemLabel();
			switch (type)
			{
				case FormItemTypes.ADDRESS_1:
					_control=new TextInput();
					TextInput(_control).restrict=InputRestrictions.RESTRICT_TO_ADDRESS;
					TextInput(_control).maxChars=InputRestrictions.ADDRESS_1_MAX_CHARS;
					validator=new StringValidator();
					StringValidator(validator).minLength=minLength;
					this.registerControl(_control, validator);
					break;
				case FormItemTypes.ADDRESS_2:
					_control=new TextInput();
					TextInput(_control).restrict=InputRestrictions.RESTRICT_TO_ADDRESS;
					TextInput(_control).maxChars=InputRestrictions.ADDRESS_2_MAX_CHARS;
					validator=new StringValidator();
					StringValidator(validator).minLength=minLength;
					this.registerControl(_control, validator);
					break;
				case FormItemTypes.CAPTCHA:
					var bg:Canvas=new Canvas();
					var canvas:GradientCanvas=new GradientCanvas();
					bg.styleName='captcha';
					bg.y=10;
					canvas.y=10;
					bg.x=10;
					canvas.y=10;
					bg.width=ControlSizes.MIN_WIDTH;
					canvas.percentWidth=100;
					canvas.percentHeight=100;
					bg.height=60;
					canvas.height=50;
					var lbl:Label=new Label();
					lbl.width=ControlSizes.MIN_WIDTH;
					lbl.styleName='captchaLabel';
					lbl.text=BaseFormItem.getCaptcha();
					_control=new TextInput();
					TextInput(_control).restrict=InputRestrictions.RESTRICT_TO_NUMBERS_CHARS;
					TextInput(_control).maxChars=InputRestrictions.CAPTCHA_MAX_CHARS;
					validator=new StringMatchValidator();
					StringMatchValidator(validator).matches=lbl.text;
					canvas.addChild(lbl);
					bg.addChild(canvas);
					this.addChild(bg);
					this.registerControl(_control, validator);
					invalidateDisplayList();
					break;
				case FormItemTypes.CHECK_BOX:
					_control=new CheckBox();
					validator=new CheckBoxValidator();
					CheckBox(_control).label=this.nonFormattedLabel;
					CheckBox(_control).labelPlacement=ButtonLabelPlacement.LEFT;
					this.registerControl(_control, validator, null, PROPERTY_SELECTED);
					break;
				case FormItemTypes.CREDIT_CARD_EXPIRATION_DATE:
					_control=new TextInput();
					TextInput(_control).restrict=InputRestrictions.RESTRICT_TO_NUMBERS_FORWARD_SLASH;
					TextInput(_control).maxChars=5;
					validator=new RegExpValidator();
					//http://regexlib.com/REDetails.aspx?regexp_id=2306
					RegExpValidator(validator).expression='^((0[1-9])|(1[0-2]))[\/\.\-]*((0[8-9])|(1[1-9]))$';
					this.registerControl(_control, validator);
					break;
				case FormItemTypes.CREDIT_CARD_NUMBER:
					_control=new TextInput();
					TextInput(_control).restrict=InputRestrictions.RESTRICT_TO_NUMBERS_HYPHENS;
					TextInput(_control).enabled=false;
					validator=new CreditCardValidator();
					this.registerControl(_control, validator);
					break;
				case FormItemTypes.CREDIT_CARD_SECURITY_CODE:
					_control=new TextInput();
					TextInput(_control).restrict=InputRestrictions.RESTRICT_TO_NUMBERS;
					TextInput(_control).enabled=false;
					validator=new StringValidator();
					StringValidator(validator).requiredFieldError='The' + ' ' + defaultLabelModel.creditCardSecurityCode + ' ' + 'is required';
					this.registerControl(_control, validator);
					break;
				case FormItemTypes.CREDIT_CARD_TYPE:
					_control=new BaseComboBox();
					validator=new ComboBoxValidator();
					BaseComboBox(_control).populate=creditCardList;
					BaseComboBox(_control).prompt=SELECT_A_PREFIX + this.nonFormattedLabel;
					this.registerControl(_control, validator, null, PROPERTY_SELECTED_INDEX);
					break;
				case FormItemTypes.COMBO_BOX:
					_control=new BaseComboBox();
					_control.prompt=SELECT_A_PREFIX + this.nonFormattedLabel;
					validator=new ComboBoxValidator();
					this.registerControl(_control, validator, null, PROPERTY_SELECTED_INDEX);
					BaseComboBox(_control).dataProvider=dataProvider;
					break;
				case FormItemTypes.CURRENCY:
					_control=new TextInput();
					TextInput(_control).restrict=InputRestrictions.RESTRICT_TO_CURRENCY;
					TextInput(_control).maxChars=this.maxLength;
					validator=new CurrencyValidator();
					CurrencyValidator(validator).allowNegative=false;
					CurrencyValidator(validator).thousandsSeparator=',';
					CurrencyValidator(validator).precision=2;
					CurrencyValidator(validator).minValue=this.minValue;
					CurrencyValidator(validator).maxValue=this.maxValue;
					this.registerControl(_control, validator, formatCurrency);
					break;
				case FormItemTypes.DATE:
					_control=new TextInput();
					TextInput(_control).restrict=InputRestrictions.RESTRICT_TO_DATE;
					TextInput(_control).maxChars=InputRestrictions.DATE_MAX_CHARS;
					validator=new DateValidator();
					DateValidator(validator).inputFormat=InputRestrictions.STANDARD_US_DATE_FORMAT;
					this.registerControl(_control, validator, formatDate);
					break;
				case FormItemTypes.EMAIL:
					_control=new TextInput();
					TextInput(_control).restrict=InputRestrictions.RESTRICT_TO_EMAIL;
					TextInput(_control).maxChars=InputRestrictions.EMAIL_MAX_CHARS;
					validator=new EmailValidator();
					this.registerControl(_control, validator);
					break;
				case FormItemTypes.FILE_MANAGER:
					_control=new FileManagerFormItem();
					validator=new CollectionValidator();
					this.registerControl(_control, validator, null, PROPERTY_LENGTH);
					break;
				case FormItemTypes.FIRST_NAME:
					_control=new TextInput();
					TextInput(_control).restrict=InputRestrictions.RESTRICT_TO_CHARS_SPACES;
					TextInput(_control).maxChars=InputRestrictions.FIRST_NAME_MAX_CHARS;
					validator=new StringValidator();
					StringValidator(validator).minLength=minLength;
					this.registerControl(_control, validator);
					break;
				case FormItemTypes.LAST_NAME:
					_control=new TextInput();
					TextInput(_control).restrict=InputRestrictions.RESTRICT_TO_CHARS_SPACES;
					TextInput(_control).maxChars=InputRestrictions.FIRST_NAME_MAX_CHARS;
					validator=new StringValidator();
					StringValidator(validator).minLength=minLength;
					PROPERTY_TEXT
					this.registerControl(_control, validator);
					break;
				case FormItemTypes.NUMERIC_STEPPER:
					_control=new NumericStepper();
					validator=new NumberValidator();
					NumberValidator(validator).minValue=this.minValue;
					NumberValidator(validator).maxValue=this.maxValue;
					NumericStepper(_control).minimum=this.minValue;
					NumericStepper(_control).maximum=this.maxValue;
					NumericStepper(_control).stepSize=this.stepSize;
					this.registerControl(_control, validator, null, PROPERTY_VALUE);
					break;
				case FormItemTypes.PHONE_NUMBER:
					_control=new TextInput();
					TextInput(_control).restrict=InputRestrictions.RESTRICT_TO_PHONE_NUMBER;
					TextInput(_control).maxChars=InputRestrictions.PHONE_NUMBER_MAX_CHARS;
					validator=new PhoneNumberValidator();
					PhoneNumberValidator(validator).allowedFormatChars=InputRestrictions.ALLOWED_FORMAT_CHARACTERS_PHONE;
					PhoneNumberValidator(validator).minDigits=InputRestrictions.PHONE_NUMBER_MIN_DIGITS;
					this.registerControl(_control, validator, formatPhoneNumber);
					break;
				case FormItemTypes.RADIO_BUTTON_GROUP:
					_control=new HBox();
					HBox(_control).percentHeight=100;
					HBox(_control).styleName='radioButtonGroup';
					radioButtonGroup=new RadioButtonGroup();
					RadioButtonGroup(radioButtonGroup).labelPlacement=ButtonLabelPlacement.RIGHT;
					validator=new Validator();
					Validator(validator).listener=_control;
					Validator(validator).requiredFieldError="One option must be selected";
					this.registerControl(radioButtonGroup, validator, null, SELECTED_VALUE);
					break;
				case FormItemTypes.PASSWORD:
					_control=getPasssordTextInput(new TextInput());
					validator=getPasswordValidator(new StringValidator());
					this.registerControl(_control, validator);
					break;
				case FormItemTypes.RICH_TEXT_EDITOR:
					_control=new RichTextEditor();
					RichTextEditor(_control).percentWidth=100;
					RichTextEditor(_control).percentWidth=100;
					validator=new StringValidator();
					StringValidator(validator).minLength=this.minLength;
					StringValidator(validator).maxLength=this.maxLength;
					this.registerControl(_control, validator);
					break;
				case FormItemTypes.SOCIAL_SECURITY:
					_control=new TextInput();
					TextInput(_control).restrict=InputRestrictions.RESTRICT_TO_NUMBERS_HYPHENS;
					TextInput(_control).maxChars=InputRestrictions.SOCIAL_SECURITY_MAX;
					validator=new SocialSecurityValidator();
					this.registerControl(_control, validator, formatSocialSecurity);
					break;
				case FormItemTypes.TEXT_INPUT:
					_control=new TextInput();
					TextInput(_control).restrict=restriction;
					TextInput(_control).maxChars=this.maxLength;
					;
					validator=new StringValidator();
					StringValidator(validator).minLength=this.minLength;
					this.registerControl(_control, validator);
					break;
				case FormItemTypes.TIME:
					_control=new TextInput();
					TextInput(_control).restrict=InputRestrictions.RESTRICT_TO_TIME;
					TextInput(_control).maxChars=InputRestrictions.TIME_MAX_CHARS;
					validator=new RegExpValidator();
					RegExpValidator(validator).expression='^((([0]?[1-9]|1[0-2])(:|\.)[0-5][0-9]((:|\.)[0-5][0-9])?( )?(AM|am|aM|Am|PM|pm|pM|Pm))|(([0]?[0-9]|1[0-9]|2[0-3])(:|\.)[0-5][0-9]((:|\.)[0-5][0-9])?))$';
					this.registerControl(_control, validator);
					break;
				case FormItemTypes.URI:
					_control=new TextInput();
					TextInput(_control).restrict=InputRestrictions.RESTRICT_TO_KITCHEN_SINK;
					TextInput(_control).maxChars=InputRestrictions.URL_MAX_CHARS;
					validator=new RegExpValidator();
					//http://regexlib.com/REDetails.aspx?regexp_id=622
					RegExpValidator(validator).expression='^(((ht|f)tp(s?))\://)?(www.|[a-zA-Z].)[a-zA-Z0-9\-\.]+\.(com|edu|gov|mil|net|org|biz|info|name|museum|us|ca|uk)(\:[0-9]+)*(/($|[a-zA-Z0-9\.\,\;\?\'\\\+&amp;%\$#\=~_\-]+))*$';
					this.registerControl(_control, validator);
					break;
				case FormItemTypes.ZIP_CODE:
					_control=new TextInput();
					TextInput(_control).restrict=InputRestrictions.RESTRICT_TO_NUMBERS_HYPHENS;
					TextInput(_control).maxChars=InputRestrictions.ZIP_CODE_MAX;
					validator=new ZipCodeValidator();
					ZipCodeValidator(validator).domain=ZIP_CODE_DOMAIN;
					this.registerControl(_control, validator, formatZipCode);
					break;
				default:
					throw new Fault('Error', 'Could not find the desired form-type. Received request for ' + type);
					return;
			}
			this.setControlWidth();
			this.addChildComponent(_control);
			this.addFormatHint();
			super.createChildren();
		}

		[Bindable]
		protected function get dataProvider():Object
		{
			return _dataProvider;
		}

		protected function set dataProvider(value:Object):void
		{
			if (type != FormItemTypes.COMBO_BOX)
			{
				throw new Fault('Error', 'Do not set the dataProvider for this _control');
			}
			this._dataProvider=value;
		}

		protected function formatCurrency(event:Event):void
		{
			if (!_formatter)
			{
				_formatter=new CurrencyFormatter();
				CurrencyFormatter(_formatter).currencySymbol='$';
				CurrencyFormatter(_formatter).useThousandsSeparator=true;
				CurrencyFormatter(_formatter).precision=2;
				CurrencyFormatter(_formatter).rounding=NumberBaseRoundType.NONE;
				CurrencyFormatter(_formatter).useNegativeSign=false;
			}
			this.formatValue(event);
		}

		protected function formatCustom(event:Event):void
		{
			if (!_formatter)
			{
				_formatter=this.customFormatter;
			}
			this.formatValue(event);
		}

		protected function formatDate(event:Event):void
		{
			if (!_formatter)
			{
				_formatter=new DateFormatter();
				DateFormatter(_formatter).formatString=InputRestrictions.STANDARD_US_DATE_FORMAT;
			}
			this.formatValue(event);
		}

		protected function formatPhoneNumber(event:Event):void
		{
			if (!_formatter)
			{
				_formatter=new PhoneFormatter();
				PhoneFormatter(_formatter).formatString=phoneNumberFormat;
			}
			this.formatValue(event);
		}

		protected function formatSocialSecurity(event:Event):void
		{
			if (!_formatter)
			{
				_formatter=new PhoneFormatter();
				PhoneFormatter(_formatter).formatString='###-##-####';
				PhoneFormatter(_formatter).areaCodeFormat='';
				PhoneFormatter(_formatter).validPatternChars='-';
			}
			this.formatValue(event);
		}


		protected function formatZipCode(event:Event):void
		{
			if (!_formatter)
			{
				_formatter=new ZipCodeFormatter();
			}
			TextInput(event.currentTarget).length > 5 ? ZipCodeFormatter(_formatter).formatString='#####-####' : ZipCodeFormatter(_formatter).formatString='#####';
			this.formatValue(event);
		}

		protected function getFormatHint():String
		{
			var format:String='';
			switch (type)
			{
				case FormItemTypes.ADDRESS_1:
					format=_formatHintsModel.address1;
					break;
				case FormItemTypes.ADDRESS_2:
					format=_formatHintsModel.address2;
					break;
				case FormItemTypes.CAPTCHA:
					break;
				case FormItemTypes.CHECK_BOX:
					break;
				case FormItemTypes.COMBO_BOX:
					break;
				case FormItemTypes.CREDIT_CARD_EXPIRATION_DATE:
					format=_formatHintsModel.creditCardExpirationDate;
					break;
				case FormItemTypes.CREDIT_CARD_NUMBER:
					format=_formatHintsModel.creditCardNumber_AmericanExpress;
					break;
				case FormItemTypes.CREDIT_CARD_SECURITY_CODE:
					format=_formatHintsModel.creditCardSecurityCode_AmericanExpress;
					break;
				case FormItemTypes.CREDIT_CARD_TYPE:
					break;
				case FormItemTypes.CURRENCY:
					format=_formatHintsModel.currency;
					break;
				case FormItemTypes.DATE:
					format=_formatHintsModel.date;
					break;
				case FormItemTypes.EMAIL:
					format=_formatHintsModel.email;
					break;
				case FormItemTypes.FILE_MANAGER:
					break;
				case FormItemTypes.FIRST_NAME:
					format=_formatHintsModel.firstName;
					break;
				case FormItemTypes.LAST_NAME:
					format=_formatHintsModel.lastName;
					break;
				case FormItemTypes.NUMERIC_STEPPER:
					break;
				case FormItemTypes.PASSWORD:
					format=_formatHintsModel.password;
					break;
				case FormItemTypes.PHONE_NUMBER:
					format=_formatHintsModel.phoneNumber;
					break;
				case FormItemTypes.RADIO_BUTTON_GROUP:
					break;
				case FormItemTypes.RICH_TEXT_EDITOR:
					break;
				case FormItemTypes.SOCIAL_SECURITY:
					format=_formatHintsModel.socialSecurity;
					break;
				case FormItemTypes.TEXT_INPUT:
					format=formatHint;
					break;
				case FormItemTypes.TIME:
					format=_formatHintsModel.time;
					break;
				case FormItemTypes.URI:
					format=_formatHintsModel.uri;
					break;
				case FormItemTypes.ZIP_CODE:
					format=_formatHintsModel.zipCode;
					break;
				default:
					throw new Error('Could not find the desired format. Received request for ' + type);
					break;
			}
			if (format == '')
			{
				trace('The formatter is not available for this FormItem type');
			}
			return format;
		}

		protected function getFormatter(formatter:Formatter):Formatter
		{
			if (this.customFormatter != null)
			{
				return this.customFormatter;
			}
			return this._formatter;
		}

		protected function getGranularErrorString(validator:Validator):Validator
		{
			Validator(validator).requiredFieldError=this.nonFormattedLabel + ' ' + 'is required';

			if (validator is StringValidator)
			{
				StringValidator(validator).tooLongError=this.nonFormattedLabel + ' ' + 'is too long';
				StringValidator(validator).tooShortError=this.nonFormattedLabel + ' ' + 'is too short';
			}

			return validator;
		}

		protected function getValidator(validator:Validator):Validator
		{
			if (this.customValidator)
			{
				return this.customValidator;
			}
			return validator;
		}

		protected function registerControl(control:*, val:Validator, pFormatter:Function=null, property:String=PROPERTY_TEXT):void
		{
			this.controlProperty=property;

			var validator:Validator=this.getValidator(val);
			validator=this.getGranularErrorString(validator);
			validator.property=this.controlProperty;
			validator=addValidatorProperties(control, validator);
			this.registeredValidator=validator;
			if (pFormatter != null)
			{
				DisplayObject(control).addEventListener(FlexEvent.VALUE_COMMIT, pFormatter);
			}
		}

		protected function setControlWidth():void
		{
			if (_control is CheckBox || _control is TextInput || _control is NumericStepper || _control is ComboBox)
			{
				_control.width=ControlSizes.MIN_WIDTH;
			}
		}

		protected function setFormItemLabel():void
		{
			this.nonFormattedLabel=this.label;
			switch (type)
			{
				case FormItemTypes.ADDRESS_1:
					nonFormattedLabel=defaultLabelModel.address1;
					break;
				case FormItemTypes.ADDRESS_2:
					nonFormattedLabel=defaultLabelModel.address2;
					break;
				case FormItemTypes.CAPTCHA:
					nonFormattedLabel=defaultLabelModel.captcha;
					break;
				case FormItemTypes.CHECK_BOX:
					break;
				case FormItemTypes.COMBO_BOX:
					break;
				case FormItemTypes.CREDIT_CARD_EXPIRATION_DATE:
					nonFormattedLabel=defaultLabelModel.creditCardExpirationDate;
					break;
				case FormItemTypes.CREDIT_CARD_NUMBER:
					nonFormattedLabel=defaultLabelModel.creditCardNumber;
					break;
				case FormItemTypes.CREDIT_CARD_SECURITY_CODE:
					nonFormattedLabel=defaultLabelModel.creditCardSecurityCode;
					break;
				case FormItemTypes.CREDIT_CARD_TYPE:
					nonFormattedLabel=defaultLabelModel.creditCardType;
					break;
				case FormItemTypes.CURRENCY:
					nonFormattedLabel=defaultLabelModel.currency;
					break;
				case FormItemTypes.DATE:
					nonFormattedLabel=defaultLabelModel.date;
					break;
				case FormItemTypes.EMAIL:
					nonFormattedLabel=defaultLabelModel.email;
					break;
				case FormItemTypes.FILE_MANAGER:
					nonFormattedLabel=defaultLabelModel.fileManager;
					break;
				case FormItemTypes.FIRST_NAME:
					nonFormattedLabel=defaultLabelModel.firstName;
					break;
				case FormItemTypes.LAST_NAME:
					nonFormattedLabel=defaultLabelModel.lastName;
					break;
				case FormItemTypes.NUMERIC_STEPPER:
					nonFormattedLabel=defaultLabelModel.numericStepper;
					break;
				case FormItemTypes.PASSWORD:
					nonFormattedLabel=defaultLabelModel.password;
					break;
				case FormItemTypes.PHONE_NUMBER:
					nonFormattedLabel=defaultLabelModel.phoneNumber;
					break;
				case FormItemTypes.RADIO_BUTTON_GROUP:
					nonFormattedLabel=defaultLabelModel.radioButtonGroup;
					break;
				case FormItemTypes.RICH_TEXT_EDITOR:
					break;
				case FormItemTypes.SOCIAL_SECURITY:
					nonFormattedLabel=defaultLabelModel.socialSecurity;
					break;
				case FormItemTypes.TEXT_INPUT:
					// throw Alert();
					break;
				case FormItemTypes.TIME:
					nonFormattedLabel=defaultLabelModel.time;
					break;
				case FormItemTypes.URI:
					nonFormattedLabel=defaultLabelModel.uri;
					break;
				case FormItemTypes.ZIP_CODE:
					nonFormattedLabel=defaultLabelModel.zipCode;
					break;
				default:
					throw new Error('Could not find the desired label. Received request for ' + type);
					break;
			}
			if (type == FormItemTypes.CHECK_BOX)
			{
				this.label='';
				return;
			}
			this.label == '' ? (this.label=nonFormattedLabel + ':') : (this.label=(this.label + ':'));
		}

		private function get cachedColorState():String
		{
			return this._cachedColorState;
		}

		private function set cachedColorState(value:String):void
		{
			this._cachedColorState=value;
		}

		private function get creditCardList():Array
		{
			var array:Array=new Array();
			if (!this.excludeAmericanExpress)
			{
				array.push(CreditCardValidatorCardType.AMERICAN_EXPRESS);
			}
			if (!this.excludeDinersClub)
			{
				array.push(CreditCardValidatorCardType.DINERS_CLUB);
			}
			if (!this.excludeDiscover)
			{
				array.push(CreditCardValidatorCardType.DISCOVER);
			}
			if (!this.excludeMasterCard)
			{
				array.push(CreditCardValidatorCardType.MASTER_CARD);
			}
			if (!this.excludeVisa)
			{
				array.push(CreditCardValidatorCardType.VISA);
			}
			array.sort(Array.CASEINSENSITIVE);
			return array;
		}


		private function formatValue(event:Event):void
		{
			var str:String=_formatter.format(TextInput(event.currentTarget).text);
			if (str == '')
			{
				event.stopImmediatePropagation();
				return;
			}
			TextInput(event.currentTarget).text=str;
		}

		private function getPasssordTextInput(control:TextInput):TextInput
		{
			TextInput(control).restrict=InputRestrictions.RESTRICT_TO_PASSWORD;
			TextInput(control).maxChars=InputRestrictions.PASSWORD_MAX_CHARS;
			TextInput(control).displayAsPassword=true;
			return control;
		}

		private function getPasswordValidator(validator:Validator):Validator
		{
			StringValidator(validator).minLength=InputRestrictions.PASSWORD_MIN_CHARS;
			StringValidator(validator).maxLength=InputRestrictions.PASSWORD_MAX_CHARS;
			return validator;
		}

		private function handleMatchingFieldChange(event:Event):void
		{
			StringMatchValidator(validator).matches=TextInput(event.currentTarget).text;
		}

		private function handleWhatsThisClick(event:MouseEvent):void
		{
			if (whatsThisURL != '' && openLinksInNewWindow)
			{
				var urlReq:URLRequest=new URLRequest(whatsThisURL);
				navigateToURL(urlReq, "_blank");
				return;
			}
			if (whatsThisURL != '' && !openLinksInNewWindow)
			{
				var contentWindow:ContentWindow=new ContentWindow();
				contentWindow.fileSource=this.whatsThisURL;
				PopUpManager.addPopUp(contentWindow, mx.core.Application.application.root, true);
				PopUpManager.centerPopUp(contentWindow);
			}

		}

		private function hasFormItemColorStateChanged(newState:String):Boolean
		{
			var hasChanged:Boolean=cachedColorState != newState;
			cachedColorState=newState;
			return hasChanged;
		}

		private function incrementTabIndex(control:DisplayObject):void
		{
			UIComponent(control).tabIndex=tabIndex++;
		}

		private function get lastFormItemStyle():String
		{
			return this._lastFormItemSyle;
		}

		private function set lastFormItemStyle(value:String):void
		{
			this._lastFormItemSyle=value;
		}

		private function get nonFormattedLabel():String
		{
			return this._nonFormattedLabel;
		}

		private function set nonFormattedLabel(value:String):void
		{
			this._nonFormattedLabel=value;
		}

		private function setCheckBoxList():void
		{
			validator=new CollectionValidator();
			CollectionValidator(validator).minValue=this.minValue;
			CollectionValidator(validator).maxValue=this.maxValue;
			for (var i:uint=0; i < this.checkBoxList.length; i++)
			{
				var checkbox:CheckBox=new CheckBox();
				checkbox.label=CheckBoxVO(this.checkBoxList[i]).label;
				checkbox.data=CheckBoxVO(this.checkBoxList[i]).data;
				Tile(_control).addChild(checkbox);
				this.registerControl(_control, validator, null, 'selected');
			}

			invalidateDisplayList();
		}

		private function setRadioButtonList():void
		{
			HBox(_control).removeAllChildren();
			for (var i:uint=0; i < radioButtonList.length; i++)
			{
				var radioButton:RadioButton=new RadioButton();
				radioButton.label=RadioButtonVO(radioButtonList[i]).label;
				radioButton.group=radioButtonGroup;
				radioButton.data=RadioButtonVO(radioButtonList[i]).data;
				radioButton.groupName=_control;
				HBox(_control).addChild(radioButton);
			}

			invalidateDisplayList();
		}

		private function showPassword(event:MouseEvent):void
		{
			TextInput(_control).displayAsPassword=!event.currentTarget.selected;
		}

		private function titleCaseFormatter(value:String):String
		{
			return value;
		}

		private function validateControl(event:ValidationResultEvent):void
		{
			if (event.type == ValidationResultEvent.VALID && this.required)
			{
				this.styleName='formItemPass';
				return;
			}
			if (event.type == ValidationResultEvent.VALID && !this.required)
			{
				return;
			}
			if (event.type == ValidationResultEvent.INVALID && this.required)
			{
				this.styleName='formItemFail';
				return;
			}
			if (event.type == ValidationResultEvent.INVALID && !this.required && this.showWarnings)
			{
				this.styleName='formItemWarn';
				return;
			}
		}
	}
}

