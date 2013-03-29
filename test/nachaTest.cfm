<cftry>

<cfscript>
oNachaService=	new	lib.orangexception.nacha.NachaService();

sSecurityRecord=	"$$ADD ID=";	//	field = request type , size = 9 , position = 1 - 9
sSecurityRecord&=	"Z3LCOTF6";		//	field = user id , size = 8 , position = 10 - 17
sSecurityRecord&=	" ";			//	field = blank , size = 1 , position = 18
sSecurityRecord&=	"BID=";			//	field = batch id parameter , size = 4 , position = 19 - 22
sSecurityRecord&=	"'";			//	field = starting single quote , size = 1 , position = 23
sSecurityRecord&=	"NWFACH";		//	field = file type , size = 6 , position = 24 - 29
sSecurityRecord&=	"26218304";		//	field = application id , size = 8 , position = 30 - 37
sSecurityRecord&=	"'";			//	field = ending single quote , size = 1 , position = 38

qData=	queryNew( "bNachaCTXEnabled,CreditDebit,Amount,RoutingNumber,AccountNumber,IndividualID,Name,PayerName,PayerCustomerIdentifier,BillerName" );

queryAddRow( qData );
querySetCell( qData , "bNachaCTXEnabled" , 1 );
querySetCell( qData , "CreditDebit" , 'D' );
querySetCell( qData , "Amount" , 42000.24 );
querySetCell( qData , "RoutingNumber" , '123123123' );
querySetCell( qData , "AccountNumber" , '999900009999' );
querySetCell( qData , "IndividualID" , 'Batch 45069' );
querySetCell( qData , "Name" , 'Exception LLC' );
querySetCell( qData , "PayerName" , 'Exception LLC' );
querySetCell( qData , "PayerCustomerIdentifier" , '0001' );
querySetCell( qData , "BillerName" , 'orangexception LLC' );

sContent=	oNachaService.create(	qPayments=					qData ,
									sSecurityRecord=			sSecurityRecord ,
									sFileIDImmediateOrigin=		"2621830443" ,
									sOriginBankName=			"WELLS FARGO BANK" ,
									sOriginCompanyName=			"orangexception" ,
									sOriginRoutingNumber=		"123123123" ,
									sNachaBatchId=				"NACHA 1000" ,
									sCompanyEntryDescription=	"ACHPAYMENT" ,
									sLineBreak=					"#chr( 13 )##chr( 10 )#" );

fileWrite( expandPath( "/lib/orangexception/nacha/test/nacha.txt" ) , sContent );

</cfscript>

	<cfcatch>
		<cfdump	var=	"#cfcatch#" />
	</cfcatch>
</cftry>
<cfabort />