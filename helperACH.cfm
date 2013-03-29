<cfscript>
	private function nextBusinessDay ( daDate ) {
		//	Weekend?
		while( DayOfWeek( daDate ) % 6 == 1 ) {
			//	Add A Day
			daDate=	DateAdd( "d" , 1 , daDate );

		}

		//	Return Next Business Day
		return	daDate;
	}

	private function justifyLeftAndPadRange (	sValue=		"" ,
												iLimitLow=	0 ,
												iLimitHigh=	0 ,
												sCharacterToPad=	" " ) {
		//	Low Limit Not Passed?
		if( iLimitLow == 0 ) {
			//	Set Low Limit to Length of Value
			iLimitLow=	len( sValue );

		}

		//	High Limit Not Passed?
		if( iLimitHigh == 0 ) {
			//	Set High Limit to Low Limit
			iLimitHigh=	iLimitLow;

		}

		//	To UpperCase & Trim to High Limit
		sValue=	uCase( left( sValue , iLimitHigh ) );

		//	Determine Characters to Pad
		var	iCharactersToPad=	iLimitLow - len( sValue );

		//	Padding Loop
		for(	var	iPaddingCount=	1;
				iPaddingCount <= iCharactersToPad;
				iPaddingCount++ ) {
			//	Add Padding
			sValue&=	sCharacterToPad;

		}

		//	Return Value
		return	sValue;
	}

	private function justifyRightAndPadRange (	sValue=		"" ,
												iLimitLow=	0 ,
												iLimitHigh=	0 ,
												sCharacterToPad=	" " ) {
		//	Low Limit Not Passed?
		if( iLimitLow == 0 ) {
			//	Set Low Limit to Length of Value
			iLimitLow=	len( sValue );

		}

		//	High Limit Not Passed?
		if( iLimitHigh == 0 ) {
			//	Set High Limit to Low Limit
			iLimitHigh=	iLimitLow;

		}

		//	To UpperCase & Trim to High Limit
		sValue=	uCase( left( sValue , iLimitHigh ) );

		//	Determine Characters to Pad
		var	iCharactersToPad=	iLimitLow - len( sValue );

		//	Padding Loop
		for(	var	iPaddingCount=	1;
				iPaddingCount <= iCharactersToPad;
				iPaddingCount++ ) {
			//	Add Padding
			sValue=	sCharacterToPad & sValue;

		}

		//	Return Value
		return	sValue;
	}

	private function grimVariable ( sValue ) {
		//	Create a Copy of Value
		var	sCopy=	sValue;

		//	Simple Type Check?
		if( isSimpleValue( sCopy ) ) {
			//	Convert HTML to <
			sCopy=	REReplaceNoCase(	sCopy ,
										"&lt;" ,
										'<' ,
										"all" );
			//	Convert HTML to >
			sCopy=	REReplaceNoCase(	sCopy ,
										"&gt;" ,
										'>' ,
										"all" );
			//	Convert HTML to &
			sCopy=	REReplaceNoCase(	sCopy ,
										"&amp;" ,
										'&' ,
										"all" );
			//	Convert HTML to `"`
			sCopy=	REReplaceNoCase(	sCopy ,
										"&quot;" ,
										'"' ,
										"all" );

		}

		//	Return Copy
		return	sCopy;
	}

	private function CTXNumberFormat ( dNumber ) {
		//	Convert to Decimal Format
		dNumber=	decimalFormat( dNumber );

		//	Remove Trailing Zero
		dNumber=	dNumber.ReplaceAll( "(\.0+|\.(\d)0)$" , ".$2" );

		//	Remove Commas
		dNumber=	dNumber.ReplaceAll( "," , "" );

		//	Remove Trailing Period
		dNumber=	dNumber.ReplaceAll( "\.$" , "" );

		//	Remove Leading Zero
		dNumber=	dNumber.ReplaceAll( "^0+" , "" );

		//	Return Formatted Number
		return	dNumber;
	}

</cfscript>