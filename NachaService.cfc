component	name=		"NachaService"
			output=		"false"
			accessors=	"true"
			hint=		"I create Nacha files" {

	property	name=	"CTXService";

	include	"helperACH.cfm";

	/**
	*	Constructor
	*/
	function init ( CTXService=	new	CTXService() ) {

		//	Set CTX Service
		variables.CTXService=	CTXService;

		//	Return Self
		return	this;
	}

	/**
	*	I create a nacha record.
	*/
	function create (	qPayments=					"" ,
						sSecurityRecord=			"" ,
						sFileIDImmediateOrigin=		"Value Provided By Your Bank" ,
						sOriginBankName=			"Your Bank's Name" ,
						sOriginCompanyName=			"Your Company" ,
						sOriginRoutingNumber=		"123123123" ,
						sNachaBatchId=				"1000" ,
						sCompanyEntryDescription=	"ACHPAYMENT" ,
						sLineBreak=					"#chr( 13 )##chr( 10 )#" ) {	//"
//	qPayments
//		bNachaCTXEnabled
//		CreditDebit
//		Amount
//		RoutingNumber
//		AccountNumber
//		IndividualID
//		Name
//	sSecurityRecord
//	sFileIDImmediateOrigin
//	sOriginCompanyName
//	sOriginBankName
//	sOriginRoutingNumber
//	sNachaBatchId
//	sCompanyEntryDescription

		//	Create Result Variable
		var	sNachaRecord=	"";

		//	Anything to do?
		if(	isQuery( qPayments ) == false
		||	qPayments.RecordCount == 0 ) {
			//	Escape!
			return	sNachaRecord;
		}

		//	Hash Array
		var	aHashes=		[];

		//	File Total Credits
		var	dFileCredit=	0;

		//	File Total Debits
		var	dFileDebit=		0;

		//	Entry Count
		var	iEntries=		0;

		//	Batch Number
		var	iBatchNumber=	0;

		//	File Entry Hash
		var	sFileEntryHash=	0;

		//	Security Record Provided?
		if( len( sSecurityRecord ) ) {
			//	Add Security Record
			sNachaRecord=	sSecurityRecord & sLineBreak;

		}


		//	#	Create File Header
		//	Field = record type , size = 1 , position = 1
		sNachaRecord&=	"1";

		//	Field = priority code , size = 2 , position = 2 - 3
		sNachaRecord&=	"01";

		//	Field = Routing number ( Immediate Destination ) , size = 10 , position = 4 - 13
		sNachaRecord&=	" " & justifyLeftAndPadRange( sOriginRoutingNumber , 9 );

		//	Field = File ID ( Immediate Origin ) , size = 10 , position = 14 - 23
		sNachaRecord&=	justifyRightAndPadRange( sFileIDImmediateOrigin , 10 );

		//	Field = File creation date , size = 6 , position = 24 - 29
		sNachaRecord&=	justifyLeftAndPadRange( dateFormat( now() , "YYMMDD" ) , 6 );

		//	Field = File creation time , size = 4 , position = 30 - 33
		sNachaRecord&=	justifyLeftAndPadRange( timeFormat( now() , "HHmm" ) , 4 );

		//	Field = file id modifier , size = 1 , position = 34
		sNachaRecord&=	"A";

		//	Field = record size , size = 3 , position = 35 - 37
		sNachaRecord&=	"094";

		//	Field = blocking factor , size = 2 , position = 38 - 39
		sNachaRecord&=	"10";

		//	Field = format code , size = 1 , position = 40
		sNachaRecord&=	"1";

		//	Field = Origination bank ( immediate destination name ) , size = 23 , position = 41 - 63
		sNachaRecord&=	justifyLeftAndPadRange( sOriginBankName , 23 );

		//	Field = company name ( immediate origin name ) , size = 23 , position = 64 - 86
		sNachaRecord&=	justifyLeftAndPadRange( sOriginCompanyName , 23 );

		//	Field = reference code , size = 8 , position = 87 - 94
		sNachaRecord&=	justifyLeftAndPadRange( "" , 8 );

		//	Line Break
		sNachaRecord&=	sLineBreak;



		//	Using CTX in this Nacha?
		var	bPreviousNachaCTXEnabled=	-1;

		//	#	Create Batchs and Records
		for(	var	iCurrentRow=	1;
				iCurrentRow <= qPayments.RecordCount;
				iCurrentRow++ ) {

			//	New Batch?
			if(	iCurrentRow == 1
			||	bPreviousNachaCTXEnabled != qPayments.bNachaCTXEnabled[ iCurrentRow ] ) {
				//	Update Batch Number
				iBatchNumber++;

				//	Reset Batch Entry Count
				var	iBatchEntries=	0;

				//	Reset Batch Debits
				var	dBatchDebit=	0;

				//	Reset Batch Credits
				var	dBatchCredit=	0;

				//	##	Create Batch Header
				//	Field = record type , size = 1 , position = 1
				sNachaRecord&=	"5";

				//	Field = service class code , size = 3 , position = 2 - 4
				sNachaRecord&=	"200";

				//	Field = company name , size = 16 , position = 5 - 20
				sNachaRecord&=	justifyLeftAndPadRange( sOriginCompanyName , 16 );

				//	Field = company discretionary data , size = 20 , position = 21 - 40
				//	Recommended Format =>	"Batch ID " & iNachaID
				sNachaRecord&=	justifyLeftAndPadRange( sNachaBatchId , 20 );

				//	Field = company id , size = 10 , position = 41 - 50
				sNachaRecord&=	justifyRightAndPadRange( sFileIDImmediateOrigin , 10 );

				//	CTX Data?
				if( qPayments.bNachaCTXEnabled[ iCurrentRow ] ) {
					//	Field = standard entry class ( SEC ) code , size = 3 , position = 51 - 53
					sNachaRecord&=	"CTX";

				}
				else {
					//	Field = standard entry class ( SEC ) code , size = 3 , position = 51 - 53
					sNachaRecord&=	"CCD";

				}

				//	Field = company entry description , size = 10 , position = 54 - 63
				sNachaRecord&=	justifyLeftAndPadRange( sCompanyEntryDescription , 10 );

				//	Field = company descriptive date , size = 6 , position = 64 - 69
				sNachaRecord&=	justifyLeftAndPadRange( "" , 6 );

				//	Field = effective entry date , size = 6 , position = 70 - 75
				sNachaRecord&=	justifyLeftAndPadRange( dateFormat( nextBusinessDay( now() ) , "YYMMDD" ) , 6 );

				//	Field = settlement date , size = 3 , position = 76 - 78
				sNachaRecord&=	justifyLeftAndPadRange( "" , 3 );

				//	Field = originator status code , size = 1 , position = 79
				sNachaRecord&=	"1";

				//	Field = Wells Fargo R/T number ( originating DFI ID ) , size = 8 , position 80 - 87
				sNachaRecord&=	justifyLeftAndPadRange( sOriginRoutingNumber , 8 );

				//	Field = batch number , size = 7 , position = 88 - 94
				sNachaRecord&=	justifyRightAndPadRange( iBatchNumber , 7 , 7 , "0" );

				//	Line Break
				sNachaRecord&=	sLineBreak;

			}

			//	Update Batch Entries
			iBatchEntries++;

			//	##	Create Entry Detail Record or 6 Record
			//	Field = record type , size = 1 , position = 1
			sNachaRecord&=	"6";

			//	Credit Record?
			if( trim( qPayments.CreditDebit[ iCurrentRow ] ) == "CR" ) {
				//	Field = transaction code , size = 2 , position = 2 - 3
				sNachaRecord&= "22";

				//	Update Batch Credits Total
				dBatchCredit+=	numberFormat( qPayments.Amount[ iCurrentRow ] , "9.00" );

			}
			//	Debit Record
			else {
				//	Field = transaction code , size = 2 , position = 2 - 3
				sNachaRecord&=	"27";

				//	Update Batch Debits Total
				dBatchDebit+=	numberFormat( qPayments.Amount[ iCurrentRow ] , "9.00" );

			}

			//	Field = receiving DFI R/T number , size = 8 , position = 4 - 11
			//	AND
			//	Field = R/T number check digit , size = 1 , position = 12
			sNachaRecord&=	qPayments.RoutingNumber[ iCurrentRow ];

			//	Field = receiving DFI account number , size = 17 , position = 13 - 29
			sNachaRecord&=	justifyLeftAndPadRange( qPayments.AccountNumber[ iCurrentRow ] , 17 );

			//	Field = amount , size = 10 , position = 30 - 39
			sNachaRecord&=	justifyRightAndPadRange( numberFormat( qPayments.Amount[ iCurrentRow ] * 100 , "9999999999" ) , 10 , 10 , "0" );

			//	Field = Individual ID ( Individual Identification Number ) , size = 15 , position = 40 - 54
			sNachaRecord&=	justifyLeftAndPadRange( right( grimVariable( qPayments.IndividualID[ iCurrentRow ] ) , 15 ) , 15 );

			//	CTX Batch?
			if( qPayments.bNachaCTXEnabled[ iCurrentRow ] ) {
				//	Insert Easily Replaceable Value
				//	Field = Addenda Count , size = 22 , position = 55 - 58 - When using the SEC code of CTX
				sNachaRecord&=	"PAYCARGO6RECORDADDENDACOUNT";

				//	Normal Individual ID
				//	Field = Individual Name , size = 22 , position = 59 - 76
				sNachaRecord&=	justifyLeftAndPadRange( grimVariable( qPayments.Name[ iCurrentRow ] ) , 18 );

			}
			//	CCD Batch
			else {
				//	Field = Individual Name , size = 22 , position = 55 - 76
				sNachaRecord&=	justifyLeftAndPadRange( grimVariable( qPayments.Name[ iCurrentRow ] ) , 22 );


			}

			//	Field = discretionary data , size = 2 , position = 77 - 78
			sNachaRecord&=	"  ";

			//	Field = addenda record indicator , size = 1 , position = 79
			sNachaRecord&=	"0";

			//	Field = trace number , size = 15 , position = 80 - 94
			sNachaRecord&=	justifyLeftAndPadRange( sOriginRoutingNumber , 8 ) & justifyRightAndPadRange( iCurrentRow + 1 , 7 , 7 , "0" );

			//	Line Break
			sNachaRecord&=	sLineBreak;

			//	Calculate Check Hash
			var	sHash=	justifyLeftAndPadRange( val( qPayments.RoutingNumber[ iCurrentRow ] ) , 8 );

			//	Add Hash to Batch Hash Array
			ArrayAppend( aHashes , sHash );

			//	##	Create CTX Addenda Record
			//	CTX Batch?
			if( qPayments.bNachaCTXEnabled[ iCurrentRow ] ) {

				//	Define Parameters for CTX Service
				var	stCTXParameters=	{
						sOriginRoutingNumber=		sOriginRoutingNumber ,
						sCustomerAccountNumber=		qPayments.AccountNumber[ iCurrentRow ] ,
						sCustomerRoutingNumber=		qPayments.RoutingNumber[ iCurrentRow ] ,
						dTotalAmount=				qPayments.Amount[ iCurrentRow ] ,
						sIndividualID=				qPayments.IndividualID[ iCurrentRow ] ,
						sPayerName=					qPayments.PayerName[ iCurrentRow ] ,
						sPayerCustomerIdentifier=	qPayments.PayerCustomerIdentifier[ iCurrentRow ] ,
						sBillerName=				qPayments.BillerName[ iCurrentRow ] ,
						qBatchTransactionNumbers=	getBatchTransactionNumbers( qPayments.IndividualID[ iCurrentRow ] ) };

				//	Get CTX Detail Records
				var	sCTXDetail=	getCTXService().create(	argumentCollection=	stCTXParameters );

				//	Parse CTX Detail into Addena Records
				var	stCTXDetail=	ctxToNachaFormat(	sCTXDetail ,
														iCurrentRow ,
														sLineBreak );

				//	Update Addenda Count
				sNachaRecord=	REReplaceNoCase(	sNachaRecord ,
													"PAYCARGO6RECORDADDENDACOUNT" ,
													justifyRightAndPadRange( stCTXDetail.iCTXSequenceNumber - 1 , 4 , 4 , "0" ) );

				//	Add Addena Records
				sNachaRecord&=	stCTXDetail.sNachaAddendaRecords;

				//	Update Batch Entries
				iBatchEntries+=	stCTXDetail.iBatchEntries;

			}

			//	Update bPreviousNachaCTXEnabled
			bPreviousNachaCTXEnabled=	qPayments.bNachaCTXEnabled[ iCurrentRow ];

			//	##	Create Batch Footer
			//	Additional Batch?
			if(	iCurrentRow == qPayments.RecordCount
			||	bPreviousNachaCTXEnabled != qPayments.bNachaCTXEnabled[ iCurrentRow + 1 ] ) {

				//	Calculate Batch Hash
				var	sBatchEntryHash=	0;
				for( var sHash in aHashes ) {
					sBatchEntryHash+=	sHash;

				}

				//	Update Entry Count
				iEntries+=	iBatchEntries;

				//	Update File Hash
				sFileEntryHash+=	sBatchEntryHash;

				//	Update File Credit
				dFileCredit+=	dBatchCredit;

				//	Update File Debit
				dFileDebit+=	dBatchDebit;

				//	Create Batch Footer
				//	Field = record type , size = 1 , position = 1
				sNachaRecord&=	"8";

				//	Field = service class code , size = 3 , position = 2 - 4
				sNachaRecord&=	"200";

				//	Field = entry/addenda count , size = 6 , position = 5 - 10
				sNachaRecord&=	justifyRightAndPadRange( iBatchEntries , 6 , 6 , "0" );

				//	Field = entry hash , size = 10 , position = 11 - 20
				sNachaRecord&=	justifyRightAndPadRange( sBatchEntryHash , 10 , 10 , "0" );

				//	Field = total batch debit entry dollar amount , size = 12 , position = 21 - 32
				sNachaRecord&=	justifyRightAndPadRange( dBatchDebit * 100 , 12 , 12 , "0" );

				//	Field = total batch credit entry dollar amount , size = 12 , position = 33 - 44
				sNachaRecord&=	justifyRightAndPadRange( dBatchCredit * 100 , 12 , 12 , "0" );

				//	Field = company id , size = 10 , position = 45 - 54
				sNachaRecord&=	justifyLeftAndPadRange( sFileIDImmediateOrigin , 10 );

				//	Field = message authentication code , size = 19 , position = 55 - 73
				sNachaRecord&=	justifyLeftAndPadRange( "" , 19 );

				//	Field = blank , size = 6 , position = 74 - 79
				sNachaRecord&=	justifyLeftAndPadRange( "" , 6 );

				//	Field = Well Fargo R/T number( originating DFI ID ) , size = 8 , position = 80 - 87
				sNachaRecord&=	justifyLeftAndPadRange( sOriginRoutingNumber , 8 );

				//	Field = batch number , size = 7 , position = 88 - 94
				sNachaRecord&=	justifyRightAndPadRange( iBatchNumber , 7 , 7 , "0" );

				//	Line Break
				sNachaRecord&=	sLineBreak;

			}

		}


		//	#	Create File Control Footer
		//	Calculate Nacha Record Count
		var	iRecords=	iEntries + ( iBatchNumber * 2 ) + 2;

		//	Calculate Filler Rows Needed
		var	iFiller=	10 - ( iRecords % 10 );
		//	Exactly 10?
		if( iFiller == 10 ) {
			//	Reset to 0
			iFiller=	0;

		}

		//	Calculate Block Count
		var	iBlocks=	( iRecords + iFiller ) / 10;

		//	Field = record type , size = 1 , position = 1
		sNachaRecord&=	"9";

		//	Field = batch count , size = 6 , position = 2 - 7
		sNachaRecord&=	justifyRightAndPadRange( iBatchNumber , 6 , 6 , "0" );

		//	Field = block count , size = 6 , position = 8 - 13
		sNachaRecord&=	justifyRightAndPadRange( iBlocks , 6 , 6 , "0" );

		//	Field = entry/addenda record count , size = 8 , position = 14 - 21
		sNachaRecord&=	justifyRightAndPadRange( iEntries , 8 , 8 , "0" );

		//	Field = entry hash total , size = 10 , position = 22 - 31
		sNachaRecord&=	justifyRightAndPadRange( sFileEntryHash , 10 , 10 , "0" );

		//	Field = total file debit entry amount , size = 12 , position = 32 - 43
		sNachaRecord&=	justifyRightAndPadRange( dFileDebit * 100 , 12 , 12 , "0" );

		//	Field = total file credit entry amount , size = 12 , position = 44 - 55
		sNachaRecord&=	justifyRightAndPadRange( dFileCredit * 100 , 12 , 12 , "0" );

		//	Field = filler ( spaces ) , size = 39 , position = 56 - 94
		sNachaRecord&=	justifyLeftAndPadRange( "" , 39 );

		//	Line Break
		sNachaRecord&=	sLineBreak;

		//	Create Filler Records
		for(	var	iFillerRow=	1;
				iFillerRow <= iFiller;
				iFillerRow++ ) {
			//	Create Row Full of 9's
			sNachaRecord&=	justifyLeftAndPadRange( "" , 94 , 94 , "9" );

			//	Line Break
			sNachaRecord&=	sLineBreak;

		}

		//	Return Result
		return	sNachaRecord;
	}

	function ctxToNachaFormat (	sCTXDetail=		"" ,
								iCurrentRow=	1 ,
								sLineBreak=		"#chr( 13 )##chr( 10 )#" ) {	//"
		//	Create Return Variable
		var	stCTXDetail=	{	sNachaAddendaRecords=	"" ,
								iBatchEntries=			0 ,
								iCTXSequenceNumber=		0 };

		//	CTX Data Available?
		while( len( sCTXDetail ) > 0 ) {
			//	CTX Data Length
			iCTXDetailLength=	len( sCTXDetail );

			//	New Addenda Line
			sCTXLineDetail=	left( sCTXDetail , 80 );

			//	Need Another Row?
			if( iCTXDetailLength > 80 ) {
				//	Remove The First 80 Characters
				sCTXDetail=	mid( sCTXDetail , 81 , iCTXDetailLength );

			}
			//	No More Rows
			else {
				//	Remove Everything
				sCTXDetail=	"";

			}

			//	Update Batch Entry Counter
			stCTXDetail.iBatchEntries++;

			//	Field = record type , size = 1 , position = 1
			stCTXDetail.sNachaAddendaRecords&=	"7";

			//	Field = addenda type code , size = 2 , position = 2 - 3
			stCTXDetail.sNachaAddendaRecords&=	"05";

			//	Field = payment-related information , size = 80 , position = 4 - 83
			stCTXDetail.sNachaAddendaRecords&=	justifyLeftAndPadRange( sCTXLineDetail , 80 );

			//	Field = addenda sequence number , size = 4 , position = 84 - 87
			stCTXDetail.sNachaAddendaRecords&=	justifyRightAndPadRange( stCTXDetail.iCTXSequenceNumber , 4 , 4 , "0" );

			//	Field = entry detail sequence number, same as 6 record , size = 4 , position = 84 - 87
			stCTXDetail.sNachaAddendaRecords&=	justifyRightAndPadRange( iCurrentRow + 1 , 7 , 7 , "0" );

			//	Line Break
			stCTXDetail.sNachaAddendaRecords&=	sLineBreak;

			//	Update 7 Record Count
			stCTXDetail.iCTXSequenceNumber++;
		}


		//	Return Nacha Format CTX Deta
		return	stCTXDetail;
	}

	function getBatchTransactionNumbers ( IndividualID ) {
		//	Define Return Variable
		var	qResult=	queryNew( "TransactionNumber,Amount" , "VarChar,Decimal" );

		//	Fake Data
		queryAddRow( qResult );
		querySetCell( qResult , "TransactionNumber" , IndividualID & "1" );
		querySetCell( qResult , "Amount" , 500 );

		queryAddRow( qResult );
		querySetCell( qResult , "TransactionNumber" , IndividualID & "2" );
		querySetCell( qResult , "Amount" , 41500.24 );

		//	Return Query
		return	qResult;
	}

}