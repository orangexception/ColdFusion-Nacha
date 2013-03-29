component	name=	"CTXService"
			hint=	"I create a CTX record." {

	include	"helperACH.cfm";

	/**
	*	Constructor
	*/
	function init () {

		//	Return Self
		return	this;
	}

	/**
	*	Create CTX Record
	*	qBatchTransactionNumbers expects a query with TransactionNumber and Amount columns. If not passed, then the sIndividualID and dTotalAmount are used.
	*/
	function create (	sOriginRoutingNumber=		"123123123" ,
						sCustomerAccountNo=			"0" ,
						sCustomerRoutingNo=			"123123123" ,
						dTotalAmount=				0 ,
						sIndividualID=				"sNacha6RecordIndividualID" ,
						sPayerName=					"Payer" ,
						sPayerCustomerIdentifier=	"CustomValueThatIdentifiesPayer" ,
						sBillerName=				"Biller" ,
						qBatchTransactionNumbers=	"" ) {
		//	Create Return Record
		var	sCTXRecord=	"";

		//	Define Segment Break
		var	sCTXSegmentBreak=	"\";	//"

		//	Create ISA Header
		var	sCTXRecord=		"ISA*00*          *00*          *17*#justifyLeftAndPadRange( sOriginRoutingNumber , 15 )#*17*#justifyLeftAndPadRange( sCustomerRoutingNo , 15 )#*#dateFormat( now() , "YYMMDD" )#*#timeFormat( now() , "HHMM" )#*U*00401*000000001*0*P*~" & sCTXSegmentBreak;

		//	Create GS Header
		var	sCTXRecord&=	"GS*RA*ISA06*ISA08*#dateFormat( now() , "YYYYMMDD" )#*#timeFormat( now() , "HHMM" )#*1*X*004010STP820" & sCTXSegmentBreak;

		//	Create ST Header
		sCTXRecord&=	"ST*820*#numberFormat( 1 , "0000" )#" & sCTXSegmentBreak;

		//	Set Standard Record Count
		var	iNumberOfSegmentsBetweenSTandSE=	8;

		//	Create BPR Record
		sCTXRecord&=	"BPR*C*#justifyLeftAndPadRange( CTXNumberFormat( dTotalAmount ) , 10 )#*C*ACH*CTX*******01*#sCustomerRoutingNo#*22*#justifyLeftAndPadRange( sCustomerAccountNo , 1 , 17 )#*#dateFormat( now() , "YYYYMMDD" )#" & sCTXSegmentBreak;

		//	Create TRN Record
		sCTXRecord&=	"TRN*1*#justifyLeftAndPadRange( sIndividualID , 1 , 30 )#" & sCTXSegmentBreak;	// Batch ##

		//	Create N1 Payer Record
		sCTXRecord&=	"N1*PR*#justifyLeftAndPadRange( grimVariable( sPayerName ) , 1 , 16 )#*91*#justifyLeftAndPadRange( sPayerCustomerIdentifier , 2 , 80 )#" & sCTXSegmentBreak;

		//	Create N1 Biller Record
		sCTXRecord&=	"N1*PE*#justifyLeftAndPadRange( grimVariable( sBillerName ) , 1 , 16 )#" & sCTXSegmentBreak;

		//	Create ENT Header
		sCTXRecord&=	"ENT*1" & sCTXSegmentBreak;

		//	Batched Payments?
		if(	isQuery( qBatchTransactionNumbers )
		&&	qBatchTransactionNumbers.RecordCount ) {

			//	Update Counter
			iNumberOfSegmentsBetweenSTandSE-=	1;

			//	Loop Through Payments
			for(	var	iBatchCurrentRow=	1;
					iBatchCurrentRow <= qBatchTransactionNumbers.RecordCount;
					iBatchCurrentRow++ ) {
				//	Add RMR Detail
				sCTXRecord&=	"RMR*IV*#justifyLeftAndPadRange( qBatchTransactionNumbers.TransactionNumber[ iBatchCurrentRow ] , 1 , 30 )#**#justifyLeftAndPadRange( CTXNumberFormat( qBatchTransactionNumbers.Amount[ iBatchCurrentRow ] ) , 10 )#" & sCTXSegmentBreak;

				//	Update Counter
				iNumberOfSegmentsBetweenSTandSE+=	1;

			}

		}
		//	Single Payment
		else {

			//	Add RMR Detail
			sCTXRecord&=	"RMR*IV*#justifyLeftAndPadRange( sIndividualID , 1 , 30 )#**#justifyLeftAndPadRange( CTXNumberFormat( dTotalAmount ) , 10 )#" & sCTXSegmentBreak;


		}

		//	Add SE Footer
		sCTXRecord&=	"SE*#iNumberOfSegmentsBetweenSTandSE#*#NumberFormat( 1 , "0000" )#" & sCTXSegmentBreak;

		//	Add GE Footer
		sCTXRecord&=	"GE*1*1" & sCTXSegmentBreak;

		//	Add IEA Footer
		sCTXRecord&=	"IEA*1*000000001" & sCTXSegmentBreak;

		//	Return Record
		return	sCTXRecord;
	}

}