component	name=	"ReturnService"
			hint=	"I create an ACH return file" {

	include	"helperACH.cfm";

	/**
	*	Constructor
	*/
	function init () {

		//	Return Self
		return	this;
	}

	/**
	*	Create Return File
	*/
	function create (	qPayments=					"" ,
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
//	sFileIDImmediateOrigin
//	sOriginCompanyName
//	sOriginBankName
//	sOriginRoutingNumber
//	sNachaBatchId
//	sCompanyEntryDescription


		//	Create Return Content
		var	sContent=	"";

		//	Anything to do?
		if(	isQuery( qPayments ) == false
		||	qPayments.RecordCount == 0 ) {
			//	Escape!
			return	sContent;
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


		//	#	Create File Header
		//	Field = priority , size = 3 , position = 1 - 3
		sContent=	"101";

		//	Field = File ID ( Immediate Origin ) , size = 10 , position = 4 - 13
		sContent&=	justifyRightAndPadRange( sFileIDImmediateOrigin , 10 );

		//	Field = Routing number ( Immediate Destination ) , size = 10 , position = 14 - 23
		sContent&=	justifyLeftAndPadRange( sOriginRoutingNumber , 9 );

		//	Field = File creation date , size = 6 , position = 24 - 29
		sContent&=	justifyLeftAndPadRange( dateFormat( now() , "YYMMDD" ) , 6 );

		//	Field = File creation time , size = 4 , position = 30 - 33
		sContent&=	justifyLeftAndPadRange( timeFormat( now() , "HHmm" ) , 4 );

		//	Field = File id modified , size = 1 , position = 34
		sContent&=	"A";

		//	Field = record size , size = 3 , position = 35 - 37
		sContent&=	"094";

		//	Field = blocking factor , size = 2 , position = 38 - 39
		sContent&=	"10";

		//	Field = format code , size = 1 , position = 40
		sContent&=	"1";

		//	Field = company name ( immediate origin name ) , size = 23 , position = 41 - 63
		sContent&=	justifyLeftAndPadRange( sOriginCompanyName , 23 );

		//	Field = Origination bank ( immediate destination name ) , size = 33 , position = 64 - 86
		sContent&=	justifyLeftAndPadRange( sOriginBankName , 23 );

		//	Field = reference code , size = 8 , position = 87 - 94
		sContent&=	justifyLeftAndPadRange( "" , 8 );

		//	Line Break
		sContent&=	sLineBreak;

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

				//	#	Create Batch Header
				//	Field = record type , size = 1 , position = 1
				sContent&=	"5";

				//	Field = service class code , size = 3 , position = 2 - 4
				sContent&=	"200";

				//	Field = company name , size = 16 , position = 5 - 20
				sContent&=	justifyLeftAndPadRange( sOriginCompanyName , 16 );

				//	Field = company discretionary data , size = 20 , position = 21 - 40
				//	Recommended Format =>	"Batch ID " & iNachaID
				sContent&=	justifyLeftAndPadRange( sNachaBatchId , 20 );

				//	Field = company id , size = 10 , position = 41 - 50
				sContent&=	justifyRightAndPadRange( sFileIDImmediateOrigin , 10 );

				//	CTX Data?
				if( qPayments.bNachaCTXEnabled[ iCurrentRow ] ) {
					//	Field = standard entry class ( SEC ) code , size = 3 , position = 51 - 53
					sContent&=	"CTX";

				}
				else {
					//	Field = standard entry class ( SEC ) code , size = 3 , position = 51 - 53
					sContent&=	"CCD";

				}

				//	Field = company entry description , size = 10 , position = 54 - 63
				sContent&=	justifyLeftAndPadRange( sCompanyEntryDescription , 10 );

				//	Field = company descriptive date , size = 6 , position = 64 - 69
				sContent&=	justifyLeftAndPadRange( "" , 6 );

				//	Field = effective entry date , size = 6 , position = 70 - 75
				sContent&=	justifyLeftAndPadRange( dateFormat( nextBusinessDay( now() ) , "YYMMDD" ) , 6 );

				//	Field = settlement date , size = 3 , position = 76 - 78
				sContent&=	justifyLeftAndPadRange( "" , 3 , 3 , "0" );

				//	Field = originator status code , size = 1 , position = 79
				sContent&=	"1";

				//	Field = Wells Fargo R/T number ( originating DFI ID ) , size = 8 , position 80 - 87
				sContent&=	justifyLeftAndPadRange( sOriginRoutingNumber , 8 );

				//	Field = Found Not Found Indicator ( originating DFI ID ) , size = 1 , position 88
				sContent&=	justifyRightAndPadRange( sOriginRoutingNumber , 1 );

				//	Field = batch number , size = 7 , position = 89 - 94
				sContent&=	justifyRightAndPadRange( iBatchNumber , 7 , 7 , "0" );

				//	Line Break
				sContent&=	sLineBreak;

			}

			//	Update Batch Entries
			iBatchEntries++;

			//	##	Create Entry Detail Record or 6 Record
			//	Field = record type , size = 1 , position = 1
			sContent&=	"6";

			//	Credit Record?
			if( trim( qPayments.CreditDebit[ iCurrentRow ] ) == "CR" ) {
				//	Field = transaction code , size = 2 , position = 2 - 3
				sContent&= "21";

				//	Update Batch Credits Total
				dBatchCredit+=	numberFormat( qPayments.Amount[ iCurrentRow ] , "9.00" );

			}
			//	Debit Record
			else {
				//	Field = transaction code , size = 2 , position = 2 - 3
				sContent&=	"26";

				//	Update Batch Debits Total
				dBatchDebit+=	numberFormat( qPayments.Amount[ iCurrentRow ] , "9.00" );

			}

			//	Field = receiving DFI R/T number , size = 8 , position = 4 - 11
			//	AND
			//	Field = R/T number check digit , size = 1 , position = 12
			sContent&=	justifyLeftAndPadRange( qPayments.RoutingNumber[ iCurrentRow ] , 9 );

			//	Field = receiving DFI account number , size = 17 , position = 13 - 29
			sContent&=	justifyLeftAndPadRange( qPayments.AccountNumber[ iCurrentRow ] , 17 );

			//	Field = amount , size = 10 , position = 30 - 39
			sContent&=	justifyRightAndPadRange( numberFormat( qPayments.Amount[ iCurrentRow ] * 100 , "9999999999" ) , 10 , 10 , "0" );

			//	Field = Individual ID ( Individual Identification Number ) , size = 15 , position = 40 - 54
			sContent&=	justifyLeftAndPadRange( right( grimVariable( qPayments.IndividualID[ iCurrentRow ] ) , 15 ) , 15 );

			//	CTX Batch?
			if( qPayments.bNachaCTXEnabled[ iCurrentRow ] ) {
				//	Insert Easily Replaceable Value
				//	Field = Addenda Count , size = 4 , position = 55 - 58 - When using the SEC code of CTX
				sContent&=	"PAYCARGO6RECORDADDENDACOUNT";

				//	Normal Individual ID
				//	Field = Individual Name , size = 18 , position = 59 - 76
				sContent&=	justifyLeftAndPadRange( grimVariable( qPayments.Name[ iCurrentRow ] ) , 18 );

			}
			//	CCD Batch
			else {
				//	Field = Individual Name , size = 22 , position = 55 - 76
				sContent&=	justifyLeftAndPadRange( grimVariable( qPayments.Name[ iCurrentRow ] ) , 22 );


			}

			//	Field = discretionary data , size = 2 , position = 77 - 78
			sContent&=	"  ";

			//	Field = addenda record indicator , size = 1 , position = 79
			sContent&=	"0";

			//	Field = trace number , size = 15 , position = 80 - 94
			sContent&=	justifyLeftAndPadRange( sOriginRoutingNumber , 8 ) & justifyLeftAndPadRange( val( qPayments.RoutingNumber[ iCurrentRow ] ) , 7 );

			//	Line Break
			sContent&=	sLineBreak;

			//	Calculate Check Hash
			var	sHash=	justifyLeftAndPadRange( val( qPayments.RoutingNumber[ iCurrentRow ] ) , 8 );

			//	Add Hash to Batch Hash Array
			ArrayAppend( aHashes , sHash );



			//	Update Batch Entries
			iBatchEntries++;

			//	##	Create Return Detail Record or 7 Record
			//	Field = record type , size = 1 , position = 1
			sContent&=	"7";

			//	Field = transaction code , size = 2 , position = 2 - 3
			sContent&=	"99";

			//	Field = Return Reason Code , size = 3 , position = 4 - 7
			sContent&=	justifyLeftAndPadRange( qPayments.ReturnReasonCode[ iCurrentRow ] , 3 );

			//	Field = Original Entry Trace Number , size = 15 , position = 7 - 21
			sContent&=	justifyLeftAndPadRange( sOriginRoutingNumber , 8 ) & justifyLeftAndPadRange( val( qPayments.RoutingNumber[ iCurrentRow ] ) , 7 );

			//	Field = Date of Death , size = 6 , position = 22 - 27
			sContent&=	justifyLeftAndPadRange( qPayments.DateOfDeath[ iCurrentRow ] , 6 );

			//	Field = Original RDFI Routing Number , size = 8 , position = 28 - 35
			sContent&=	justifyLeftAndPadRange( qPayments.OriginalRDFIRoutingNumber[ iCurrentRow ] , 8 );

			//	Field = Addenda Information , size = 44 , position = 36 - 79
			sContent&=	justifyLeftAndPadRange( qPayments.AddendaInformation[ iCurrentRow ] , 44 );

			//	Field = Trace Number , size = 15 , position = 80 - 94
			sContent&=	justifyLeftAndPadRange( sOriginRoutingNumber , 8 ) & justifyRightAndPadRange( sHash , 7 , 7 , "0" );

			//	Line Break
			sContent&=	sLineBreak;





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
				sContent&=	"8";

				//	Field = service class code , size = 3 , position = 2 - 4
				sContent&=	"200";

				//	Field = entry/addenda count , size = 6 , position = 5 - 10
				sContent&=	justifyRightAndPadRange( iBatchEntries , 6 , 6 , "0" );

				//	Field = entry hash , size = 10 , position = 11 - 20
				sContent&=	justifyRightAndPadRange( sBatchEntryHash , 10 , 10 , "0" );

				//	Field = total batch debit entry dollar amount , size = 12 , position = 21 - 32
				sContent&=	justifyRightAndPadRange( dBatchDebit * 100 , 12 , 12 , "0" );

				//	Field = total batch credit entry dollar amount , size = 12 , position = 33 - 44
				sContent&=	justifyRightAndPadRange( dBatchCredit * 100 , 12 , 12 , "0" );

				//	Field = company id , size = 10 , position = 45 - 54
				sContent&=	justifyLeftAndPadRange( sFileIDImmediateOrigin , 10 );

				//	Field = message authentication code , size = 19 , position = 55 - 73
				sContent&=	justifyLeftAndPadRange( "" , 19 );

				//	Field = blank , size = 6 , position = 74 - 79
				sContent&=	justifyLeftAndPadRange( "" , 6 );

				//	Field = Well Fargo R/T number( originating DFI ID ) , size = 8 , position = 80 - 87
				sContent&=	justifyLeftAndPadRange( sOriginRoutingNumber , 8 );

				//	Field = batch number , size = 7 , position = 88 - 94
				sContent&=	justifyRightAndPadRange( iBatchNumber , 7 , 7 , "0" );

				//	Line Break
				sContent&=	sLineBreak;

			}

		}


		//	#	Create File Control Footer
		//	Calculate Nacha Record Count
		var	iRecords=	iEntries + ( iBatchNumber * 2 ) + 2;

		//	Calculate Block Count
		var	iBlocks=	( iRecords ) / 10;
			iBlocks=	numberFormat( iBlocks , "0" );

		//	Field = record type , size = 1 , position = 1
		sContent&=	"9";

		//	Field = batch count , size = 6 , position = 2 - 7
		sContent&=	justifyRightAndPadRange( iBatchNumber , 6 , 6 , "0" );

		//	Field = block count , size = 6 , position = 8 - 13
		sContent&=	justifyRightAndPadRange( iBlocks , 6 , 6 , "0" );

		//	Field = entry/addenda record count , size = 8 , position = 14 - 21
		sContent&=	justifyRightAndPadRange( iEntries , 8 , 8 , "0" );

		//	Field = entry hash total , size = 10 , position = 22 - 31
		sContent&=	justifyRightAndPadRange( sFileEntryHash , 10 , 10 , "0" );

		//	Field = total file debit entry amount , size = 12 , position = 32 - 43
		sContent&=	justifyRightAndPadRange( dFileDebit * 100 , 12 , 12 , "0" );

		//	Field = total file credit entry amount , size = 12 , position = 44 - 55
		sContent&=	justifyRightAndPadRange( dFileCredit * 100 , 12 , 12 , "0" );

		//	Field = filler ( spaces ) , size = 39 , position = 56 - 94
		sContent&=	justifyLeftAndPadRange( "" , 39 );

		//	Line Break
		sContent&=	sLineBreak;


		//	Return Content
		return	sContent;
	}


}